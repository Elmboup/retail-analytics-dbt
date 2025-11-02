{{
  config(
    materialized='view'
  )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
    where order_status not in ('cancelled', 'unavailable')
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

order_totals as (
    -- Agréger les items par commande
    select
        order_id,
        sum(price) as order_amount,
        sum(freight_value) as freight_amount,
        sum(total_item_value) as total_amount,
        count(distinct product_id) as items_count,
        count(*) as lines_count
    from order_items
    group by order_id
),

final as (
    select
        -- Infos commande
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchased_at,
        o.order_delivered_at,
        
        -- Montants
        ot.order_amount,
        ot.freight_amount,
        ot.total_amount,
        ot.items_count,
        ot.lines_count,
        
        -- Calculer les délais
        datediff('day', o.order_purchased_at, o.order_delivered_at) as delivery_days,
        
        -- Catégoriser la vitesse de livraison
        case 
            when datediff('day', o.order_purchased_at, o.order_delivered_at) <= 7 then 'Fast'
            when datediff('day', o.order_purchased_at, o.order_delivered_at) <= 14 then 'Normal'
            when datediff('day', o.order_purchased_at, o.order_delivered_at) <= 30 then 'Slow'
            else 'Very Slow'
        end as delivery_speed_category
        
    from orders o
    left join order_totals ot on o.order_id = ot.order_id
)

select * from final