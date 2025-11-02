{{
  config(
    materialized='view'
  )
}}

with sales as (
    select * from {{ ref('fct_sales') }}
),

customers as (
    select * from {{ ref('dim_customers') }}
),

-- Métriques globales
global_metrics as (
    select
        count(distinct order_id) as total_orders,
        count(distinct customer_id) as total_customers,
        round(sum(total_amount), 2) as total_revenue,
        round(avg(total_amount), 2) as avg_order_value,
        round(sum(total_amount) / count(distinct customer_id), 2) as revenue_per_customer,
        round(avg(delivery_days), 1) as avg_delivery_days
    from sales
),

-- Métriques par période
monthly_metrics as (
    select
        order_month,
        count(distinct order_id) as monthly_orders,
        round(sum(total_amount), 2) as monthly_revenue,
        round(avg(total_amount), 2) as monthly_aov
    from sales
    group by order_month
),

-- Performance par segment
segment_performance as (
    select
        customer_segment,
        count(*) as nb_customers,
        round(sum(lifetime_value), 2) as segment_revenue,
        round(avg(lifetime_value), 2) as avg_ltv,
        round(sum(lifetime_value) * 100.0 / sum(sum(lifetime_value)) over(), 2) as revenue_contribution_pct
    from customers
    where total_orders > 0
    group by customer_segment
),

-- Métriques géographiques
top_cities as (
    select
        customer_city,
        count(distinct customer_id) as nb_customers,
        round(sum(total_amount), 2) as city_revenue
    from sales
    group by customer_city
    order by city_revenue desc
    limit 10
)

-- Consolidation finale
select
    'Global Metrics' as metric_type,
    null as dimension,
    total_orders as value_numeric,
    'Total Orders' as metric_name
from global_metrics

union all

select
    'Global Metrics',
    null,
    total_revenue,
    'Total Revenue (BRL)'
from global_metrics

union all

select
    'Global Metrics',
    null,
    avg_order_value,
    'Average Order Value (BRL)'
from global_metrics

union all

select
    'Segment Performance',
    customer_segment,
    segment_revenue,
    'Revenue by Segment'
from segment_performance

union all

select
    'Geography',
    customer_city,
    city_revenue,
    'Top 10 Cities Revenue'
from top_cities