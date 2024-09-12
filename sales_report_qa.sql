--Check which orders aren't getting a unit_cost or 

--interrogate matches vs non-matches
  Select t.order_id
  ,t.marketplace_id
  ,t.order_date 
  ,t.sku
  ,t.quantity
  ,lo.Line_total_excluding_tax
  ,lo.Unit_cost
  ,lo.SKU
  ,lo.Channel_SKU
  from sales_report t
    left join `client-datawarehouse.a1028_mart.v_linn_orders_current` lo 
      on t.sku = lo.SKU
      AND t.marketplace_id = lo.reference_number
      AND t. quantity = lo.quantity 
    --4804 total order-skus
    where lo.sku is null


--create a temp table w/records to fuzzy-match
CREATE OR REPLACE TEMP TABLE missing_edi_submitted_amount_l1 AS
    Select t.order_id
    ,t.marketplace_id
    ,t.order_date 
    ,t.sku
    ,t.quantity
    from sales_report t
      left join `client-datawarehouse.a1028_mart.v_linn_orders_current` lo 
        on t.sku = lo.SKU
        AND t.marketplace_id = lo.reference_number
        AND t. quantity = lo.quantity
      where 1=1
      and lo.sku is null
      and t.order_id is not null;

    --Fuzzy match order_id + simplified SKU
    Select m.order_id
    ,m.marketplace_id
    ,left(m.sku, 12) as genSku
    ,m.sku
    ,lo.sku
    ,m.order_date
    ,lo.received_date_pst
    from  missing_edi_submitted_amount_l1 m left join `client-datawarehouse.a1028_mart.v_linn_orders_current` lo 
      on 1=1
        AND m.marketplace_id = lo.reference_number
        --AND m.order_date = lo.received_date_pst 
        AND left(m.sku, 12) = left(lo.sku, 12)
