# CraftMitra

### Your Craft. Your Business. Your Digital Mitra.

**AI-Driven Market Linkage and Smart Cataloging Mobile Application for Marginalized Artisans**

**Smart India Hackathon 2026 — SIH26090**
**Theme:** Heritage & Culture
**Category:** Software
**Team:** DARK CODERS

---

## 🎯 Problem

Many traditional and marginalized artisans have strong craftsmanship but face difficulties when moving their products into digital markets.

Common challenges include:

- Creating professional product listings
- Writing product descriptions
- Preparing product images
- Understanding suitable pricing
- Finding relevant buyers
- Managing orders and sales
- Using unfamiliar digital interfaces

CraftMitra addresses these challenges through a simple, artisan-centered mobile workflow.

---

## 💡 Proposed Solution

**CraftMitra** acts as a virtual business manager for artisans.

Instead of requiring artisans to learn complex digital tools, the application allows them to use **photos and voice input** to create structured product information.

The application supports the journey from product creation to digital selling.

### Core Workflow

**SHOW → SPEAK → CREATE → PRICE → MATCH → SELL**

| Stage | Purpose |
|---|---|
| SHOW | Capture or upload the product |
| SPEAK | Describe the product using voice |
| CREATE | Generate structured product information |
| PRICE | Provide an explainable price suggestion |
| MATCH | Identify suitable buyer profiles |
| SELL | Publish products and manage orders |

---

## ✨ Key Features

### Smart Product Cataloging
Creates structured product information from available product details.

### Voice-First Product Creation
Allows artisans to describe products using speech instead of relying completely on typing.

### AI-Assisted Catalog Creation
Uses Firebase AI Logic and Gemini to assist with product understanding and catalog information.

### Explainable Smart Pricing
Provides price suggestions using identifiable product and cost factors.

### Buyer Matching
Compares product characteristics with buyer requirements to identify relevant buyer profiles.

### Product Publishing
Allows artisans to review and publish their product information.

### Order Management
Provides order-related information through the application.

### Sales Dashboard
Helps artisans view sales-related information.

---

## 🛠 Technology Stack

| Layer | Technology |
|---|---|
| Mobile Application | Flutter |
| Programming Language | Dart |
| State Management | Provider |
| Navigation | GoRouter |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Artificial Intelligence | Firebase AI Logic + Gemini |
| Voice Input | Speech-to-Text |
| Product Images | Cloudinary |
| User Interface Design | Stitch |
| Development | Visual Studio Code / Antigravity |
| Version Control | Git + GitHub |

---

## 🏗 System Architecture

