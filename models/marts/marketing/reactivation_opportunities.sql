-- Vue Marketing - Opportunités de Réactivation

{{
  config(
    materialized='view'
  )
}}

with customer_360 as (
    select * from {{ ref('customer_360') }}
),

-- Clients High Value à réactiver
high_value_reactivation as (
    select
        customer_unique_id,
        city,
        state,
        customer_segment,
        lifetime_value,
        last_order_at,
        days_since_last_order,
        'High Value Reactivation' as campaign_type,
        1 as priority_score
    from customer_360
    where customer_segment = 'High Value One-time'
      and days_since_last_order between 30 and 180
),

-- Clients VIP/Loyal à risque
churn_prevention as (
    select
        customer_unique_id,
        city,
        state,
        customer_segment,
        lifetime_value,
        last_order_at,
        days_since_last_order,
        'VIP Churn Prevention' as campaign_type,
        2 as priority_score
    from customer_360
    where customer_segment in ('VIP', 'Super Loyal')
      and customer_status in ('At Risk', 'Cooling')
),

-- Clients Repeat actifs à upsell
upsell_opportunities as (
    select
        customer_unique_id,
        city,
        state,
        customer_segment,
        lifetime_value,
        last_order_at,
        days_since_last_order,
        'Repeat Customer Upsell' as campaign_type,
        3 as priority_score
    from customer_360
    where customer_segment = 'Repeat'
      and customer_status = 'Active'
      and lifetime_value < 500  -- Potentiel d'augmentation
)

-- Consolider toutes les opportunités
select * from high_value_reactivation
union all
select * from churn_prevention
union all
select * from upsell_opportunities
order by priority_score, lifetime_value desc