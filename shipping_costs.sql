--Size up dates we are trying to cover
Select min(order_date), max(order_date) from gierd-finrec.a1028_dev.sales_report;

Select Shipment_Date, sum(Net_Charge_Amount), Invoice_Number, Invoice_Date
FROM `client-datawarehouse.a1028_raw.fedex_data` 
where Shipment_Date >= '2024-08-01';

select t.order_id
,t.reference_number
,t.tracking_number
,t.received_date_pst
,s.Express_or_Ground_Tracking_ID
,t.Processed_date_pst
,s.Shipment_Date
,s.Net_Charge_Amount
FROM `client-datawarehouse.a1028_mart.v_linn_orders_current` t
  left join `client-datawarehouse.a1028_raw.fedex_data` s
    on t.tracking_number = s.Express_or_Ground_Tracking_ID;
  

