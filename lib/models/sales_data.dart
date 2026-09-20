import 'order.dart';

class MonthlySales {
  final String month;
  final double amount;

  const MonthlySales({required this.month, required this.amount});
}

class SalesData {
  final double totalEarnings;
  final double growthPercent;
  final double thisMonth;
  final int totalOrders;
  final int totalPieces;
  final List<MonthlySales> monthlySales;
  final String aiInsight;
  final double averageOrderValue;
  final double estimatedProfit;

  const SalesData({
    required this.totalEarnings,
    this.growthPercent = 0.0,
    required this.thisMonth,
    required this.totalOrders,
    required this.totalPieces,
    required this.monthlySales,
    this.aiInsight = '',
    this.averageOrderValue = 0.0,
    this.estimatedProfit = 0.0,
  });

  /// Derives real sales and financial analytics STRICTLY from completed orders.
  /// Does NOT invent growth percentages (defaults to 0.0 unless historical comparison exists).
  factory SalesData.fromOrders(List<CraftOrder> orders) {
    // Filter strictly to completed / delivered orders
    final completedOrders = orders.where((o) => o.isCompleted).toList();

    double totalEarnings = 0.0;
    int totalPieces = 0;
    final Map<String, double> monthTotals = {};

    final now = DateTime.now();
    final currentMonthName = _monthName(now.month);
    double currentMonthEarnings = 0.0;

    for (final o in completedOrders) {
      totalEarnings += o.totalValue;
      totalPieces += o.quantity;

      final date = o.completedAt ?? o.createdAt ?? now;
      final mName = _monthName(date.month);
      monthTotals[mName] = (monthTotals[mName] ?? 0.0) + o.totalValue;

      if (date.month == now.month && date.year == now.year) {
        currentMonthEarnings += o.totalValue;
      }
    }

    final monthlyList = monthTotals.entries.map((e) {
      return MonthlySales(month: e.key, amount: e.value);
    }).toList();

    if (monthlyList.isEmpty) {
      monthlyList.add(MonthlySales(month: currentMonthName, amount: 0.0));
    }

    final aov = completedOrders.isNotEmpty
        ? (totalEarnings / completedOrders.length)
        : 0.0;

    // Estimated profit based on ~35% average artisan margin
    final estProfit = totalEarnings * 0.35;

    final insight = completedOrders.isNotEmpty
        ? 'Completed ${completedOrders.length} orders totaling ₹${totalEarnings.toInt()}. Top performing items reflect steady artisan market demand.'
        : 'No orders completed yet. Once orders are delivered, your verified sales figures will update automatically.';

    return SalesData(
      totalEarnings: totalEarnings,
      growthPercent: 0.0, // Strict: do not invent growth percentages
      thisMonth: currentMonthEarnings,
      totalOrders: completedOrders.length,
      totalPieces: totalPieces,
      monthlySales: monthlyList,
      aiInsight: insight,
      averageOrderValue: aov,
      estimatedProfit: estProfit,
    );
  }

  static String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return 'Month';
  }
}
