---
title: Implement the Credit Card Tender Type
excerpt: TODO
created_at: 2019/10/25
---

Implement the Credit Card Tender Type
======================================================================

[The credit card tender type](/articles/payment-tender-types.html#credit-card-tender-type_2) is a [payment tender type](/articles/payment-tender-types.html) included in base, but incomplete.
You must fully implement this tender type in order to accept credit card payments in production.
For many payment providers, you can install a Workarea plugin that completes the implementation for you.

However, a retailer may choose a payment service provider for which no Workarea plugin is available, or you may be tasked with writing the plugin for a particular provider.
In either case, you can complete the credit card tender type implementation in the following steps:

1. [Implement gateways](#gateways_1)
2. [Implement credit card tokenization](#credit-card-tokenization_2)
3. [Implement each payment operation](#operation-implementations_3)

The following sections cover each step in greater depth and provide examples from
_Workarea Core_ v3.4.18 (
[gem](https://rubygems.org/gems/workarea-core/versions/3.4.18),
[docs](https://www.rubydoc.info/gems/workarea-core/3.4.18),
[source](https://github.com/workarea-commerce/workarea/tree/v3.4.18/core)
)
and
_Workarea Braintree_ v1.0.3 (
[gem](https://rubygems.org/gems/workarea-braintree/versions/1.0.3),
[docs](https://www.rubydoc.info/gems/workarea-braintree/1.0.3),
[source](https://github.com/workarea-commerce/workarea-braintree/tree/v1.0.3)
).


Gateways
----------------------------------------------------------------------

[Implementing Payment Tender Types, Gateways](/articles/implementing-payment-tender-types.html#gateways_1).

The base credit card tender type uses a bogus gateway.
[`ActiveMerchant::Billing::BogusGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BogusGateway).
Which is [initialized and memoized in configuration](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/config/initializers/11_payment.rb#L6).
This is a [gateway anti-pattern](/articles/implementing-payment-tender-types.html#gateway-anti-patterns_3).
Use a current [gateway pattern](/articles/implementing-payment-tender-types.html#gateway-patterns_2) instead.

The gateway is accessed via the `#gateway` method in a module that's mixed into objects that need access to the gateway.
[`Payment::CreditCardOperation`](https://github.com/workarea-commerce/workarea/blob/master/core/app/models/workarea/payment/credit_card_operation.rb).
[`Payment::CreditCardOperation#gateway`](https://github.com/workarea-commerce/workarea/blob/master/core/app/models/workarea/payment/credit_card_operation.rb#L15-L17)
The method returns the memoized gateway.

Apps need a gateway that connects to an actual payment service provider.
The service must support credit card tokenization to be compatible with Workarea.
See section [Credit Card Tokenization](#credit-card-tokenization_2).

The Workarea Braintree plugin integrates integrates Workarea with the [Braintree](https://www.braintreepayments.com/) payment service.


Workarea Braintree relies on the credit card operation mixin from base to access the gateway.

But to use its own gateway instances, it reconfigures some things when the app boots.

It has [autoconfiguration code](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/lib/workarea/braintree.rb#L8-L24), which is called from an [initializer](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/config/initializers/workarea.rb#L1).

The effect is that in any environment, where there are braintree secrets, you get a "real" Braintree endpoint:

[`ActiveMerchant::Billing::BraintreeGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BraintreeGateway)

Otherwise, you get a bogus gateway thate doesn't go over the network:

[`ActiveMerchant::Billing::BogusBraintreeGateway`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/lib/active_merchant/billing/bogus_braintree_gateway.rb)

So, to use the real Braintree service in production, users of this plugin must add production secrets for braintree (get these from the retailer who owns the account):

```yaml
# config/secrets.yml
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  braintree:
    merchant_id: foo
    public_key: bar
    private_key: baz
    merchant_account_id: qux
```

Which you can confirm by opening a production console:

```shell
$ RAILS_ENV=production bin/rails c
```

or, for Commerce Cloud:

```shell
$ workarea production console
```

And viewing the braintree secrets:

```ruby
puts Rails.application.secrets.braintree
# {:merchant_id=>"foo", :public_key=>"bar", :private_key=>"baz", :merchant_account_id=>"qux"}
```

To use the braintree service with Commerce Cloud, you'd also have to update the proxy configuration to allow outgoing requests to the Braintree service.
See [Implementing Payment Tender Types, Commerce Cloud Proxy](/articles/implementing-payment-tender-types.html#commerce-cloud-proxy_4).

For the automated testing gateway, Braintree implements [`BraintreeGatewayVCRConfig`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/support/workarea/braintree_support_vcr_config.rb), a module that is mixed into all automated tests that need to communicate with Braintree.

The module assigns a new/different instance of [`ActiveMerchant::Billing::BraintreeGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BraintreeGateway) as the credit card gateway in configuration.
It uses bogus creds, which is fine because all the requests have already been recorded as [VCR cassettes](https://github.com/workarea-commerce/workarea-braintree/tree/v1.0.3/test/vcr_cassettes).

The plugin [decorates `Payment::CreditCardIntegrationTest`](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/credit_card_integration_test.decorator), mixing in the module so that all requests to the gateway are now returned from the vcr cassettes.

if you are using the braintree plugin or similar plugin in your app, the tests were written to talk to a real braintree endpoint
but don't actually do so when you run the tests.

if you are implementing a new cc gateway from scratch, you can follow this pattern by using a "real" gateway for testing
until all the tests pass and then commit the casettes and remove your credentials from your test setup.


Credit Card Tokenization
----------------------------------------------------------------------

In addition to processing payments, a credit card gateway is responsible for [credit card tokenization](/articles/implementing-payment-tender-types.html#credit-card-tokenization_5).
Workarea encapsulates its tokenization logic within `Payment::StoreCreditCard`, particularly `Payment::StoreCreditCard#perform!` (with tests in `Payment::StoreCreditCardTest`).

If your gateway's tokenization API differs from Workarea's default implementation, decorate `Payment::StoreCreditCard` to customize the implementation as necessary.

The default implementation of `#perform!` assumes the gateway responds to `#store`, returns the token in the param `billingid` and will potentially raise `ActiveMerchant::ResponseError`, `ActiveMerchant::ActiveMerchantError`, or `ActiveMerchant::ConnectionError` (encapsulated by `handle_active_merchant_error`).
The full implementation follows
([source](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/store_credit_card.rb)):

```ruby
module Workarea
  class Payment
    class StoreCreditCard
      def perform!
        return true if @credit_card.token.present?

        response = handle_active_merchant_errors do
          gateway.store(@credit_card.to_active_merchant)
        end

        @credit_card.token = response.params['billingid']

        response.success?
      end
    end
  end
end
```

Change the aspects that differ for your gateway.
For example, the Braintree gateway returns the card token within a different parameter
([source](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/store_credit_card.decorator)):

```ruby
module Workarea
  decorate Payment::StoreCreditCard, with: :braintree do
    def perform!
      # ...
      @credit_card.token = response.params['credit_card_token']
    end
  end
end
```

Workarea Braintree also decorates tests to configure the correct gateway and account for gateway API differences.
Refer to the following sources:

* [Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/store_credit_card.rb)
* [Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/store_credit_card_test.rb)
* [Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/store_credit_card.decorator)
* [Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/store_credit_card_test.decorator)


Operation Implementations
----------------------------------------------------------------------

Finally, to finish implementing the credit card tender type, you must [implement each credit card operation](/articles/implementing-payment-tender-types.html#operation-implementations_8) implement each credit card operation: authorize, purchase, capture, and refund.
In each case, decorate the class to customize `#complete!`, `#cancel!`, and `#transaction_options` (authorize and purchase only) to account for differences between the default gateway and your chosen gateway.

For the credit card tender type, the authorize and purchase operations must handle tokenization.
There are two general patterns for this behavior.
The first, as demonstrated in the default implementation, is to tokenize the card in a separate request before authorizing the transaction
([source](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/authorize/credit_card.rb)):

```ruby
def complete!
  return unless StoreCreditCard.new(tender, options).save!

  transaction.response = handle_active_merchant_errors do
    gateway.authorize(
      transaction.amount.cents,
      tender.to_token_or_active_merchant,
      transaction_options
    )
  end
end
```

The alternative, preferred by Braintree and other gateways, is to tokenize and authorize in the same request, in which case you must save the token after a successful authorization
([source](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/authorize/credit_card.decorator)):

```ruby
def complete!
  transaction.response = handle_active_merchant_errors do
    if tender.token.present?
      gateway.authorize(
        transaction.amount.cents,
        tender.token,
        {
          payment_method_token: true,
          order_id: order_id,
          email: email,
          billing_address: billing_address
        }
      )
    else
      gateway.authorize(
        transaction.amount.cents,
        tender.to_active_merchant,
        {
          store: true,
          order_id: order_id,
          email: email,
          billing_address: billing_address
        }
      )
    end
  end

  if transaction.response.success? && tender.token.blank?
    tender.token =
      transaction.response.params["braintree_transaction"]["credit_card_details"]["token"]
    tender.save!
  end
end
```

Here are all the operation implementations from Workarea Core and Workarea Braintree for reference:

Authorize:

* [Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/authorize/credit_card.rb)
* [Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/authorize/credit_card_test.rb)
* [Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/authorize/credit_card.decorator)
* [Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/authorize/credit_card_test.decorator)

Purchase:

* [Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/purchase/credit_card.rb)
* [Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/purchase/credit_card_test.rb)
* [Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/purchase/credit_card.decorator)
* [Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/purchase/credit_card_test.decorator)

Capture:

* [Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/capture/credit_card.rb)
* [Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/capture/credit_card_test.rb)
* [Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/capture/credit_card.decorator)
* [Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/capture/credit_card_test.decorator)

Refund:

* [Workarea Core implementation](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/app/models/workarea/payment/refund/credit_card.rb)
* [Workarea Core test case](https://github.com/workarea-commerce/workarea/blob/v3.4.18/core/test/models/workarea/payment/refund/credit_card_test.rb)
* [Workarea Braintree implementation extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/app/models/workarea/payment/refund/credit_card.decorator)
* [Workarea Braintree test case extensions](https://github.com/workarea-commerce/workarea-braintree/blob/v1.0.3/test/models/workarea/payment/refund/credit_card_test.decorator)
