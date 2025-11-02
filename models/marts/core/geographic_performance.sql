{{
  config(
    materialized='view'
  )
}}

with sales as (
    select * from {{ ref('fct_sales') }}
),

state_performance as (
    select
        customer_state,
        count(distinct customer_id) as total_customers,
        count(distinct order_id) as total_orders,
        round(sum(total_amount), 2) as total_revenue,
        round(avg(total_amount), 2) as avg_order_value,
        round(avg(delivery_days), 1) as avg_delivery_days,
        
        -- Calculs de parts de marché
        round(sum(total_amount) * 100.0 / sum(sum(total_amount)) over(), 2) as revenue_market_share,
        
        -- Efficacité logistique
        round(sum(case when delivery_speed_category = 'Fast' then 1 else 0 end) * 100.0 / count(*), 2) as fast_delivery_rate
        
    from sales
    group by customer_state
)

select
    customer_state,
    total_customers,
    total_orders,
    total_revenue,
    avg_order_value,
    avg_delivery_days,
    revenue_market_share,
    fast_delivery_rate,
    
    -- Classement
    row_number() over (order by total_revenue desc) as revenue_rank,
    
    -- Identifier les états stratégiques
    case
        when revenue_market_share >= 10 then 'Strategic Market'
        when revenue_market_share >= 5 then 'Important Market'
        when revenue_market_share >= 2 then 'Growth Market'
        else 'Emerging Market'
    end as market_importance
    
from state_performance
order by total_revenue desc