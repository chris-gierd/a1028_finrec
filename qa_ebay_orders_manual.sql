Select transaction_creation_date
,type
,et.order_number
,pr.order_number
,et.payout_id
,et.transaction_id
,et.item_subtotal
,et.gross_transaction_amount
,et.quantity
,et.item_id
,et.custom_label
FROM `gierd-finrec.a1028_dev.ebay_orders_manual` et
left join `gierd-finrec.a1028_dev.ebay_payout_ 6472238658_orders_recon` pr
on et.order_number = pr.order_number
where 1=1
AND et.payout_id = '6472238658'
AND et.type = 'Order'
AND pr.order_number is null
