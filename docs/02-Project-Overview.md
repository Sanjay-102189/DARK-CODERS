# 02 — Project Overview

## 1. Project

**CraftMitra**

### Tagline

**Your Craft. Your Business. Your Digital Mitra.**

### Problem Statement

**SIH26090**

### Theme

**Heritage & Culture**

### Category

**Software**

### Team

**DARK CODERS**



## 2. Project Objective

CraftMitra is designed as a mobile-based digital business assistant for traditional and marginalized artisans.

The objective is to simplify the process of converting handmade products into structured digital listings and provide basic tools required to manage the product journey from creation to sales.

The application brings product creation, catalog generation, pricing assistance, buyer discovery and business management into one workflow.



## 3. Core Product Journey

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

SHOW

The artisan captures or uploads an image of the product.

SPEAK

The artisan provides product information using voice input.

CREATE

The application processes the available information and assists in creating structured product details.

PRICE

The application provides an explainable price suggestion based on available product and cost factors.

MATCH

The application compares product characteristics with buyer requirements.

SELL

The artisan can publish products, manage orders and view sales information.

4. Main Functional Areas
Authentication

Provides user authentication through Firebase Authentication.

Product Creation

Allows artisans to add products using images and product information.

Voice Cataloging

Uses speech-to-text to reduce the amount of manual typing required during product creation.

AI-Assisted Cataloging

Uses Firebase AI Logic and Gemini to assist with product information generation and catalog creation.

Image Handling

Product images are selected and processed before being associated with product information.

Smart Pricing

Provides a price recommendation using explainable application-level pricing logic.

Buyer Matching

Compares product information with buyer requirements to identify suitable buyer profiles.

Product Publishing

Allows the artisan to review product information before publishing.

Order Management

Provides screens and workflows for viewing and managing orders.

Sales Dashboard

Provides sales-related information to help the artisan monitor business activity.

AI Assistant

Provides an AI-assisted interface for product and business-related support.

5. Technology Overview
Area	                         Technology
Mobile Application	             Flutter
Programming Language	         Dart
Authentication	                 Firebase Authentication
Database	                     Cloud Firestore
Artificial Intelligence	         Firebase AI Logic + Gemini
Voice Processing	             Speech-to-Text
Image Storage	                 Cloudinary
State Management	             Provider
Navigation	                     GoRouter


6. Design Approach

The application follows a modular structure so that individual application responsibilities can be developed and maintained separately.

The major areas are:

User Interface
      ↓
Application Flow
      ↓
Domain Services
      ↓
Firebase / Cloud Services
      ↓
External AI and Media Services

The architecture allows individual capabilities such as pricing, matching, image handling, authentication and catalog generation to remain separated from the user interface.

7. Artisan-Centered Design

The application is designed around reducing the amount of technical knowledge required from the artisan.

Instead of requiring the user to understand complex digital commerce terminology, CraftMitra presents the major activities as a guided workflow.

The artisan provides the basic product information, reviews the generated information and remains responsible for the final product details before publishing.

8. Current Implementation

The current development version contains the core mobile application structure and major product workflows.

The repository contains the Flutter source code together with supporting documentation, architecture diagrams, development records and testing information.

Further development is planned for production-level security hardening, broader language support, external marketplace integrations and additional business capabilities.