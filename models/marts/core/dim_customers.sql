{{
  config(
    materialized='table'
  )
}}

with customers as (
    select * from {{ ref('stg_customers') }}
),

customer_orders as (
    select * from {{ ref('int_customer_orders') }}
),

customer_metrics as (
    select
        customer_id,
        
        -- Métriques de commande
        count(distinct order_id) as total_orders,
        sum(total_amount) as lifetime_value,
        avg(total_amount) as avg_order_value,
        sum(items_count) as total_items_purchased,
        
        -- Dates importantes
        min(order_purchased_at) as first_order_at,
        max(order_purchased_at) as last_order_at,
        
        -- Calculs temporels
        datediff('day', min(order_purchased_at), max(order_purchased_at)) as customer_lifetime_days,
        datediff('day', max(order_purchased_at), current_date()) as days_since_last_order,
        
        -- Métriques moyennes
        avg(delivery_days) as avg_delivery_days
        
    from customer_orders
    group by customer_id
),

-- Calculer les dates min/max du dataset pour segmentation relative
dataset_boundaries as (
    select
        min(order_purchased_at) as dataset_start,
        max(order_purchased_at) as dataset_end,
        datediff('day', min(order_purchased_at), max(order_purchased_at)) as dataset_duration_days
    from customer_orders
),

customer_segmentation as (
    select
        cm.*,
        db.dataset_end,
        
        -- Calculer la récence RELATIVE
        datediff('day', cm.last_order_at, db.dataset_end) as days_since_last_order_relative,
        
        -- Segmentation AJUSTÉE à la réalité du dataset
        case 
            when cm.total_orders >= 3 AND cm.lifetime_value >= 1000 then 'VIP'
            when cm.total_orders >= 3 then 'Super Loyal'
            when cm.total_orders = 2 AND cm.lifetime_value >= 500 then 'High Value Repeat'
            when cm.total_orders = 2 then 'Repeat'
            when cm.total_orders = 1 AND cm.lifetime_value >= 300 then 'High Value One-time'
            else 'One-time'
        end as customer_segment,
        
        -- Segmentation par récence (seulement pour les repeat customers)
        case
            when cm.total_orders = 1 then 'One-time Buyer'
            when datediff('day', cm.last_order_at, db.dataset_end) <= 90 then 'Active'
            when datediff('day', cm.last_order_at, db.dataset_end) <= 180 then 'Cooling'
            when datediff('day', cm.last_order_at, db.dataset_end) <= 365 then 'At Risk'
            else 'Lost'
        end as customer_status
        
    from customer_metrics cm
    cross join dataset_boundaries db
),

final as (
    select
        -- Infos client
        c.customer_id,
        c.customer_unique_id,
        c.city,
        c.state,
        c.zip_code,
        
        -- Métriques
        coalesce(cs.total_orders, 0) as total_orders,
        coalesce(cs.lifetime_value, 0) as lifetime_value,
        coalesce(cs.avg_order_value, 0) as avg_order_value,
        coalesce(cs.total_items_purchased, 0) as total_items_purchased,
        
        -- Dates
        cs.first_order_at,
        cs.last_order_at,
        cs.customer_lifetime_days,
        cs.days_since_last_order,
        
        -- Métriques qualité
        cs.avg_delivery_days,
        
        -- Segments
        coalesce(cs.customer_segment, 'One-time') as customer_segment,
        coalesce(cs.customer_status, 'New') as customer_status
        
    from customers c
    left join customer_segmentation cs on c.customer_id = cs.customer_id
)

select * from final