```text
                         ARTISAN
                            │
                    PHOTO + VOICE INPUT
                            │
                            ▼
                  ┌──────────────────┐
                  │  FLUTTER MOBILE  │
                  │   APPLICATION    │
                  └────────┬─────────┘
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
       IMAGE PROCESSING            SPEECH-TO-TEXT
              │                         │
              └────────────┬────────────┘
                           ▼
                    GEMINI AI
                           │
                           ▼
              STRUCTURED PRODUCT DATA
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
        SMART PRICING             BUYER MATCHING
              │                         │
              └────────────┬────────────┘
                           ▼
                   PRODUCT PUBLISHING
                           │
                           ▼
                       ORDERS
                           │
                           ▼
                    SALES DASHBOARD
Supporting Services

Firebase Authentication → User authentication
Cloud Firestore → Application data
Cloudinary → Product image storage
Firebase AI Logic → Artificial intelligence interaction

Detailed architecture:

docs/03-System-Architecture.md

🔄 Application Flow
Authentication
      ↓
Home Dashboard
      ↓
Add Product
      ↓
Image Selection
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

The artisan remains in control and can review or edit generated information before publishing.

Detailed workflow:

docs/04-Application-Flow.md

🤖 Artificial Intelligence

CraftMitra uses artificial intelligence primarily for product understanding and catalog assistance.

Product Image
      +
Artisan Voice
      ↓
Speech-to-Text
      ↓
Product Information
      ↓
Firebase AI Logic
      ↓
Gemini
      ↓
Structured Product Information
      ↓
Catalog Preview
      ↓
Artisan Review

Artificial intelligence assists with:

Understanding product information
Generating product descriptions
Structuring catalog information
Product-related assistance

AI-generated information is not automatically treated as final. The artisan can review and edit the information before publishing.

Detailed documentation:

docs/07-AI-Architecture.md

💰 Smart Pricing

CraftMitra provides an explainable price recommendation rather than an unexplained output.

Main Factors
Material cost
Labour or craft effort
Product characteristics
Quantity
Other available product factors
Product & Cost Factors
          ↓
   Pricing Logic
          ↓
 Price Recommendation
          ↓
   Artisan Review
          ↓
    Final Price

The current implementation uses application-level pricing logic with artificial intelligence assistance where applicable. It is not presented as a separately trained machine-learning pricing model.

Detailed documentation:

docs/08-Smart-Pricing.md

🤝 Buyer Matching

Buyer matching is implemented as an explainable compatibility process.

Product Information
        +
Buyer Requirements
        ↓
Compatibility Analysis
        ↓
Suitable Buyer Profiles

Matching can consider:

Product category
Material
Craft technique
Price range
Quantity
Location
Buyer requirements

The current buyer profiles are representative application data used to demonstrate the matching workflow.

Detailed documentation:

docs/09-Buyer-Matching.md

🗄 Data Architecture

CraftMitra uses Cloud Firestore for application data and Cloudinary for product images.

Cloud Firestore
│
├── User Information
├── Product Information
├── Order Information
└── Application Data

Cloudinary
└── Product Images

Detailed database documentation:

docs/06-Database-Design.md

🔐 Authentication & Security

CraftMitra uses Firebase Authentication for user authentication.

The application separates:

Authentication
Application data
Product media

Current security considerations include:

Authenticated user access
Firestore-based application data
Application-level validation
Separate product media storage
Credential protection during development

Production-level security hardening remains part of continued development.

Detailed documentation:

docs/10-Authentication-and-Security.md

🧪 Testing & Validation

The application has been validated during development using Flutter tooling and feature-level testing.

Development Validation
Flutter Analyze
Static Analysis
Flutter Test
Debug APK Build Verification

Feature-level validation covers implemented areas such as:

Authentication
Product creation
Image handling
Voice input
Catalog generation
Pricing
Buyer matching
Orders
Sales-related screens

Detailed testing documentation:

docs/12-Testing-and-Validation.md

📈 Implementation Progress

CraftMitra has been developed incrementally through multiple stages.

Stage	Progress Area
1	Project foundation
2	Authentication
3	Product creation
4	Artificial intelligence integration
5	Marketplace logic
6	Business management
7	Testing and refinement

Detailed progress:

docs/13-Implementation-Progress.md

📁 Project Structure
CraftMitra/
│
├── android/
├── ios/
├── lib/
│   ├── core/
│   ├── models/
│   ├── providers/
│   ├── services/
│   └── features/
│
├── assets/
│   ├── architecture/
│   ├── database/
│   ├── flowcharts/
│   ├── graphs/
│   └── screenshots/
│
├── docs/
├── test/
├── pubspec.yaml
├── README.md
└── .gitignore

The application separates screens, services, models, state management, and supporting functionality.

⚙️ Technical Decisions
Technology	Reason
Flutter	Cross-platform mobile development
Dart	Native language for Flutter
Firebase Authentication	Managed user authentication
Cloud Firestore	Cloud-based application data
Firebase AI Logic	Artificial intelligence integration
Gemini	Product information and AI assistance
Speech-to-Text	Voice-first product creation
Cloudinary	Product image storage
Provider	Application state management
GoRouter	Structured navigation

Detailed decisions:

docs/14-Technical-Decisions.md

⚠️ Current Limitations

The current implementation is a working development version.

Buyer profiles are representative data.
Buyer matching is currently application-level compatibility logic.
Pricing is not based on a separately trained machine-learning model.
External marketplace integrations are future work unless explicitly connected.
Payment and escrow functionality are not implemented as live financial services.
Production deployment and large-scale infrastructure hardening remain future work.
Language coverage can be expanded to additional Indian languages.

These limitations clearly separate the current implementation from the future scope.

🚀 Future Scope

Potential future extensions include:

Digital marketplace integrations
Additional Indian language support
Larger market datasets
Advanced pricing models
Improved buyer discovery
Production security hardening
Business intelligence and advanced sales analytics
Payment and logistics integrations

Detailed future scope:

docs/15-Future-Scope.md

📚 Documentation

The repository contains focused technical documentation for the major parts of CraftMitra.

Document	Description
01 — Problem Statement	Problem and target users
02 — Project Overview	Product concept and objectives
03 — System Architecture	Architecture and components
04 — Application Flow	End-to-end workflow
05 — Feature Documentation	Feature implementation
06 — Database Design	Firestore data structure
07 — AI Architecture	Artificial intelligence integration
08 — Smart Pricing	Pricing logic
09 — Buyer Matching	Buyer compatibility logic
10 — Authentication & Security	Security architecture
11 — Image & Voice Processing	Media and voice workflow
12 — Testing & Validation	Development testing
13 — Implementation Progress	Development stages
14 — Technical Decisions	Technology decisions
15 — Future Scope	Planned improvements
📱 Prototype

The repository contains the source code and supporting material for the CraftMitra mobile application.

Major Product Journey

Product Creation → AI-Assisted Catalog → Pricing → Buyer Matching → Publishing → Orders → Sales

👥 Team
DARK CODERS

Project: CraftMitra
Problem Statement: SIH26090
Smart India Hackathon: 2026

Your Craft. Your Business. Your Digital Mitra.
