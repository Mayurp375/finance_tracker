import 'package:finance_tracker/service/database_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FinanceProvider with ChangeNotifier {
  Map<String, dynamic> _currentSummary = {};
  DateTime _currentPeriod = DateTime.now();
  List<Map<String, dynamic>> _savingsGoals = []; // ✅ MOVED TO TOP

  // Getters
  Map<String, dynamic> get summary => _currentSummary;

  DateTime get currentPeriod => _currentPeriod;

  List<Map<String, dynamic>> get savingsGoals => _savingsGoals;

  // **DYNAMIC LOAD** - Real DB query every time
  // REPLACE your loadSummary() with this ALWAYS REFRESH version
  Future<void> loadSummary(DateTime period) async {
    print('🔄 Provider forcing FRESH reload...');

    // Get FRESH data every time
    _currentSummary = await DatabaseHelper.getSummary(period);
    _savingsGoals = await DatabaseHelper.getSavingsProgress();

    _currentPeriod = DateTime(period.year, period.month);

    print('✅ Provider refreshed: ${_currentSummary['expenses']} expenses');
    notifyListeners(); // Force UI update
  }

  // **DYNAMIC PIE CHART** - From real DB categories
  List<PieChartSectionData> get pieSections {
    final categories = Map<String, double>.from(
      _currentSummary['categories'] ?? {},
    );
    if (categories.isEmpty) return [];

    final totalExpenses = _currentSummary['expenses'] ?? 1.0;
    return categories.entries.map((entry) {
      final percentage = (entry.value / totalExpenses) * 100;
      return PieChartSectionData(
        value: entry.value,
        title:
            '${entry.key}\n₹${_format(entry.value)}\n${percentage.toStringAsFixed(0)}%',
        color: _getCategoryColor(entry.key),
        radius: 70,
      );
    }).toList();
  }

  // **DYNAMIC INSIGHTS** - Real calculations
  List<String> get insights {
    final categories = Map<String, double>.from(
      _currentSummary['categories'] ?? {},
    );
    final income = _currentSummary['income'] ?? 0.0;
    final travel = categories['Travel'] ?? 0.0;

    List<String> insights = [];

    // Real travel % calculation
    if (travel > 0 && income > 0) {
      final travelPct = (travel / income) * 100;
      if (travelPct > 15) {
        insights.add('⚠️ Travel ${travelPct.toStringAsFixed(0)}% of income');
      }
    }

    if ((_currentSummary['balance'] ?? 0) >
        (_currentSummary['income'] ?? 0) * 0.5) {
      insights.add('👍 Good saving month!');
    }

    return insights;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Travel':
        return Colors.blue;
      case 'Diesel':
        return Colors.green;
      case 'Rent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _format(double value) => '${(value / 1000).toStringAsFixed(1)}K';
}
