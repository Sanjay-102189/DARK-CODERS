# 10 — Authentication and Security

## Overview

CraftMitra uses Firebase Authentication for user authentication
and Cloud Firestore for application data.

The application separates authentication from application data
and follows a service-based structure.

## Authentication Flow

User
 ↓
Authentication Screen
 ↓
Firebase Authentication
 ↓
Authenticated Session
 ↓
CraftMitra Application


Authentication

Service: Firebase Authentication

Authentication provides the user login mechanism and identifies
the authenticated artisan within the application.

Data Security

Database: Cloud Firestore

Application data such as products and orders is stored in
Cloud Firestore.

The application uses dedicated services for database operations:

Firestore Product Service
Firestore Order Service
Image Security

Product images are handled through Cloudinary rather than
storing image files directly in the application database.

Security Approach
Authentication
      ↓
Authenticated User
      ↓
Application Services
      ↓
Cloud Firestore
      +
Cloudinary
Current Security Scope
Firebase Authentication for user identity
Cloud Firestore for application data
Cloudinary for product images
Environment and secret files excluded from version control
Application services used for database operations
Security Considerations

Production deployment should additionally include appropriate
Firestore security rules, application protection mechanisms,
restricted cloud credentials and secure image upload configuration.

Security controls should be reviewed before production release.