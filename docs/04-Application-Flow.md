# 04 — Application Flow

## Application Workflow

User Authentication
        ↓
Home Dashboard
        ↓
Add Product
        ↓
Image Studio
        ↓
Voice Catalog
        ↓
AI Processing
        ↓
Catalog Preview
        ↓
Smart Pricing
        ↓
Buyer Matching
        ↓
Publish Product
        ↓
Orders & Sales
Implementation
1. Authentication

Component: Authentication
Technology: Firebase Authentication
Purpose: Secure artisan login and user authentication.

2. Product Creation

Component: Add Product
Purpose: Capture the basic product information and images.

3. Image Processing

Component: Image Studio
Service: Cloudinary
Purpose: Handle product images and image enhancement.

4. Voice Input

Component: Voice Catalog
Service: Speech-to-Text
Purpose: Convert the artisan's spoken description into text.

5. AI Processing

Component: AI Processing
Service: AI Catalog Service
Purpose: Generate structured product information from the provided inputs.

6. Catalog Generation

Component: Catalog Preview
Purpose: Allow the artisan to review and edit the generated product information.

7. Price Recommendation

Component: Smart Pricing
Service: Smart Pricing Service
Purpose: Provide an explainable price recommendation based on product factors.

8. Buyer Discovery

Component: Buyer Matching
Service: Buyer Matching Service
Purpose: Identify compatible buyers based on product and buyer requirements.

9. Product Publishing

Component: Publish Product
Database: Cloud Firestore
Purpose: Store and publish the finalized product listing.

10. Order Management

Component: Orders
Service: Firestore Order Service
Purpose: Manage product orders and order information.

11. Sales Tracking

Component: Sales Dashboard
Purpose: Track sales information and provide business insights.

Supporting Services
Firebase Authentication → User Authentication
Cloud Firestore         → Application Data
Cloudinary              → Product Images
AI Catalog Service      → AI-Assisted Catalog Generation
Smart Pricing Service   → Price Recommendation
Buyer Matching Service  → Buyer Discovery
Voice Recording Service → Voice Input
Outcome

CraftMitra converts an artisan's product photo and voice description
into a structured, reviewed and publishable digital product listing,
followed by buyer discovery, order management and sales tracking.