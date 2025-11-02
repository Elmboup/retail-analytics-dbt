with source as (
    select * from {{ source('raw_ecommerce', 'customers')}}
),

renamed as (
    select
    -- Identifiants
        customer_id,
        customer_unique_id,
        
        -- Informations geographiques
        customer_zip_code_prefix as zip_code,
        customer_city as city,
        customer_state as state

    from source
)

select * from renamed