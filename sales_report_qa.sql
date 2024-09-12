--Check which orders aren't getting a unit_cost or 

  Select t.order_id
  ,t.marketlace_id 
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
    --where lo.sku is null
