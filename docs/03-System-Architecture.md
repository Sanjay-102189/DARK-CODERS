# 03 — System Architecture

## 1. Architecture Overview

CraftMitra is implemented as a modular Flutter mobile application supported by Firebase services, Cloudinary media storage and artificial intelligence capabilities through Firebase AI Logic and Gemini.

The architecture separates the user interface, application features, domain services and external services.


## 2. High-Level Architecture


                         ARTISAN
                            │
                     Photo + Voice
                            │
                            ▼
                  ┌──────────────────┐
                  │ Flutter Mobile   │
                  │    Application   │
                  └────────┬─────────┘
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
       Image Processing          Speech-to-Text
              │                         │
              └────────────┬────────────┘
                           ▼
                     Gemini AI
                           │
                           ▼
                 Product Information
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
       Smart Pricing              Buyer Matching
              │                         │
              └────────────┬────────────┘
                           ▼
                    Product Publishing
                           │
                           ▼
                         Orders
                           │
                           ▼
                    Sales Dashboard


3. Major Architecture Layers
3.1 Presentation Layer

The presentation layer is implemented using Flutter.

It contains the screens and user interface components through which artisans interact with the application.

Major areas include:

Home dashboard
Authentication
Product creation
Product catalog
Buyer directory
Orders
Sales dashboard
AI assistant
3.2 Application Layer

The application layer manages navigation and application flow.

The project uses:

Provider for state management
GoRouter for navigation
Application-level services for feature-specific operations
3.3 Domain Services

Domain services contain functionality that supports the application's business operations.

Major services include:

Authentication service
Product service
Order service
Voice recording
Pricing service
Matching service
Image selection
Image enhancement
AI catalog service

These services keep business operations separate from individual user interface screens.

4. Catalog Creation Flow
Product Image
      +
Voice Input
      │
      ▼
Speech-to-Text
      │
      ▼
Product Information
      │
      ▼
AI Catalog Processing
      │
      ▼
Catalog Preview
      │
      ▼
Artisan Review
      │
      ▼
Product Publishing


5. Pricing Flow
Product Information
        │
        ▼
Available Cost Factors
        │
        ▼
Pricing Service
        │
        ▼
Price Recommendation
        │
        ▼
Artisan Review
        │
        ▼
Final Product Price

The current implementation uses explainable application-level pricing logic rather than claiming a separately trained machine-learning model.

6. Buyer Matching Flow
Product Information
        │
        ├── Category
        ├── Material
        ├── Craft Technique
        ├── Price
        ├── Quantity
        └── Location
                 │
                 ▼
        Buyer Requirements
                 │
                 ▼
        Matching Service
                 │
                 ▼
        Suitable Buyer Profiles

The current matching mechanism is application-level and explainable.

7. Data and Media Services
Firebase Authentication

Responsible for user authentication.

Cloud Firestore

Stores application data such as product and order information.

Cloudinary

Handles product image storage and media-related operations.

8. Artificial Intelligence Integration

Firebase AI Logic is used to connect the application with Gemini for AI-assisted product and catalog operations.

Flutter Application
        │
        ▼
Firebase AI Logic
        │
        ▼
Gemini
        │
        ▼
Generated Product Information
        │
        ▼
Application Review

AI-generated information is presented for review rather than being treated as automatically final.

9. Data Flow

The general application data flow is:

User
 ↓
Flutter Application
 ↓
Domain Services
 ↓
Firebase / Cloud Services
 ↓
Application Data / Media / AI Processing
 ↓
Flutter Application
 ↓
User


10. Architecture Principles

The implementation follows these principles:

Separation of user interface and business logic
Reusable services
Centralized application state where required
Cloud-based application data
Separate media storage
Human review of AI-generated information
Explainable application logic for pricing and matching
Scope for future external integrations

11. Detailed Architecture Diagram

The complete visual architecture diagram is maintained in:

assets/architecture/system-architecture.png

The diagram represents the actual application modules and their relationships in the current implementation.