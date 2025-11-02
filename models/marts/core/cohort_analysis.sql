{{
  config(
    materialized='table'
  )
}}

with customer_orders as (
    select
        customer_unique_id,
        order_purchased_at,
        total_amount,
        row_number() over (partition by customer_unique_id order by order_purchased_at) as order_number
    from {{ ref('fct_sales') }}
),

first_orders as (
    select
        customer_unique_id,
        order_purchased_at as first_order_date,
        date_trunc('month', order_purchased_at) as cohort_month,
        total_amount as first_order_value
    from customer_orders
    where order_number = 1
),

subsequent_orders as (
    select
        co.customer_unique_id,
        fo.cohort_month,
        co.order_purchased_at,
        date_trunc('month', co.order_purchased_at) as order_month,
        datediff('month', fo.cohort_month, date_trunc('month', co.order_purchased_at)) as months_since_first_order,
        co.total_amount
    from customer_orders co
    join first_orders fo on co.customer_unique_id = fo.customer_unique_id
),

cohort_data as (
    select
        cohort_month,
        months_since_first_order,
        count(distinct customer_unique_id) as customers_retained,
        count(distinct order_purchased_at) as orders_count,
        round(sum(total_amount), 2) as cohort_revenue
    from subsequent_orders
    group by cohort_month, months_since_first_order
),

cohort_size as (
    select
        cohort_month,
        count(distinct customer_unique_id) as cohort_size,
        round(sum(first_order_value), 2) as cohort_initial_revenue
    from first_orders
    group by cohort_month
)

select
    cd.cohort_month,
    cd.months_since_first_order,
    cs.cohort_size,
    cd.customers_retained,
    cd.orders_count,
    cd.cohort_revenue,
    cs.cohort_initial_revenue,
    round(cd.customers_retained * 100.0 / cs.cohort_size, 2) as retention_rate_pct
from cohort_data cd
join cohort_size cs on cd.cohort_month = cs.cohort_month
order by cd.cohort_month, cd.months_since_first_order