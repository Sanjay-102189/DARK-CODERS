# 08 — Smart Pricing

## Overview

CraftMitra provides an explainable price recommendation to help
artisans understand the possible selling price of their products.

The recommendation considers basic product cost factors rather than
providing an unexplained fixed price.

## Pricing Flow

Product Information
        ↓
Material Cost
        ↓
Labour Cost
        ↓
Other Cost Factors
        ↓
Pricing Logic
        ↓
Suggested Price
        ↓
Artisan Review


Implementation

Service: Smart Pricing Service

The pricing service processes available product cost information
and generates a suggested price.

The result is presented to the artisan along with the factors
considered for the recommendation.

Key Principles
Explainable: The artisan can understand the factors affecting
the suggested price.
Adjustable: The artisan can review and modify the suggested price.
Product-Aware: Pricing is based on information associated with
the individual product.
Decision Support: The recommendation assists the artisan and
does not replace the artisan's final pricing decision.
Pricing Approach
Cost Factors
     ↓
Rule-Based Pricing Logic
     ↓
Price Recommendation
     ↓
Artisan Validation
     ↓
Final Product Price
Current Scope

The current implementation uses explainable rule-based application
logic for price recommendation.

It is not a separately trained machine-learning pricing model.

Future Enhancement

Future versions can incorporate additional market data, regional
price trends and historical sales information to improve pricing
assistance.