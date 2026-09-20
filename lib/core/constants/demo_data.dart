import '../../models/models.dart';

/// All demo/mock data used in the CraftMitra prototype.
/// Matches CRAFTMITRA_HANDOFF.md and DESIGN.md specifications exactly.
class DemoData {
  DemoData._();

  // ─── Demo Image Assets ───
  static const rawPotImageUrl =
      'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=800&auto=format&fit=crop&q=80';
  static const enhancedPotImageUrl =
      'https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?w=800&auto=format&fit=crop&q=80';

  // ─── Artisan ───
  static const artisan = Artisan(
    id: 'RJ-4091',
    name: 'Ramprasad Sharma',
    craft: 'Traditional Pottery / Terracotta',
    location: 'Alwar',
    state: 'Rajasthan',
    registrationId: 'Rajasthan Khadi Crafts #RJ-4091',
    isVerified: true,
  );

  // ─── Products ───
  static final products = <Product>[
    Product(
      id: 'CM-4091',
      name: 'Handcrafted Terracotta Vase',
      nameHindi: 'हस्तनिर्मित टेराकोटा फूलदान',
      description:
          'Beautiful handcrafted terracotta flower pot created using generational wheel pottery techniques. Baked at 900°C for exceptional durability, eco-friendly natural cooling, and an authentic earthy finish suited for living rooms and gardens.',
      category: 'Home Decor',
      craftTechnique: 'Wheel Pottery',
      material: 'Natural River Clay',
      origin: 'Rajasthan, India',
      price: 850,
      views: 124,
      orders: 8,
      status: ProductStatus.published,
      keywords: [
        '#terracotta',
        '#handmade',
        '#wheelpottery',
        '#ecofriendly',
        '#indiancraft',
        '#alwarclay',
      ],
      createdAt: DateTime(2024, 9, 1),
    ),
    Product(
      id: 'CM-4092',
      name: 'Clay Traditional Diya Set (6 Pcs)',
      nameHindi: 'मिट्टी का पारंपरिक दीया सेट',
      description: 'Set of six festive traditional clay diya lamps with delicate petal cuts.',
      category: 'Festive Decor',
      craftTechnique: 'Hand Molding',
      material: 'Natural Clay',
      origin: 'Rajasthan, India',
      price: 420,
      views: 89,
      orders: 14,
      status: ProductStatus.published,
      keywords: ['#diya', '#festival', '#diwali', '#clay', '#handmade'],
      createdAt: DateTime(2024, 8, 20),
    ),
    Product(
      id: 'CM-4093',
      name: 'Hand-painted Clay Pitcher',
      nameHindi: 'हाथ से पेंट किया हुआ मिट्टी का घड़ा',
      description: 'Hand-painted water pitcher with tribal white folk motifs.',
      category: 'Kitchenware',
      craftTechnique: 'Wheel Pottery',
      material: 'Red Clay',
      origin: 'Rajasthan, India',
      price: 650,
      views: 0,
      orders: 0,
      status: ProductStatus.draft,
      keywords: ['#pitcher', '#handpainted', '#tribal', '#clay'],
      createdAt: DateTime(2024, 9, 4),
    ),
  ];

  // Draft in-progress product
  static const draftProduct = Product(
    id: 'CM-4094',
    name: 'Terracotta Decorative Flower Pot',
    nameHindi: 'मिट्टी का सजावटी गमला',
    description: '',
    category: 'Home Decor',
    craftTechnique: 'Wheel Pottery',
    material: 'Natural River Clay',
    origin: 'Rajasthan, India',
    price: 0,
    status: ProductStatus.draft,
    completionPercent: 0.75,
  );

