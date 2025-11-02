with source as (
    -- Référencer la source qu'on a déclarée
    select * from {{ source('raw_ecommerce', 'orders') }}
),

renamed as (
    select
        -- Renommer et typer proprement
        order_id,
        customer_id,
        order_status,
        
        -- Convertir les timestamps en bon format
        to_timestamp_ntz(order_purchase_timestamp) as order_purchased_at,
        to_timestamp_ntz(order_approved_at) as order_approved_at,
        to_timestamp_ntz(order_delivered_carrier_date) as order_delivered_carrier_at,
        to_timestamp_ntz(order_delivered_customer_date) as order_delivered_at,
        to_timestamp_ntz(order_estimated_delivery_date) as order_estimated_delivery_at
        
    from source
)

select * from renamed