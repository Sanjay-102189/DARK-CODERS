# 14 — Technical Decisions

## Technology Selection

CraftMitra uses technologies selected for mobile development,
cloud integration, artificial intelligence and rapid prototyping.

### Flutter and Dart

Used to build the cross-platform mobile application with a
single maintainable codebase.

### Firebase

Used for authentication, cloud database services and
artificial intelligence integration.

### Cloud Firestore

Used to store application data such as products, buyers,
orders and sales information.

### Cloudinary

Used for product image storage and image handling.

### Gemini

Used for artificial intelligence-assisted product information
generation.

### Speech-to-Text

Used to support voice-based product descriptions and reduce
manual typing.

## Architecture Decisions

### Modular Feature Structure

The application is organized into feature-based modules such as
products, orders, buyers, authentication and product creation.

This makes individual features easier to develop and maintain.

### Service-Based Logic

External services and major application operations are separated
into dedicated service classes.

User Interface
      ↓
Providers / Application State
      ↓
Service Layer
      ↓
Firebase / Cloudinary / AI Services


Explainable Application Logic

Smart Pricing and Buyer Matching use explainable application logic
so that their results can be understood and reviewed by the artisan.

Design Goal

The technical architecture prioritizes:

Simple user interaction
Maintainable code structure
Cloud integration
Explainable decision support
Future extensibility