  // ─── Generated Catalog (demo) ───
  static const demoCatalog = GeneratedCatalog(
    title: 'Handcrafted Terracotta Decorative Flower Pot',
    titleHindi: 'हस्तनिर्मित टेराकोटा नक्काशीदार फूलदान',
    category: 'Home Decor',
    craftTechnique: 'Wheel Pottery',
    material: 'Natural River Clay',
    origin: 'Rajasthan, India',
    description:
        'Beautiful handcrafted terracotta flower pot created using generational wheel pottery techniques. Baked at 900°C for exceptional durability, eco-friendly natural cooling, and an authentic earthy finish suited for living rooms and gardens.',
    keywords: [
      '#terracotta',
      '#handmade',
      '#wheelpottery',
      '#ecofriendly',
      '#indiancraft',
      '#alwarclay',
    ],
  );

  // ─── Demo Voice Transcript ───
  static const demoTranscript =
      'यह हाथ से बना मिट्टी का सजावटी गुलदस्ता है। इसे हमने अलवर की नदी किनारे की लाल मिट्टी से चाक पर तैयार किया है, और 900 डिग्री पर पकाया है...';

  // ─── Pricing ───
  static const demoPricing = PricingBreakdown(
    rawMaterial: 250,
    rawMaterialLabel: 'Clay, kiln fuel',
    craftLabor: 270,
    craftLaborLabel: '3.5h artisan effort',
    packaging: 80,
    packagingLabel: 'Straw & carton',
  );

