{{
  config(
    materialized='view'
  )
}}

with customers as (
    select * from {{ ref('dim_customers') }}
),

-- Dernière commande de chaque client
last_orders as (
    select 
        customer_id,
        order_id as last_order_id,
        order_purchased_at as last_order_date,
        total_amount as last_order_amount,
        delivery_speed_category as last_delivery_speed
    from {{ ref('fct_sales') }}
    qualify row_number() over (partition by customer_id order by order_purchased_at desc) = 1
)

select
    -- Infos client
    c.customer_unique_id,
    c.city,
    c.state,
    
    -- Segmentation
    c.customer_segment,
    c.customer_status,
    
    -- Métriques globales
    c.total_orders,
    c.lifetime_value,
    c.avg_order_value,
    c.total_items_purchased,
    
    -- Historique temporel
    c.first_order_at,
    c.last_order_at,
    c.customer_lifetime_days,
    c.days_since_last_order,
    
    -- Dernière commande
    lo.last_order_id,
    lo.last_order_date,
    lo.last_order_amount,
    lo.last_delivery_speed,
    
    -- Flags actionnables
    case 
        when c.customer_status = 'At Risk' and c.lifetime_value > 500 
        then true else false 
    end as needs_reactivation_campaign,
    
    case 
        when c.customer_segment = 'VIP' 
        then true else false 
    end as eligible_for_vip_program

from customers c
left join last_orders lo on c.customer_id = lo.customer_id