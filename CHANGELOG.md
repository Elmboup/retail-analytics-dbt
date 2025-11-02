# Changelog

Toutes les modifications notables de ce projet seront documentées dans ce fichier.

## [1.0.0] - 2025-11-02

### Ajouté
- Architecture de base avec couches Staging, Intermediate, Marts
- Modèles staging : `stg_orders`, `stg_customers`, `stg_products`, `stg_order_items`
- Modèle intermediate : `int_customer_orders`
- Modèles marts core :
  - `fct_sales` (mode incrémental)
  - `dim_customers` avec segmentation
  - `customer_360` vue consolidée
  - `cohort_analysis` pour analyse de rétention
  - `product_performance` avec classification ABC
  - `geographic_performance` par état
- Modèle marts marketing : `reactivation_opportunities`
- 25+ tests de qualité de données
- Documentation complète avec dbt docs
- README avec insights business

### Métriques
- 99,441 commandes traitées
- 12 modèles dbt
- 25+ tests qualité
- Documentation 100% coverage

## [À Venir]

### Version 1.1.0
- Orchestration avec Dagster
- Dashboards BI (Metabase/Preset)
- Analyses marketing avancées

### Version 1.2.0
- Modèles prédictifs (ML)
- Analyse sentiment reviews
- Great Expectations pour data quality avancée
```

---

### 7. Créer un LICENSE

Créez `LICENSE` (MIT License) :
```
MIT License

Copyright (c) 2025 [Votre Nom]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.