# CRAFTMITRA — PROJECT HANDOFF

## 1. PROJECT IDENTITY

Project Name:

CRAFTMITRA

Tagline:

"Your Craft. Your Business. Your Digital Mitra."

Secondary tagline:

"Create. Connect. Grow."

Positioning:

AI-powered virtual business manager for marginalized Indian artisans.

Core Journey:

SHOW → SPEAK → AI → PRICE → MATCH → SELL


## 2. SIH CONTEXT

SIH 2026 Problem Statement:

SIH26090

Title:

AI-Driven Market Linkage and Smart Cataloging Mobile Application
for Marginalized Artisans

Organization:

Ministry of Social Justice and Empowerment

Department:

Department of Social Justice and Empowerment

Theme:

Heritage & Culture

Category:

Software

The goal is to help marginalized artisans digitize products,
create professional catalogs, get fair pricing guidance,
find suitable buyers and sell beyond periodic fairs.


## 3. CURRENT PROJECT STATUS

The Flutter project already exists.

DO NOT create a new Flutter project.

The project currently contains:

- Flutter project
- Android project
- lib/
- test/
- pubspec.yaml
- README.md
- DESIGN.md

DESIGN.md is the primary UI/UX implementation specification.

The Stitch MCP connection was successfully tested in the
previous Antigravity account.


## 4. GOOGLE STITCH

Stitch project:

CraftMitra: Artisan Business Manager

Stitch Project ID:

projects/3067496545963948862

Stitch project is PRIVATE.

Stitch MCP was successfully connected.

The Stitch project contains:

- 4 major high-fidelity mobile screens
- CraftMitra emblem
- Artisan portrait
- product imagery
- buyer imagery
- complete design system
- HTML/CSS implementation
- design metadata

The Stitch MCP is the PRIMARY visual source of truth.

Read DESIGN.md before implementing UI.

Do NOT redesign the UI.


## 5. DESIGN SOURCE PRIORITY

When making UI decisions, use this priority:

1. Actual Stitch design
2. DESIGN.md
3. Product requirements
4. Implementation assumptions

Never replace the Stitch design with generic Flutter UI.

Preserve:

- colors
- typography
- spacing
- cards
- buttons
- navigation
- bilingual patterns
- AI components
- voice UI
- image studio
- pricing UI
- buyer matching UI
- order timeline
- sales dashboard


## 6. DESIGN SYSTEM

Primary:

#9F3C16

Primary Container:

#BF542C

Secondary:

#2A6A48

Secondary Container:

#ACEEC4

Tertiary:

#8D4B00

Background:

#FFF8F5

Surface:

#FFF8F5

On Surface:

#251911

On Surface Variant:

#57423B

Outline:

#8A726A

Outline Variant:

#DEC0B7

Error:

#BA1A1A

Heading font:

Epilogue

Body font:

Noto Sans

Minimum interactive target:

48 × 48 logical pixels

See DESIGN.md for the complete design system.


## 7. STITCH SCREENS

The 4 major Stitch screens are:

1. Artisan Home Dashboard

2. AI Image & Voice Catalog Studio

3. AI Smart Pricing & Buyer Match

4. Orders Tracking & Business Sales

These tall screens contain the equivalent of many logical
Flutter screens/features.

Do not assume that only four Flutter routes are required.


## 8. CORE PRODUCT FLOW

The most important demo flow is:

Home
 ↓
Add Product
 ↓
Image Studio
 ↓
Voice Description
 ↓
AI Processing
 ↓
Generated Catalog
 ↓
Smart Pricing
 ↓
Buyer Match
 ↓
Publish & Broadcast
 ↓
Buyer Inquiry
 ↓
Order
 ↓
Order Tracking
 ↓
Sales Analytics


## 9. DEMO PRIORITY

This is currently a college/SIH selection prototype.

Priority:

1. High visual fidelity
2. Complete navigation
3. Complete end-to-end demo
4. Reliable offline/demo behavior
5. Realistic data
6. AI-like interactions
7. Accessibility
8. Future backend readiness

Do NOT spend this milestone building production backend infrastructure.


## 10. DEMO FALLBACK REQUIREMENT

The application must work during the demo without:

- internet
- Gemini API
- backend
- Supabase
- microphone permissions
- camera permissions
- external marketplace APIs

