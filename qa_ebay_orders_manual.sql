WITH ebay_payout_recon AS(
SELECT transaction_creation_date
,type
,order_number
,payout_id
,transaction_id
,item_subtotal
,gross_transaction_amount
,quantity
,item_id
,custom_label
FROM `gierd-finrec.a1028_dev.ebay_orders_manual`
where 1=1
--AND order_number in ('16-11850-33616','06-11893-70770','03-11858-51388')
AND payout_id = '6472238658'
AND type = 'Order'
)
--Select order_number, custom_label, quantity from ebay_payout_recon

-- select et.order_number, et.custom_label, et.quantity from ebay_payout_recon et 
--   left join `gierd-finrec.a1028_dev.ebay_payout_ 6472238658_orders_recon` pr 
--     on et.order_number = pr.Order_Number 
--       AND et.item_id = pr.sku
--       AND et.quantity = pr.Quantity
--   where pr.partner = 'Gierd'
--   AND pr.order_number is not null


select et.order_number, et.custom_label, et.quantity, pr.sku, pr.partner from ebay_payout_recon et 
  left join `gierd-finrec.a1028_dev.ebay_payout_ 6472238658_orders_recon` pr 
    on et.order_number = pr.Order_Number 
      AND et.custom_label = pr.sku
      AND et.quantity = pr.Quantity
  where 1=1
  AND pr.order_number is null

  Select transaction_creation_date
,type
,order_number
,payout_id
,transaction_id
,item_subtotal
,gross_transaction_amount
,quantity
,item_id
,custom_label
FROM `gierd-finrec.a1028_dev.ebay_orders_manual` et
left join `gierd-finrec.a1028_dev.ebay_payout_ 6472238658_orders_recon` pr
on et.order_number = pr.order_number
