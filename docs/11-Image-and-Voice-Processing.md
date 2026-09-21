# 11 — Image and Voice Processing

## Overview

CraftMitra uses image and voice input to reduce the amount of
typing required during product creation.

The two inputs are processed separately and then used during
catalog generation.

## Image Processing Flow

Product Image
      ↓
Image Studio
      ↓
Image Handling / Enhancement
      ↓
Cloudinary
      ↓
Product Catalog

Implementation:

Image Studio
Image Enhancement Service
Image Picker Service
Cloudinary Service
Voice Processing Flow
Artisan Voice
      ↓
Voice Recording
      ↓
Speech-to-Text
      ↓
Product Description
      ↓
AI Catalog Processing

Implementation:

Voice Catalog
Voice Recording Service
Speech-to-Text
Combined Input Flow
             Product Image
                   ↓
              Image Studio
                   ↓
             Image Processing
                   │
                   ├──────────┐
                              ↓
Artisan Voice → Speech-to-Text → AI Catalog Processing
                              ↓
                     Structured Product Data
Key Benefits
Reduces manual typing.
Supports a simple product creation workflow.
Allows artisans to provide product information naturally.
Combines visual product information with the artisan's description.
Current Scope

Image and voice processing are integrated into the product creation
workflow and provide the input required for AI-assisted catalog generation.