# 06 — Database Design

## Database Overview

CraftMitra uses **Cloud Firestore** as its primary application database.

The database stores artisan information, product listings, buyer information,
orders, pricing information and sales-related data.

## Data Structure

Artisan
   │
   ├── Products
   │      ├── Catalog Information
   │      ├── Pricing Information
   │      └── Product Images
   │
   ├── Orders
   │
   └── Sales Data

Buyer
   │
   └── Buyer Requirements
Main Data Models
Artisan

Stores information related to the artisan using the application.

Key information:

Artisan identity
Profile information
Authentication reference
Product

Stores the details of products created by the artisan.

Key information:

Product name
Description
Category
Craft details
Materials
Images
Price
Quantity
Publishing status
Catalog

Stores the structured product information generated during
the catalog creation process.

Key information:

Product information
Generated description
Craft details
Catalog content
Buyer

Stores buyer information used for product discovery and matching.

Key information:

Buyer profile
Requirements
Product categories
Material preferences
Quantity requirements
Location information
Pricing

Stores information related to the product price recommendation.

Key information:

Product cost factors
Suggested price
Pricing explanation
Order

Stores information related to product orders.

Key information:

Product reference
Buyer reference
Quantity
Order status
Order details
Sales Data

Stores information used by the Sales Dashboard to display
business activity and sales information.

Data Flow
Artisan Input
     ↓
Product Data
     ↓
Cloud Firestore
     ↓
Catalog / Pricing / Buyer Matching
     ↓
Published Products
     ↓
Orders
     ↓
Sales Data
Database Services
Cloud Firestore
      ↓
Product Service
Order Service
Authentication
Sales Data
Design Approach

The database structure separates major application data into
clear models, making the application easier to maintain and
extend with future marketplace integrations.