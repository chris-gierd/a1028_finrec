Select * from `gierd-finrec.a1028_dev.Acer_47_columns`

order_date
date_shipped
marketplace_id
order_id
acer_edi_po_number
marketplace
customer_type
bill_to
part_number
sku
model
condition
quantity
sold_each
marketplace_and_money_trans
ship_and_handle_gross
ship_and_handle_net
rebate
subsidy
marketing
warranty
returns
total_external_fees
purchase_amount_less_fees
success_fee
category
subcategory
per_unit_marketplace_fee
per_unit_gierd_cs_fee
net_acer_unit
net_no_taxes
taxes
edi_tax_submitted
net_plus_taxes
average_gross_price
low_channel_price
high_channel_price
shipping_method
tracking_number
warehouse
adjustment_amount
adjustment_reason
order_source

--CREATE OR REPLACE TEMP TABLE qty_weighted_skus 
Select sku
,count(order_id)
,sum(quantity * sold_each) / sum(quantity) average_gross_price
,min(sold_each) low_channel_price
,max(sold_each) high_channel_price
FROM `gierd-finrec.a1028_dev.Acer_47_columns`
where 1=1
AND sku = 'UM.HS2AA.E02_FGI-EU'
AND sold_each > 0
--AND quantity > 1
group by sku


Select * from `gierd-finrec.a1028_dev.Acer_47_columns` where sku = 'DG.E2XAA.007_FGI-EU'

--AVG 713.31999999999982
--LO 699.99
--HI 719.99

Select * from `gierd-finrec.a1028_dev.Acer_47_columns` where sku = 'NX.A6WAA.00H_FGI-EU'
--AVG 153.80999999999997
--LO 179.99
--HI 190.79

Select * from `gierd-finrec.a1028_dev.Acer_47_columns` 
where 1=1 
AND sku = 'UM.HS2AA.E02_FGI-EU'
AND sold_each > 0
--AVG 87.8135294117647
--LO 69.99
--HI 96.29

-------------------------------------------------------------
Select sku
,count(order_id)
,sum(quantity * sold_each) / sum(quantity) average_gross_price
,min(sold_each) low_channel_price
,max(sold_each) high_channel_price
FROM `gierd-finrec.a1028_dev.Acer_47_columns`
where 1=1
AND sku = 'UM.HS2AA.E02_FGI-EU'
AND sold_each > 0
--AND quantity > 1
group by sku
