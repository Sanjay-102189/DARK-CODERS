CraftMitra
Your Craft. Your Business. Your Digital Mitra.

AI-Driven Market Linkage and Smart Cataloging Mobile Application for Marginalized Artisans

Smart India Hackathon 2026 — SIH26090
Theme: Heritage & Culture
Category: Software
Team: DARK CODERS

1. Project Overview

CraftMitra is a mobile application designed to help traditional and marginalized artisans manage the digital side of their craft business.

Many artisans have the skills to create high-quality handmade products but face difficulties when they need to create digital product listings, write descriptions, determine suitable prices, identify potential buyers, and manage orders.

CraftMitra addresses this gap through a simple mobile workflow that combines photo-based product creation, voice input, artificial intelligence-assisted cataloging, explainable pricing, buyer matching, and basic business management.

The application is designed around a simple principle:

The technology should adapt to the artisan, rather than requiring the artisan to adapt to the technology.


2. Problem

Traditional artisans often depend on local markets, intermediaries, exhibitions, and personal networks to sell their products.

Moving to digital commerce introduces several challenges:

Creating professional product listings
Writing product descriptions
Photographing and preparing product images
Entering product information manually
Understanding suitable pricing
Finding buyers who require their type of products
Managing orders and sales information
Working with digital interfaces and unfamiliar terminology
Communicating product information when typing is difficult

These challenges can prevent artisans from effectively reaching wider digital markets.


3. Proposed Solution

CraftMitra provides a single mobile workflow through which an artisan can take a product from creation to digital selling.

Core Workflow
SHOW
  ↓
SPEAK
  ↓
CREATE
  ↓
PRICE
  ↓
MATCH
  ↓
SELL
Workflow Explanation

SHOW
The artisan captures or uploads the product image.

SPEAK
The artisan describes the product using voice input.

CREATE
CraftMitra processes the available information and assists in creating structured product details.

PRICE
The application provides an explainable price suggestion based on available product and cost factors.

MATCH
The application compares product characteristics with buyer requirements and identifies suitable buyer profiles.

SELL
The artisan can publish the product, manage orders, and view sales information.


4. Key Features
Smart Product Cataloging

Converts basic product information into a structured digital catalog containing details such as:

Product title
Description
Category
Product attributes
Tags
Images
Voice-First Product Creation

Artisans can describe their products using speech instead of relying entirely on manual typing.

The speech input is converted into text and used as part of the catalog creation process.

Image Studio

Provides product image selection and image-related processing before the product is published.

Product media is stored separately from application data.

Explainable Smart Pricing

CraftMitra provides price suggestions using identifiable factors such as:

Material cost
Labour considerations
Product characteristics
Quantity
Other available pricing factors

The artisan can review and modify the suggested price before publishing.

The current implementation uses application-level pricing logic with artificial intelligence assistance where applicable; it is not presented as a separately trained machine-learning pricing model.

Buyer Matching

The application compares product information with buyer requirements.

Matching can consider factors such as:

Product category
Material
Craft technique
Price range
Quantity
Location
Buyer requirements

The matching approach is designed to remain explainable rather than producing an unexplained recommendation score.

Product Publishing:
After reviewing the generated information, the artisan can publish the product through the application's product workflow.

Order Management:
Artisans can view and manage product orders through the application.

Sales Dashboard:
Provides an overview of sales-related information and helps artisans understand their business activity.

AI Business Assistance:
CraftMitra includes an AI-assisted business support layer intended to help artisans with product and business-related interactions.


5. Technology Stack

Layer:	                           Technology:
Mobile Application	               Flutter
Programming Language	           Dart
State Management	               Provider
Navigation	                       GoRouter
Authentication	                   Firebase Authentication
Database	                       Cloud Firestore
Artificial Intelligence	           Firebase AI Logic + Gemini
Voice Input	                       Speech-to-Text
Product Image Storage	           Cloudinary
User Interface Design	           Stitch
Development	                       Visual Studio Code / Antigravity
Version Control	                   Git + GitHub


6. System Architecture

