-- Analyse des produits Best Sellers
{{
  config(
    materialized='table'
  )
}}

with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

orders as (
    select 
        order_id,
        order_purchased_at,
        date_trunc('month', order_purchased_at) as order_month
    from {{ ref('stg_orders') }}
    where order_status = 'delivered'
),

product_sales as (
    select
        oi.product_id,
        p.category_name,
        count(distinct oi.order_id) as total_orders,
        sum(oi.price) as total_revenue,
        round(avg(oi.price), 2) as avg_price,
        count(*) as total_units_sold,
        count(distinct date_trunc('month', o.order_purchased_at)) as months_active
    from order_items oi
    join orders o on oi.order_id = o.order_id
    left join products p on oi.product_id = p.product_id
    group by oi.product_id, p.category_name
),

-- Classement des produits
ranked_products as (
    select
        *,
        row_number() over (order by total_revenue desc) as revenue_rank,
        row_number() over (order by total_units_sold desc) as volume_rank,
        round(total_revenue * 100.0 / sum(total_revenue) over(), 2) as revenue_contribution_pct,
        round(sum(total_revenue) over (order by total_revenue desc rows between unbounded preceding and current row) 
              * 100.0 / sum(total_revenue) over(), 2) as cumulative_revenue_pct
    from product_sales
)

select
    product_id,
    category_name,
    total_orders,
    total_units_sold,
    total_revenue,
    avg_price,
    months_active,
    revenue_rank,
    volume_rank,
    revenue_contribution_pct,
    cumulative_revenue_pct,
    
    -- Identifier les produits stratégiques
    case
        when cumulative_revenue_pct <= 20 then 'A - Top 20% Revenue (Focus)'
        when cumulative_revenue_pct <= 50 then 'B - Next 30% Revenue'
        when cumulative_revenue_pct <= 80 then 'C - Next 30% Revenue'
        else 'D - Bottom 20% Revenue (Consider dropping)'
    end as abc_category
    
from ranked_products
order by revenue_rank