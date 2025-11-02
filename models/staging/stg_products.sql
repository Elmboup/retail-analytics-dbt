with source as (
    -- Référencer la source qu'on a déclarée
    select * from {{ source('raw_ecommerce', 'products') }}
),
renamed as (
    select
        -- Identifiants
        product_id,

        -- Catégories (en portugais dans la source)
        product_category_name as category_name,

        -- Dimensions physiques
        product_name_lenght as name_length,
        product_description_lenght as description_length,
        product_photos_qty,
        
        -- Poids et dimensions (pour calculer les frais de port)
        product_weight_g as weight_grams,
        product_length_cm as length_cm,
        product_height_cm as height_cm,
        product_width_cm as width_cm,

        -- Calcul volume(utile pour l'optimisation logistique)
        (product_length_cm * product_height_cm * product_width_cm) as volume_cubic_cm3

    from source
)
select * from renamed