Provide:

"Use Demo Product"

and

"Use Demo Voice"

fallbacks.

If camera permission fails:

allow Demo Product.

If microphone permission fails:

allow Demo Voice.

If network/API fails:

use local demo AI response.

The demo must never get stuck because of a permission,
network or API problem.


## 11. TECHNOLOGY

Frontend:

Flutter + Dart

State management:

Provider

Navigation:

GoRouter

Charts:

fl_chart

Fonts:

Google Fonts

Future backend:

Python + FastAPI

Future database:

Supabase PostgreSQL

Future authentication:

Supabase Auth

Future storage:

Supabase Storage

Future AI:

Gemini through FastAPI

Repository/service architecture should allow these to be
integrated later.


## 12. IMPORTANT ARCHITECTURE PRINCIPLE

Keep the architecture modular but simple.

Suggested:

lib/
  core/
  models/
  repositories/
  services/
  providers/
  features/

Feature areas:

- home
- products
- product_creation
- image_studio
- voice_catalog
- pricing
- buyers
- orders
- sales
- ai_assistant
- profile


## 13. DEMO ARTISAN

Name:

Ramprasad Sharma

Craft:

Traditional Pottery / Terracotta

Location:

Rajasthan

Use realistic Indian artisan/business data.

Do not replace this with lorem ipsum or random fake
corporate content.


## 14. DEMO PRICING

Raw Material:

₹250

Craft Labor:

₹270

Packaging:

₹80

Base Cost:

₹600

Default Margin:

30%

AI Recommended Price:

₹850

Market Range:

₹750 – ₹950


## 15. DEMO BUYERS

Buyer 1:

Dakshin Living & Home Decor

Location:

Chennai, Tamil Nadu

Match:

94%

Requirement:

50–100 units

Budget:

₹800–₹900

Buyer 2:

Sanskriti Craft Exports

Location:

Bengaluru, Karnataka

Match:

89%

The buyer matching UI must show transparent reasons
for the match.


## 16. DEMO ORDER

Order:

#CM-8821

Buyer:

Dakshin Living

Product:

Handcrafted Terracotta Flower Pot

Quantity:

50

Price:

₹850 per piece

Total:

₹42,500

Status:

Accepted & In Production

Timeline:

1. Order Placed
2. Accepted by Artisan
3. Kiln Curing & Packaging
4. Pickup by Logistics Mitra
5. Delivery & Payment Release


## 17. SALES DEMO

Total Earnings:

₹1,24,500

This Month:

₹28,400

Total Orders:

32

Craft Pieces:

147

Growth:

+22%

Monthly:

May ₹14k
Jun ₹18k
Jul ₹21k
Aug ₹24k
Sep ₹28.4k


## 18. REQUIRED REUSABLE COMPONENTS

At minimum:

CraftMitraAppBar
CraftBottomNav
VoiceMicButton
AudioWaveformVisualizer
KpiCard
ProductCard
BuyerCard
PricingCard
AiRecommendationCard
StatusBadge
MatchScoreBadge
ImageBeforeAfterSlider
CostBreakdownGrid
MarginSliderCard
OrderTimelineStepper
SalesBarChart
PrimaryButton
SecondaryButton
LanguageSwitcher
AiProcessingIndicator


## 19. CRITICAL QUALITY RULE

There must be:

- no broken routes
- no dead buttons
- no broken images
- no RenderFlex overflow
- no crash on permission denial
- no crash offline
- no blank screens
- no placeholder lorem ipsum

The complete demo flow must work.


## 20. CURRENT NEXT STEP

Before implementing:

1. Read DESIGN.md completely.
2. Inspect the existing Flutter project.
3. Inspect Stitch through MCP if necessary.
4. Review the existing implementation plan.
5. Continue implementation from the existing project.
6. Do NOT create a new project.

The previous Antigravity account already verified that Stitch MCP
can access the CraftMitra project.

The new account must verify its own Stitch MCP connection before
implementation.


## 21. IMPORTANT

This file is a HANDOFF document.

Do not blindly recreate the project.

Inspect what already exists first.

Preserve working code.

Modify only what is necessary.

Use DESIGN.md as the UI source of truth.

Continue from the current project state.