  // ─── Buyers ───
  static const buyers = <Buyer>[
    Buyer(
      id: 'B-001',
      name: 'Dakshin Living & Home Decor',
      location: 'Chennai',
      state: 'Tamil Nadu',
      distanceKm: 350,
      matchPercent: 94,
      rating: 4.9,
      completedOrders: 38,
      requirement: '50 – 100 units for Diwali',
      budgetRange: '₹800 – ₹900',
      isVerified: true,
      verificationLabel: 'Verified Enterprise',
      matchReasons: [
        'Terracotta Craft Specialization',
        '50% advance via escrow',
        'Budget fits ₹850 sweetspot',
      ],
      preferredCategories: ['Home Decor', 'Terracotta', 'Pottery'],
      preferredMaterials: ['Terracotta', 'Clay', 'Natural River Clay'],
      preferredTechniques: ['Handmade', 'Wheel-thrown', 'Wheel Pottery'],
      minBudget: 800,
      maxBudget: 900,
      minQuantity: 20,
      maxQuantity: 100,
      region: 'South India',
    ),
    Buyer(
      id: 'B-002',
      name: 'Sanskriti Craft Exports',
      location: 'Bengaluru',
      state: 'Karnataka',
      distanceKm: 420,
      matchPercent: 89,
      rating: 4.7,
      completedOrders: 22,
      requirement: '200 units',
      budgetRange: '₹780 – ₹950',
      isVerified: true,
      verificationLabel: 'Verified Global Exporter',
      matchReasons: [
        'Recurring export contract',
        'High volume buyer',
        'Verified exporter status',
      ],
      preferredCategories: ['Craft', 'Home Decor', 'Pottery'],
      preferredMaterials: ['Clay', 'Terracotta'],
      preferredTechniques: ['Traditional Handmade', 'Wheel Pottery'],
      minBudget: 780,
      maxBudget: 950,
      minQuantity: 20,
      maxQuantity: 200,
      region: 'South India',
    ),
    Buyer(
      id: 'B-003',
      name: 'Artisan Earth Boutique',
      location: 'Mumbai',
      state: 'Maharashtra',
      distanceKm: 650,
      matchPercent: 82,
      rating: 4.5,
      completedOrders: 15,
      requirement: '30 – 50 units',
      budgetRange: '₹900 – ₹1,000',
      isVerified: true,
      verificationLabel: 'Verified Retailer',
      matchReasons: [
        'Premium retail pricing',
        'Eco-friendly brand focus',
      ],
      preferredCategories: ['Home Decor'],
      preferredMaterials: ['Clay', 'Terracotta'],
      preferredTechniques: ['Handmade', 'Wheel Pottery'],
      minBudget: 900,
      maxBudget: 1000,
      minQuantity: 10,
      maxQuantity: 50,
      region: 'West India',
    ),
    Buyer(
      id: 'B-004',
      name: 'Heritage Home Studio',
      location: 'Delhi',
      state: 'NCR',
      distanceKm: 160,
      matchPercent: 78,
      rating: 4.3,
      completedOrders: 12,
      requirement: '20 – 40 units',
      budgetRange: '₹850 – ₹950',
      isVerified: true,
      verificationLabel: 'Verified B2B',
      matchReasons: [
        'Interior design studio',
        'Repeat order potential',
      ],
      preferredCategories: ['Home Decor', 'Pottery'],
      preferredMaterials: ['Clay', 'Terracotta'],
      preferredTechniques: ['Traditional Handmade', 'Handmade'],
      minBudget: 850,
      maxBudget: 950,
      minQuantity: 10,
      maxQuantity: 50,
      region: 'North India',
    ),
    Buyer(
      id: 'B-005',
      name: 'Jaipur Heritage Emporium',
      location: 'Jaipur',
      state: 'Rajasthan',
      distanceKm: 140,
      matchPercent: 91,
      rating: 4.8,
      completedOrders: 45,
      requirement: '50 – 150 units for festive season',
      budgetRange: '₹750 – ₹900',
      isVerified: true,
      verificationLabel: 'Verified State Partner',
      matchReasons: [
        'Local Rajasthan cluster synergy',
        'Bulk festive order pipeline',
      ],
      preferredCategories: ['Home Decor', 'Terracotta', 'Pottery'],
      preferredMaterials: ['Terracotta', 'Natural River Clay', 'Clay'],
      preferredTechniques: ['Wheel Pottery', 'Traditional Handmade'],
      minBudget: 750,
      maxBudget: 900,
      minQuantity: 30,
      maxQuantity: 150,
      region: 'North India',
    ),
    Buyer(
      id: 'B-006',
      name: 'Ananya Craft Curations',
      location: 'Kolkata',
      state: 'West Bengal',
      distanceKm: 1200,
      matchPercent: 84,
      rating: 4.6,
      completedOrders: 19,
      requirement: '30 – 80 units',
      budgetRange: '₹800 – ₹1,000',
      isVerified: true,
      verificationLabel: 'Verified Boutique',
      matchReasons: [
        'Artisan boutique focus',
        'Direct escrow payout',
      ],
      preferredCategories: ['Home Decor', 'Craft'],
      preferredMaterials: ['Clay', 'Terracotta'],
      preferredTechniques: ['Handmade', 'Wheel Pottery'],
      minBudget: 800,
      maxBudget: 1000,
      minQuantity: 20,
      maxQuantity: 80,
      region: 'East India',
    ),
    Buyer(
      id: 'B-007',
      name: 'Malabar Living Collective',
      location: 'Kochi',
      state: 'Kerala',
      distanceKm: 1900,
      matchPercent: 86,
      rating: 4.7,
      completedOrders: 28,
      requirement: '50 – 120 units',
      budgetRange: '₹850 – ₹950',
      isVerified: true,
      verificationLabel: 'Verified Enterprise',
      matchReasons: [
        'Eco-resort procurement contract',
        'Regular replenishment cycle',
      ],
      preferredCategories: ['Home Decor', 'Living', 'Pottery'],
      preferredMaterials: ['Terracotta', 'Clay'],
      preferredTechniques: ['Handmade', 'Wheel-thrown'],
      minBudget: 850,
      maxBudget: 950,
      minQuantity: 30,
      maxQuantity: 120,
      region: 'South India',
    ),
  ];

