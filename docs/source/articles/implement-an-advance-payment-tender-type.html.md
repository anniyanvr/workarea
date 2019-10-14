---
title: Implement an Advance Payment Tender Type
excerpt: TODO
created_at: 2019/10/25
---

Implement an Advance Payment Tender Type
======================================================================

[Advance payment tender types](/articles/payment-tender-types.html#advance-payment-tender-types_4) are [payment tender types](/articles/payment-tender-types.html).
Base includes store credit.
But you can also implement your own.

Here is a procedure to do so:

1. [Implement gateways](#gateways_1)
2. [Add tender type definition](#tender-type-definition_2)
3. [Integrate with Payment](#payment-integration_3)
4. [Implement each payment operation](#operation-implementations_4)
5. [Integrate into Storefront](#storefront-integration_5)
6. [Integrate into Admin](#admin-integration_6)

This doc uses examples from _Workarea Gift Cards_ <del>v3.5.0</del> master branch (
[<del>gem</del>](https://rubygems.org/gems/workarea-gift_cards/versions/3.5.0),
[<del>docs</del>](https://www.rubydoc.info/gems/workarea-gift_cards/3.5.0),
[source](https://github.com/workarea-commerce/workarea-gift-cards/tree/master)
).


Gateways
----------------------------------------------------------------------

[Gateways](/articles/implementing-payment-tender-types.html#gateways_1)

[`Payment::Authorize::GiftCard` including `Payment::GiftCardOperation`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/authorize/gift_card.rb#L6)

[`Payment::GiftCardOperation`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/gift_card_operation.rb)

[`Payment::GiftCardOperation#gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/gift_card_operation.rb#L4-L6)

[`GiftCards.gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards.rb#L7-L9)

[Gateway configuration](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/configuration.rb#L10)

[`GiftCards::Gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb)

[`GiftCards::GatewayTest#gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/lib/workarea/gift_cards/gateway_test.rb#L19-L21)

[`GiftCards::Gateway`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb)

[proxy](/articles/implementing-payment-tender-types.html#commerce-cloud-proxy_4)


Tender Type Definition
----------------------------------------------------------------------

[Tender Type Definition](/articles/implementing-payment-tender-types.html#tender-type-definition_6)

[`Payment::Tender::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/tender/gift_card.rb)

[`Payment::Tender::GiftCard#amount=`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/tender/gift_card.rb#L14-L17)


Payment Integration
----------------------------------------------------------------------

[Payment Integration](/articles/implementing-payment-tender-types.html#payment-integration_7)

[`Payment` decorator](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment.decorator)

[tender types configuration](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/configuration.rb#L6)

[`GiftCardPaymentTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/models/workarea/gift_card_payment_test.rb)


Operation Implementations
----------------------------------------------------------------------

[Operation Implementations](/articles/implementing-payment-tender-types.html#operation-implementations_8)

[`Payment::Authorize::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/authorize/gift_card.rb)

[`GiftCards::Gateway#authorize`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb#L19-L28)

[`Payment::Capture::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/capture/gift_card.rb)

[`GiftCards::Gateway#capture`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb#L41-L51)

[`Payment::Purchase::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/purchase/gift_card.rb)

[`GiftCards::Gateway#purchase`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb#L53-L74)

[`Payment::Purchase::GiftCardTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/models/workarea/payment/purchase/gift_card_test.rb)

[`Payment::RefundGiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/payment/refund/gift_card.rb)

[`GiftCards::Gateway#refund`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/gateway.rb#L76-L95)

[`Payment::Refund::GiftCardTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/models/workarea/payment/refund/gift_card_test.rb)


Storefront Integration
----------------------------------------------------------------------

[Storefront Integration](/articles/implementing-payment-tender-types.html#storefront-integration_9)

[Checkout steps configuration](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/configuration.rb#L5)

[Storefront SVG icon](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/assets/images/workarea/storefront/payment_icons/gift_card.svg)

[`Api::Storefront::CheckoutsController` decorator](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/controllers/workarea/api/storefront/checkouts_controller.decorator)

[`Storefront::Checkout::GiftCardsController`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/controllers/workarea/storefront/checkout/gift_cards_controller.rb)

[`Checkout::Steps::GiftCard`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/models/workarea/checkout/steps/gift_card.rb)

[`Storefront::GiftCardOrderPricing`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/view_models/workarea/storefront/gift_card_order_pricing.rb)

[`Storefront::GiftCardOrderPricing` including](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/lib/workarea/gift_cards/engine.rb#L7-L16)

[`Storefront::OrderViewModel` decorator](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/view_models/workarea/storefront/order_view_model.decorator)

[Storefront API checkout steps partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/api/storefront/checkouts/steps/_gift_card.json.jbuilder)

[Storefront API order tenders partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/api/storefront/orders/tenders/_gift_card.json.jbuilder)

[Storefront checkouts error partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/checkouts/_gift_card_error.html.haml)

[Configuration for Storefront checkouts error partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/append_points.rb#L10-L13)

[Storefront checkouts payment partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/checkouts/_gift_card_payment.html.haml)

[Configuration for Storefront checkouts payment partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/append_points.rb#L15-L18)

[Storefront checkouts summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/checkouts/_gift_card_summary.html.haml)

[Configuration for Storefront checkouts summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/append_points.rb#L5-L8)

[Storefront order mailer summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/order_mailer/_gift_card_summary.html.haml)

[Configuration for Storefront order mailer summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/append_points.rb#L25-L28)

[Storefront order mailer tenders partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/order_mailer/tenders/_gift_card.html.haml)

[Storefront orders summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/orders/_gift_card_summary.html.haml)

[Configuration for Storefront orders summary partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/initializers/append_points.rb#L20-L23)

[Storefront orders tenders partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/storefront/orders/tenders/_gift_card.html.haml)

[Core and Storefront translations](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/locales/en.yml#L50-L92)

[Storefront routes](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/routes.rb#L9-L19)

[Storefront API routes](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/routes.rb#L28-L37)

[`Api::Storefront::GiftCardsDocumentationTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/documentation/workarea/api/storefront/gift_cards_documentation_test.rb)

[`Api::Storefront::CheckoutGiftCardsIntegrationTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/integration/workarea/api/storefront/checkout_gift_cards_integration_test.rb)

[`Storefront::CheckoutGiftCardsIntegrationTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/integration/workarea/storefront/checkout_gift_cards_integration_test.rb)

[`Checkout::Steps::GiftCardTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/models/workarea/checkout/steps/gift_card_test.rb)

[`Storefront::GiftCardSystemTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/system/workarea/storefront/gift_cards_system_test.rb)

[`Storefront::GiftCardOrderPricingTest`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/test/view_models/workarea/storefront/gift_card_order_pricing_test.rb)


Admin Integration
----------------------------------------------------------------------

[Admin Integration](/articles/implementing-payment-tender-types.html#admin-integration_10)

[Admin SVG icon](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/assets/images/workarea/admin/payment_icons/gift_card.svg)

[`Admin::PaymentGiftCardViewModel`](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/view_models/workarea/admin/payment_gift_card_view_model.rb)

[Admin orders tenders partial](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/app/views/workarea/admin/orders/tenders/_gift_card.html.haml)

[Admin and Core translations](https://github.com/workarea-commerce/workarea-gift-cards/blob/master/config/locales/en.yml#L3-L57)
