{{
  config(
    materialized='incremental',
    unique_key='order_id',
    on_schema_change='fail'
  )
}}

with customer_orders as (
    select * from {{ ref('int_customer_orders') }}
    
    {% if is_incremental() %}
    -- En mode incrémental, charger seulement les nouvelles commandes
    where order_purchased_at > (select max(order_purchased_at) from {{ this }})
    {% endif %}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

final as (
    select
        -- IDs
        co.order_id,
        co.customer_id,
        c.customer_unique_id,
        
        -- Géographie client
        c.city as customer_city,
        c.state as customer_state,
        c.zip_code as customer_zip_code,
        
        -- Dates
        co.order_purchased_at,
        co.order_delivered_at,
        date_trunc('month', co.order_purchased_at) as order_month,
        date_trunc('year', co.order_purchased_at) as order_year,
        
        -- Statut
        co.order_status,
        
        -- Métriques financières
        co.order_amount,
        co.freight_amount,
        co.total_amount,
        
        -- Métriques produits
        co.items_count,
        co.lines_count,
        
        -- Métriques logistiques
        co.delivery_days,
        co.delivery_speed_category,
        
        -- Flags business
        case when co.items_count > 1 then true else false end as is_multi_item_order,
        case when co.total_amount > 200 then true else false end as is_high_value_order
        
    from customer_orders co
    left join customers c on co.customer_id = c.customer_id
)

select * from final