---
title: Implement a Primary Tender Type
excerpt: TODO
created_at: 2019/10/25
---

Implement a Primary Tender Type
======================================================================

[Primary payment tender types](/articles/payment-tender-types.html#primary-tender-types_3) are [payment tender types](/articles/payment-tender-types.html).
Base includes the credit card tender type, but you can add additional primary tender types, which shoppers can pay with instead of credit card.

Here's a procedure to implement one:

1. [Implement gateways](#gateways_1)
2. [Add tender type definition](#tender-type-definition_2)
3. [Integrate with Payment](#payment-integration_3)
4. [Implement each payment operation](#operation-implementations_4)
5. [Integrate into Storefront](#storefront-integration_5)
6. [Integrate into Admin](#admin-integration_6)

The examples use _Workarea PayPal_ v2.0.8 (
[gem](https://rubygems.org/gems/workarea-paypal/versions/2.0.8),
[docs](https://www.rubydoc.info/gems/workarea-paypal/2.0.8),
[source](https://github.com/workarea-commerce/workarea-paypal/tree/v2.0.8)
).


Gateways
----------------------------------------------------------------------

Code that needs to access a [gateway](/articles/implementing-payment-tender-types.html#gateways_1) (e.g. operation implementations), delegates `#gateway` to
[`Workarea::Paypal.gateway`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/lib/workarea/paypal.rb#L7-L9).

This looks up the gateway in configuration, which is [autoconfigured](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/lib/workarea/paypal.rb#L11-L29) from an 
[initializer](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/workarea.rb#L7).

So when no credentials are present, you're using an instance of [`ActiveMerchant::Billing::BogusGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/BogusGateway), which is a good manual testing gateway.

[Commerce cloud proxy](/articles/implementing-payment-tender-types.html#commerce-cloud-proxy_4)

```yaml
# config/secrets.yml
development:
  secret_key_base: 836fa3
test:
  secret_key_base: 5a3781
  paypal:
    login: sandbox_login
    password: sandbox_password
production:
  secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
  paypal:
    login: production_login
    password: production_password
```

```shell
$ RAILS_ENV=development bin/rails r "puts Rails.application.secrets.paypal.presence || '(blank)'"
(blank)

$ RAILS_ENV=test bin/rails r "puts Rails.application.secrets.paypal.presence || '(blank)'"
{:login=>"sandbox_login", :password=>"sandbox_password"}

$ RAILS_ENV=production bin/rails r "puts Rails.application.secrets.paypal.presence || '(blank)'"
{:login=>"production_login", :password=>"production_password"}
```

[`Rails::Application#secrets`](https://api.rubyonrails.org/v5.2/classes/Rails/Application.html#method-i-secrets)

Seems like PayPal tests use stubs and don't talk to the real endpoint.

[`ActiveMerchant::Billing::PaypalExpressGateway`](https://www.rubydoc.info/gems/activemerchant/1.99.0/ActiveMerchant/Billing/PaypalExpressGateway)

[`Storefront::PaypalIntengrationTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/integration/workarea/storefront/paypal_integration_test.rb)


Tender Type Definition
----------------------------------------------------------------------

[Tender Type Definition](/articles/implementing-payment-tender-types.html#tender-type-definition_6)

[`Payment::Tender::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/tender/paypal.rb)


Payment Integration
----------------------------------------------------------------------

[Payment Integration](/articles/implementing-payment-tender-types.html#payment-integration_7)

[`Payment` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment.decorator)

[`PaymentTest` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/models/workarea/payment_test.decorator)

[Tender types configuration](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/workarea.rb#L1)


Operation Implementations
----------------------------------------------------------------------

[Operation Implementations](/articles/implementing-payment-tender-types.html#operation-implementations_8)

[`Payment::Authorize::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/authorize/paypal.rb)

[`Payment::Authorize::PaypalTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/models/workarea/payment/authorize/paypal_test.rb)

[`Payment::Purchase::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/purchase/paypal.rb)

[`Payment::Purchase::PaypalTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/models/workarea/payment/purchase/paypal_test.rb)

[`Payment::Capture::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/capture/paypal.rb)

[`Payment::Capture::PaypalTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/models/workarea/payment/capture/paypal_test.rb)

[`Payment::Refund::Paypal`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/payment/refund/paypal.rb)

[`Payment::Refund::PaypalTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/models/workarea/payment/refund/paypal_test.rb)


Storefront Integration
----------------------------------------------------------------------

[Storefront Integration](/articles/implementing-payment-tender-types.html#storefront-integration_9)

[`Storefront::Checkout::PlaceOrderController` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/controllers/workarea/storefront/checkout/place_order_controller.decorator)

[Storefront routes](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/routes.rb)

[`Storefront::PaypalController`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/controllers/workarea/storefront/paypal_controller.rb)

[`Paypal::Setup`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/services/workarea/paypal/setup.rb)

[`Paypal::SetupTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/services/workarea/paypal/setup_test.rb)

[`Paypal::Update`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/services/workarea/paypal/update.rb)

[`Paypal::UpdateTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/services/workarea/paypal/update_test.rb)


[`Storefront::Checkout::PaymentViewModel` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/view_models/workarea/store_front/checkout/payment_view_model.decorator)

[`Storefront::CreditCardViewModel` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/view_models/workarea/store_front/credit_card_view_model.decorator)

[`Storefront::PaypalViewModel`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/view_models/workarea/store_front/paypal_view_model.rb)


[Storefront checkouts payment partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/checkouts/_paypal_payment.html.haml)

[Configuration for Storefront checkouts payment partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/append_points.rb#L11-L14)

[Storefront checkouts error partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/checkouts/_paypal_error.html.haml)

[Configuration for Storefront checkouts error partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/append_points.rb#L6-L9)

[Storefront orders tenders partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/orders/tenders/_paypal.html.haml)

[Storefront API orders tenders partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/api/orders/tenders/_paypal.json.jbuilder)

[Storefront order mailer tenders partial (HTML)](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/order_mailer/tenders/_paypal.html.haml)

[Storefront order mailer tenders partail (text)](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/order_mailer/tenders/_paypal.text.haml)

[Storefront carts partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/storefront/carts/_paypal_checkout.html.haml)

[Configuration for Storefront carts payment partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/append_points.rb#L1-L4)


[`WORKAREA.updateCheckoutSubmitText`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/assets/javascripts/workarea/storefront/paypal/modules/update_checkout_submit_text.js)

[Configuration for `WORKAREA.updateCheckoutSubmitText`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/initializers/append_points.rb#L16-L19)

[PayPal SVG icon](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/assets/images/workarea/storefront/payment_icons/paypal.svg)


[Storefront translations](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/locales/en.yml#L9-L19)


[`Storefront::PlaceOrderIntegrationTest` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/integration/workarea/storefront/place_order_integration_test.decorator)

[`Storefront::PaypalIntengrationTest`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/integration/workarea/storefront/paypal_integration_test.rb)

[`Storefront::CartSystemTest` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/system/workarea/storefront/cart_system_test.decorator)

[`Storefront::LoggedInCheckoutSystemTest` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/system/workarea/storefront/logged_in_checkout_system_test.decorator)


Admin Integration
----------------------------------------------------------------------

[Admin Integration](/articles/implementing-payment-tender-types.html#admin-integration_10)

[`Search::OrderText` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/models/workarea/search/order_text.decorator)

[`Admin::PaypalViewModel`](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/view_models/workarea/admin/paypal_view_model.rb)

[Admin orders tenders partial](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/views/workarea/admin/orders/tenders/_paypal.html.haml)

[PayPal SVG icon](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/app/assets/images/workarea/admin/payment_icons/paypal.svg)

[Admin translations](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/config/locales/en.yml#L4-L8)

[`Search::Admin::OrderTest` decorator](https://github.com/workarea-commerce/workarea-paypal/blob/v2.0.8/test/models/workarea/search/admin/order_test.decorator)
