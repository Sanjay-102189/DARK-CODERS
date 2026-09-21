# 07 — AI Architecture

## AI Overview

CraftMitra uses artificial intelligence to assist artisans in creating
structured product information from images and voice-based descriptions.

The application combines artificial intelligence services with
explainable application logic for pricing and buyer matching.

## AI Processing Flow

Product Image + Voice Description
              ↓
       Speech-to-Text
              ↓
        Product Inputs
              ↓
       Gemini AI Processing
              ↓
   Structured Product Information
              ↓
       Artisan Review
              ↓
    Pricing + Buyer Matching


AI Components
Gemini AI

Gemini is used to assist with product understanding and generation
of structured product information.

Implementation: Firebase AI Logic + Gemini

Speech-to-Text

Voice input is converted into text so artisans can provide product
descriptions without extensive typing.

Implementation: Speech-to-Text

Smart Pricing

Smart Pricing provides an explainable price recommendation using
product-related cost factors.

Implementation: Smart Pricing Service

Approach: Rule-based application logic with AI assistance where applicable.

Buyer Matching

Buyer Matching identifies compatible buyers by comparing product
attributes with buyer requirements.

Implementation: Buyer Matching Service

Approach: Explainable requirement-based matching logic.

AI Design Principle
AI assists the artisan
        ↓
Artisan reviews the result
        ↓
Artisan can edit the information
        ↓
Final information is published

CraftMitra keeps the artisan in control by allowing generated
information to be reviewed and edited before publication.