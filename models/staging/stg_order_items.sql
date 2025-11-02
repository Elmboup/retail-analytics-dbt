with source as (
    -- Référencer la source qu'on a déclarée
    select * from {{ source('raw_ecommerce', 'order_items') }}
),
renamed as (
    select
        -- Identifiants
        order_id,
        order_item_id,
        product_id,
        seller_id,

        --Dates
        to_timestamp_ntz(shipping_limit_date) as shipping_limit_at,

        -- Montants financiers
        price,
        freight_value,

        --calcul montant total de la ligne
        (price + freight_value) as total_item_value
        
    from source
)

select * from renamed