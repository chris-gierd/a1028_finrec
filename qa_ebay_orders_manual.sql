SELECT * FROM `gierd-finrec.a1028_dev.ebay_orders_manual` LIMIT 10

SELECT distinct type from `gierd-finrec.a1028_dev.ebay_orders_manual`

batch_id
creation_date
batch_filename
transaction_creation_date
type
order_number
legacy_order_id
buyer_username
buyer_name
ship_to_city
ship_to_province_region_state
ship_to_zip
ship_to_country
net_amount
payout_currency
payout_date
payout_id
payout_method
payout_status
reason_for_hold
item_id
transaction_id
item_title
custom_label
quantity
item_subtotal
shipping_and_handling
seller_collected_tax
ebay_collected_tax
final_value_fee_fixed
final_value_fee_variable
regulatory_operating_fee
very_high_item_not_as_described_fee
below_standard_performance_fee
international_fee
charity_donation
deposit_processing_fee
gross_transaction_amount
transaction_currency
exchange_rate
reference_id
description

WITH ebay_payout_recon AS(
SELECT transaction_creation_date
,type
,order_number
,payout_id
,transaction_id
,gross_transaction_amount
,quantity
FROM `gierd-finrec.a1028_dev.ebay_orders_manual`
where 1=1
AND payout_id = '6472238658'
AND type = 'Order'
)
Select payout_id, sum(quantity), sum(item_subtotal), sum(gross_transaction_amount) from ebay_payout_recon
group by payout_id