  // ─── Orders ───
  static final orders = <CraftOrder>[
    CraftOrder(
      id: '#CM-8821',
      buyerName: 'Dakshin Living',
      buyerLocation: 'Chennai, Tamil Nadu',
      productName: 'Handcrafted Terracotta Flower Pot',
      quantity: 50,
      pricePerUnit: 850,
      totalValue: 42500,
      currentStatus: OrderStatus.inProduction,
      statusLabel: 'Accepted & In Production',
      readyCount: 38,
      totalCount: 50,
      timeline: const [
        OrderTimelineStep(
          title: '1. Order Placed',
          subtitle: 'Digital contract locked via CraftMitra Escrow',
          date: '12 Oct',
          status: OrderStatus.placed,
        ),
        OrderTimelineStep(
          title: '2. Accepted by Artisan',
          subtitle: 'Clay batch prepared at Alwar workshop',
          date: '13 Oct',
          status: OrderStatus.accepted,
        ),
        OrderTimelineStep(
          title: '3. Kiln Curing & Packaging',
          subtitle:
              'Final firing completed; straw-box packing ongoing (38/50 ready)',
          date: 'In Progress',
          status: OrderStatus.inProduction,
        ),
        OrderTimelineStep(
          title: '4. Pickup by Logistics Mitra',
          subtitle: 'Partner: Delhivery Rural Hub Jaipur',
          date: 'Est. 18 Oct',
          status: OrderStatus.pickup,
        ),
        OrderTimelineStep(
          title: '5. Delivery & Payment Release',
          subtitle: '₹42,500 directly transferred into SBI A/c',
          date: 'Est. 21 Oct',
          status: OrderStatus.delivered,
        ),
      ],
    ),
    CraftOrder(
      id: '#CM-8820',
      buyerName: 'Artisan Earth Boutique',
      buyerLocation: 'Mumbai, Maharashtra',
      productName: 'Clay Traditional Diya Set (6 Pcs)',
      quantity: 200,
      pricePerUnit: 420,
      totalValue: 84000,
      currentStatus: OrderStatus.delivered,
      statusLabel: 'Delivered & Paid',
    ),
    CraftOrder(
      id: '#CM-8819',
      buyerName: 'Heritage Home Studio',
      buyerLocation: 'Delhi, NCR',
      productName: 'Handcrafted Terracotta Vase',
      quantity: 30,
      pricePerUnit: 850,
      totalValue: 25500,
      currentStatus: OrderStatus.delivered,
      statusLabel: 'Delivered & Paid',
    ),
  ];

  // ─── Sales Data ───
  static const salesData = SalesData(
    totalEarnings: 124500,
    growthPercent: 22,
    thisMonth: 28400,
    totalOrders: 32,
    totalPieces: 147,
    monthlySales: [
      MonthlySales(month: 'May', amount: 14000),
      MonthlySales(month: 'Jun', amount: 18000),
      MonthlySales(month: 'Jul', amount: 21000),
      MonthlySales(month: 'Aug', amount: 24000),
      MonthlySales(month: 'Sep', amount: 28400),
    ],
    aiInsight:
        '📈 +35% Growth: Your pottery sales surged after AI translated listings into English and Tamil!',
  );

  // ─── KPI Data ───
  static const int activeProducts = 24;
  static const int activeOrders = 8;
  static const double pendingAmount = 42500;
  static const double monthlySalesValue = 18450;
  static const int verifiedBuyers = 12;

  // ─── AI Assistant Demo Responses ───
  static const aiResponses = <String, String>{
    'Which buyer pays fastest?':
        'Based on your recent orders, Dakshin Living has the fastest payment history — average 3 days after delivery confirmation. They have paid on-time for all 38 orders.',
    'How many pots left in stock?':
        'You currently have 24 active products listed. For the Terracotta Flower Pot order #CM-8821, 38 out of 50 units are ready. 12 units still in kiln curing.',
    'Download GST/UPI invoice':
        'Invoice #CM-INV-8821 has been generated for Dakshin Living order (₹42,500). The GST-compliant PDF is ready for download. UPI payment reference: CRAFT-2024-8821.',
  };

  // ─── AI Processing Steps ───
  static const aiProcessingSteps = <String>[
    'Analyzing product image...',
    'Understanding artisan voice...',
    'Generating catalog...',
    'Finding market price...',
    'Finding buyers...',
  ];

  static const aiProcessingResults = <String>[
    'Product detected',
    'Hindi speech recognized',
    'Description created',
    'Market data analyzed',
    'Buyers matched',
  ];
}