CraftMitra follows a modular mobile application architecture.

                    ARTISAN
                       │
                 Photo + Voice
                       │
                       ▼
              ┌─────────────────┐
              │ Flutter Mobile  │
              │   Application   │
              └────────┬────────┘
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
   Smart Pricing             Buyer Matching
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
Supporting Services
Flutter Application
       │
       ├── Firebase Authentication
       │
       ├── Cloud Firestore
       │
       ├── Firebase AI Logic
       │
       └── Cloudinary

A detailed architecture diagram is available in:

docs/03-System-Architecture.md


7. Application Flow

The primary product flow is:

User Authentication
        ↓
Home Dashboard
        ↓
Add Product
        ↓
Capture / Upload Image
        ↓
Voice Product Description
        ↓
Speech-to-Text
        ↓
AI-Assisted Catalog Creation
        ↓
Catalog Review
        ↓
Smart Pricing
        ↓
Buyer Matching
        ↓
Publish Product
        ↓
Order Management
        ↓
Sales Dashboard

The artisan remains in control of the final product information and can review or edit generated information before publishing.

Detailed workflow documentation:

docs/04-Application-Flow.md


8. AI Architecture

CraftMitra uses artificial intelligence primarily for product understanding and catalog assistance.

Product Image
      +
Artisan Voice Input
      │
      ▼
Speech-to-Text
      │
      ▼
Product Information
      │
      ▼
Firebase AI Logic
      │
      ▼
Gemini
      │
      ▼
Structured Product Information
      │
      ▼
Catalog Preview
      │
      ▼
Artisan Review
AI Responsibilities

The AI layer can assist with:

Understanding product information
Generating product descriptions
Structuring catalog information
Assisting product-related interactions
Important Design Principle

AI-generated information is not automatically treated as final.

The artisan can review and edit the information before publishing.

Detailed documentation:

docs/07-AI-Architecture.md


9. Smart Pricing

CraftMitra's pricing component is designed to provide a transparent price recommendation rather than an unexplained output.

Material Cost
      +
Labour / Craft Effort
      +
Product Characteristics
      +
Quantity
      +
Other Available Factors
      │
      ▼
Price Recommendation
      │
      ▼
Artisan Review
      │
      ▼
Final Product Price

The pricing mechanism is currently application-level and explainable. It is not claimed to be a separately trained machine-learning model.

Detailed implementation:

docs/08-Smart-Pricing.md


10. Buyer Matching

Buyer matching is implemented as an explainable compatibility process.

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
      Compatibility Analysis
                │
                ▼
        Suitable Buyers

The purpose is to help artisans discover buyer profiles whose requirements are relevant to their products.

The current buyer profiles are representative application data for demonstrating the matching workflow.

Detailed documentation:

docs/09-Buyer-Matching.md


11. Data Architecture

Cloud Firestore is used for application data.

The application separates structured application data from product media.

Cloud Firestore
│
├── User Information
│
├── Product Information
│
├── Order Information
│
└── Application Data


Cloudinary
│
└── Product Images
Data Responsibilities
Service	Responsibility
Firebase Authentication	User authentication
Cloud Firestore	Application and business data
Cloudinary	Product image storage
Firebase AI Logic	Artificial intelligence interaction

Detailed database documentation:

docs/06-Database-Design.md


12. Security and Authentication

CraftMitra uses Firebase Authentication for user authentication.

The application separates authentication from application data and media storage.

Current security considerations include:

Authenticated user access
Firebase Authentication
Firestore-based application data
Application-level validation
Separate product media storage
Environment and credential protection during development

Security hardening and production-level security improvements remain part of the continuing development process.

Detailed documentation:

docs/10-Authentication-Security.md


13. Testing and Validation

The application has been validated during development through Flutter tooling and feature-level testing.

Development Validation
Flutter Analyze
      ↓
Static Analysis
      ↓
No Known Analysis Errors
Flutter Test
      ↓
Automated Test Execution
Flutter Build APK
      ↓
Debug Build Verification

Feature-level validation includes authentication, product creation, image handling, voice input, catalog generation, pricing, buyer matching, orders, and sales-related screens where implemented.

Detailed test documentation:

docs/12-Testing-and-Validation.md


14. Implementation Progress

CraftMitra has been developed incrementally rather than as a single prototype screen.

Development Stages

