{{
  config(
    materialized='view'
  )
}}

-- Vue consolidée des insights business actionnables
select 
    'Retention Crisis' as insight_category,
    'Only 0.4% of customers make a 2nd purchase within 30 days' as insight,
    'Critical' as priority,
    'Implement post-purchase email campaign + loyalty program' as recommendation
    
union all

select
    'Product Strategy',
    'beleza_saude category dominates top revenue - 2 products = 0.9% of total revenue',
    'High',
    'Expand beleza_saude inventory, create dedicated landing pages'
    
union all

select
    'Geographic Expansion',
    'SP generates 3x more revenue than RJ, but RJ has 16% higher AOV',
    'Medium',
    'Invest in RJ logistics (currently 20% fast delivery vs 51% in SP) to unlock higher-value customer base'
    
union all

select
    'Logistics Optimization',
    'Fast delivery rate in RJ is 31 points lower than SP despite higher AOV',
    'High',
    'Partner with local carriers in RJ, analyze root causes of delays'

union all

select
    'Customer Value',
    '96.5% of customers are one-time buyers representing 15.8M revenue',
    'Critical',
    'Even 5% conversion to repeat = 790 new loyal customers = potential 400K+ additional revenue'