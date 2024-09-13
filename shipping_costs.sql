-Worked through logic

  ------
    --[Pass 3] Update shipping actuals
    ------

  --Fedex roll-up total shipping cost on master tracking for multi-item orders
  CREATE OR REPLACE TEMP TABLE fedex_charge_details AS
    Select CASE WHEN TDMasterTrackingID IS NULL then Express_or_Ground_Tracking_ID
                ELSE TDMasterTrackingID
                END AS tracking_master
    ,count(Express_or_Ground_Tracking_ID) AS cnt_pkg
    ,sum(Net_Charge_Amount) ship_cost_total_order
    from `client-datawarehouse.a1028_raw.fedex_data` 
    group by CASE WHEN TDMasterTrackingID IS NULL then Express_or_Ground_Tracking_ID
                ELSE TDMasterTrackingID
                END;

  --Join total back to orders and divide by order-items
  UPDATE sales_report sr
  SET ship_and_handle_net = f.ship_and_handle_net
  FROM (SELECT (s.ship_cost_total_order / o.order_quantity) ship_and_handle_net, t.order_id, t.sku FROM `client-datawarehouse.a1028_mart.v_linn_orders_current` t
          left join fedex_charge_details s
            on t.tracking_number = s.tracking_master
          left join sales_report r 
            on t.order_id = r.order_id
            and t.sku = r.sku
          inner join (
            SELECT order_id, sum(quantity) order_quantity, count(order_id) order_lines
            FROM `client-datawarehouse.a1028_mart.v_linn_orders_current`
            group by order_id
          ) o on o.order_id = t.order_id
        WHERE 1=1
            and t.received_date_pst >= var_reporting_date_start) f
  Where sr.order_id = f.order_id
  AND sr.sku = f.sku;

  --Detail columns for validation
WITH tracking_matches as(
  select t.order_id
  ,t.reference_number
  ,r.marketplace
  ,t.tracking_number
  ,t.received_date_pst
  ,s.tracking_master
  ,t.received_date_pst
  ,t.Processed_date_pst
  --,s.Shipment_Date
  ,s.ship_cost_total_order
  ,s.cnt_pkg
  ,o.order_lines
  ,t.Quantity
  ,o.order_quantity
  ,(s.ship_cost_total_order / o.order_quantity) as unit_ship_order_average
  ,r.ship_and_handle_gross
  ,t.item_title
  ,t.sku
  FROM `client-datawarehouse.a1028_mart.v_linn_orders_current` t
    left join fedex_charge_details s
      on t.tracking_number = s.tracking_master
    left join sales_report r 
        on t.order_id = r.order_id
        and t.sku = r.sku
    inner join (
      SELECT order_id, sum(quantity) order_quantity, count(order_id) order_lines
      FROM `client-datawarehouse.a1028_mart.v_linn_orders_current`
      group by order_id
    ) o on o.order_id = t.order_id
  WHERE 1=1
      and t.received_date_pst >= var_reporting_date_start 
      --and t.Processed_date_pst <= '2024-08-30'
  )  
  
Select order_id, tracking_number, sum(unit_ship_order_average * quantity), count(*) from tracking_matches where tracking_number <> ''
group by order_id, tracking_number
having count(order_id) > 1;

Select Shipment_Date, Net_Charge_Amount, Express_or_Ground_Tracking_ID from `client-datawarehouse.a1028_raw.fedex_data` 
where TDMasterTrackingID = '277796128372';

-------------------------------------------------------------------------

--Size up dates we are trying to cover
Select min(order_date), max(order_date) from gierd-finrec.a1028_dev.sales_report;

Select Shipment_Date, count(net_charge_amount) AS shipments, sum(Net_Charge_Amount), Invoice_Number, Invoice_Date
FROM `client-datawarehouse.a1028_raw.fedex_data` 
where Shipment_Date >= '2024-08-01'
group by Shipment_Date, invoice_number, Invoice_Date
order by shipment_date asc;

select t.order_id
,t.reference_number
,r.marketplace
,t.tracking_number
,t.received_date_pst
,s.Express_or_Ground_Tracking_ID
,t.Processed_date_pst
,s.Shipment_Date
,s.Net_Charge_Amount
,o.tracking_quantity
,(s.Net_Charge_Amount / o.tracking_quantity) as item_net_ship
,r.ship_and_handle_gross
,t.item_title
,t.sku
FROM `client-datawarehouse.a1028_mart.v_linn_orders_current` t
  left join `client-datawarehouse.a1028_raw.fedex_data` s
    on t.tracking_number = s.Express_or_Ground_Tracking_ID
  left join `gierd-finrec.a1028_dev.sales_report` r on t.order_id = r.order_id
  inner join (
    SELECT order_id, tracking_number, sum(quantity) tracking_quantity
    FROM `client-datawarehouse.a1028_mart.v_linn_orders_current`
    where tracking_number is not null
    group by order_id, tracking_number 
  ) o on o.order_id = t.order_id
WHERE 1=1
    and t.Processed_date_pst >= '2024-08-01' 
    and t.Processed_date_pst <= '2024-08-30'
    and s.Express_or_Ground_Tracking_ID is not null
    --and o.tracking_quantity = 1
    and o.tracking_quantity > 1;
--3090 shipped order-lines in this time period
--1605 hits on tracking number

--Select * from `client-datawarehouse.a1028_mart.v_linn_orders_current` where order_id = '101955';

--GET order-grain quantity by tracking number
-- SELECT order_id, tracking_number, sum(quantity)
-- FROM `client-datawarehouse.a1028_mart.v_linn_orders_current`
-- where tracking_number is not null
-- group by order_id, tracking_number

  Select Shipment_Date, count(net_charge_amount) AS shipments, sum(Net_Charge_Amount), Invoice_Number, Invoice_Date
  FROM `client-datawarehouse.a1028_raw.fedex_data` 
  where Shipment_Date >= '2024-08-01'
  group by Shipment_Date, invoice_number, Invoice_Date
  order by shipment_date asc;

--Approximate number of packages shipped related to LW orders
Select sc.tracking_master
,sc.cnt_pkg
,sc.ship_cost_total_order
,sc.ship_cost_max_pkg
,s.Express_or_Ground_Tracking_ID tracking_max_pkg_cost
FROM
  (
  Select CASE WHEN TDMasterTrackingID IS NULL then Express_or_Ground_Tracking_ID
              ELSE TDMasterTrackingID
              END AS tracking_master
  ,count(Express_or_Ground_Tracking_ID) AS cnt_pkg
  ,sum(Net_Charge_Amount) ship_cost_total_order
  ,max(Net_Charge_Amount) ship_cost_max_pkg
  from `client-datawarehouse.a1028_raw.fedex_data` 
  group by tracking_master
  ) sc left join `client-datawarehouse.a1028_raw.fedex_data` s 
      on sc.tracking_master = s.TDMasterTrackingID
      AND sc.ship_cost_max_pkg = s.Net_Charge_Amount