Stage 1 — Project Foundation

Flutter project setup
Application structure
Theme and design system
Navigation

Stage 2 — Authentication

User authentication
Authentication screens
User flow

Stage 3 — Product Creation

Add product workflow
Image selection
Voice input
Catalog workflow

Stage 4 — Artificial Intelligence Integration

Firebase AI Logic integration
Gemini integration
AI-assisted product information

Stage 5 — Marketplace Logic

Smart pricing
Buyer matching
Product publishing

Stage 6 — Business Management

Orders
Sales dashboard
AI assistant

Stage 7 — Validation and Refinement

Static analysis
Testing
Debug build verification
User interface refinement

Detailed progress:

docs/13-Implementation-Progress.md


15. Project Structure
CraftMitra
│
├── android/
├── ios/
├── lib/
│   │
│   ├── core/
│   ├── models/
│   ├── providers/
│   ├── services/
│   ├── screens/
│   ├── widgets/
│   └── ...
│
├── assets/
├── docs/
├── test/
│
├── pubspec.yaml
├── README.md
└── .gitignore

The application is organized into separate components for screens, services, models, state management, and supporting functionality.


16. Technical Decisions
Decision	Reason
Flutter	Cross-platform mobile development
Dart	Native language for Flutter
Firebase Authentication	Authentication without building a custom authentication system
Cloud Firestore	Cloud-based application data
Firebase AI Logic	Integration of generative artificial intelligence capabilities
Gemini	Product information and AI assistance
Speech-to-Text	Enables voice-first product creation
Cloudinary	Product image storage and media handling
Provider	Application state management
GoRouter	Structured application navigation

Detailed decisions:

docs/14-Technical-Decisions.md


17. Current Limitations

The current implementation is a working development version and has several areas planned for further development.

Buyer profiles used for demonstration are representative data.
Buyer matching currently focuses on application-level compatibility rather than a live marketplace network.
Pricing recommendations are not based on a separately trained machine-learning model.
Marketplace integrations such as ONDC and other external commerce platforms are future integration areas unless explicitly connected.
Payment and escrow functionality are not currently implemented as live financial services.
Production deployment and large-scale infrastructure hardening remain future work.
Language coverage can be expanded to support additional Indian languages and speech patterns.

These limitations are documented so that the current implementation and future scope remain clearly separated.


18. Future Scope

Future development can extend CraftMitra through:

Marketplace Integration

Integration with suitable digital commerce and marketplace networks.

Regional Language Expansion

Support for additional Indian languages and regional speech patterns.

Advanced Pricing

Use of larger market datasets and trained models when reliable data becomes available.

Improved Buyer Discovery

Expansion from representative buyer profiles toward real marketplace requirements.

Production Security

Stronger API restrictions, production authentication policies, secure media upload architecture, monitoring, and security auditing.

Business Intelligence

More detailed sales analytics and business insights for artisans.

Logistics and Payments

Integration with appropriate payment, delivery, and order fulfilment services.


19. Documentation

The repository contains detailed technical documentation for the project.

Document	                             Description
Problem Statement	                     Problem and target users
Project Overview	                     Product concept and objectives
System Architecture	                     Application architecture and components
Application Flow	                     End-to-end application workflow
Feature Documentation	                 Feature-level implementation
Database Design	                         Firestore data structure
AI Architecture	                         Artificial intelligence integration
Smart Pricing	                         Pricing logic
Buyer Matching	                         Buyer compatibility logic
Authentication & Security	             Security architecture
Image & Voice Processing	             Media and voice workflow
Testing & Validation	                 Development testing
Implementation Progress	                 Development stages
Technical Decisions	                     Major technology decisions
Future Scope	                         Planned improvements


20. Prototype

The repository contains the source code and supporting material for the CraftMitra mobile application.

The prototype demonstrates the major product journey:

Product Creation
      ↓
AI-Assisted Catalog
      ↓
Pricing
      ↓
Buyer Matching
      ↓
Publishing
      ↓
Orders
      ↓
Sales



21. Team
DARK CODERS

Project: CraftMitra
Problem Statement: SIH26090
Smart India Hackathon: 2026

Your Craft. Your Business. Your Digital Mitra.