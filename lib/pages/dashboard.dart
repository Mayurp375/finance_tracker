import 'package:finance_tracker/pages/add_expence.dart';
import 'package:finance_tracker/pages/add_income.dart';
import 'package:finance_tracker/pages/data_manager.dart';
import 'package:finance_tracker/provider/provider.dart';
import 'package:finance_tracker/service/database_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedPeriod = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    await provider.loadSummary(_selectedPeriod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _showPeriodPicker,
            tooltip: 'Change Period',
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DataManagerScreen()),
            ),
            tooltip: 'Manage Data',
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, child) {
          return _buildBody(finance);
        },
      ),
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  Widget _buildBody(FinanceProvider finance) {
    if (finance.summary.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final summary = finance.summary;
    if (summary.isEmpty) {
      return Center(child: Text('No data available'));
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(summary),
            SizedBox(height: 24),
            _buildPieChart(finance),
            SizedBox(height: 24),
            _buildSavingsProgress(finance),
            SizedBox(height: 24),
            _buildInsights(summary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    final income = _safeDouble(summary['income'] ?? 0);
    final expenses = _safeDouble(summary['expenses'] ?? 0);
    final balance = _safeDouble(summary['balance'] ?? 0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.white]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow('Income', income, Colors.green),
          SizedBox(height: 16),
          _buildStatRow('Expenses', expenses, Colors.red),
          SizedBox(height: 16),
          _buildStatRow(
            'Balance',
            balance,
            balance >= 0 ? Colors.green : Colors.red,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    double amount,
    Color color, {
    bool isLarge = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, color: color.withOpacity(0.8)),
              ),
              Text(
                '₹${_format(amount)}',
                style: TextStyle(
                  fontSize: isLarge ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.trending_up, color: color.withOpacity(0.5)),
      ],
    );
  }

  Widget _buildPieChart(FinanceProvider finance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Breakdown',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 16),
        Container(
          height: 220,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1)),
            ],
          ),
          child: finance.pieSections.isEmpty
              ? Center(child: Text('No expenses yet'))
              : PieChart(PieChartData(sections: finance.pieSections)),
        ),
      ],
    );
  }

  Widget _buildSavingsProgress(FinanceProvider finance) {
    final goals = finance.savingsGoals;

    if (goals.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.savings_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No savings goals set',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _showAddGoalDialog,
                icon: Icon(Icons.add),
                label: Text('Set First Goal'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Savings Goals', style: Theme.of(context).textTheme.headlineSmall),
            ElevatedButton.icon(
              onPressed: _showAddGoalDialog,
              icon: Icon(Icons.add),
              label: Text('Add Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ...goals.map((goal) => _buildGoalCard(goal)),
      ],
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final current = _safeDouble(goal['current_amount'] ?? 0);
    final target = _safeDouble(goal['target_amount'] ?? 1);
    final progress = (current / target * 100).clamp(0.0, 100.0);
    final isCompleted = progress >= 100;
    final remaining = target - current;

    // Calculate expected completion
    String expectedCompletion = '';
    if (!isCompleted && goal['created_at'] != null) {
      final createdAt = DateTime.parse(goal['created_at']);
      final monthsElapsed = DateTime.now().difference(createdAt).inDays / 30.0;
      if (monthsElapsed > 0 && current > 0) {
        final monthlyRate = current / monthsElapsed;
        final remainingMonths = remaining / monthlyRate;
        final expectedDate = DateTime.now().add(Duration(days: (remainingMonths * 30).round()));
        expectedCompletion = 'Expected: ${DateFormat('MMM yyyy').format(expectedDate)}';
      }
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalHeader(goal['name'], target, progress, isCompleted, expectedCompletion),
            SizedBox(height: 20),
            _buildProgressBar(progress, isCompleted),
            SizedBox(height: 16),
            _buildGoalStatus(
              progress,
              isCompleted,
              remaining,
              goal['name'],
            ),
            SizedBox(height: 16),
            _buildGoalActions(goal),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalHeader(
    String name,
    double target,
    double progress,
    bool isCompleted,
    String expectedCompletion,
  ) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isCompleted
                  ? [Colors.green[400]!, Colors.green[600]!]
                  : [Colors.blue[400]!, Colors.blue[600]!],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: Icon(
            isCompleted ? Icons.check_circle : Icons.savings,
            color: Colors.white,
            size: 28,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Target: ₹${_format(target)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              if (expectedCompletion.isNotEmpty)
                Text(
                  expectedCompletion,
                  style: TextStyle(color: Colors.blue[600], fontSize: 12),
                ),
            ],
          ),
        ),
        Text(
          '${progress.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isCompleted ? Colors.green[700] : Colors.blue[700],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: FractionallySizedBox(
            widthFactor: (progress / 100).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCompleted
                      ? [Colors.green[400]!, Colors.green[700]!]
                      : [Colors.blue[400]!, Colors.blue[700]!],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          _getProgressVisual(progress),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalStatus(
    double progress,
    bool isCompleted,
    double remaining,
    String name,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isCompleted ? Colors.green : Colors.blue),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.thumb_up : Icons.info_outline,
            color: isCompleted ? Colors.green[700] : Colors.blue[700],
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              _getGoalMessage(progress, isCompleted, remaining, name),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalActions(Map<String, dynamic> goal) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showGoalDetails(goal),
            icon: Icon(Icons.visibility),
            label: Text('Details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _addQuickContribution(goal, 5000),
            icon: Icon(Icons.add),
            label: Text('Add ₹5K'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsights(Map<String, dynamic> summary) {
    final categories = Map<String, double>.from(summary['categories'] ?? {});
    final income = _safeDouble(summary['income'] ?? 0);
    final expenses = _safeDouble(summary['expenses'] ?? 0);
    final balance = _safeDouble(summary['balance'] ?? 0);

    List<Widget> insights = [];

    // Real dynamic insights based on ACTUAL data
    if (income > 0) {
      // Travel spending analysis
      final travel = categories['Travel'] ?? 0;
      if (travel > 0) {
        final travelPct = (travel / income) * 100;
        if (travelPct > 15) {
          insights.add(
            _buildInsightCard(
              Icons.warning_amber,
              Colors.orange,
              '⚠️ Travel ${travelPct.toStringAsFixed(0)}% of income',
            ),
          );
        }
      }

      // Food spending analysis
      final food = categories['Food'] ?? 0;
      if (food > 0) {
        final foodPct = (food / income) * 100;
        if (foodPct > 20) {
          insights.add(
            _buildInsightCard(
              Icons.restaurant,
              Colors.orange,
              '🍔 Food ${foodPct.toStringAsFixed(0)}% - consider home cooking',
            ),
          );
        }
      }

      // Savings rate
      final savingsRate = ((balance / income) * 100).clamp(0.0, 100.0);
      if (savingsRate > 30) {
        insights.add(
          _buildInsightCard(
            Icons.thumb_up,
            Colors.green,
            '💰 Excellent! Saving ${savingsRate.toStringAsFixed(0)}% of income',
          ),
        );
      } else if (savingsRate > 10) {
        insights.add(
          _buildInsightCard(
            Icons.trending_up,
            Colors.blue,
            '👍 Good savings: ${savingsRate.toStringAsFixed(0)}% of income',
          ),
        );
      } else {
        insights.add(
          _buildInsightCard(
            Icons.savings,
            Colors.amber,
            '💡 Aim to save 20%+ of ₹${_format(income)} income',
          ),
        );
      }
    }

    // No data insights
    if (insights.isEmpty && expenses == 0) {
      insights.add(
        _buildInsightCard(
          Icons.analytics,
          Colors.grey,
          '📊 Add expenses to see insights',
        ),
      );
    }

    return Column(
      children: insights.isEmpty
          ? [
              _buildInsightCard(
                Icons.info,
                Colors.grey,
                'No significant trends',
              ),
            ]
          : insights,
    );
  }

  Widget _buildInsightCard(IconData icon, Color color, String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'add_expense',
          onPressed: () =>
              _navigateToScreen(AddExpenseScreen(), after: _loadData),
          backgroundColor: Colors.red[400],
          tooltip: 'Add Expense',
          child: Icon(Icons.add_shopping_cart),
        ),
        SizedBox(height: 12),
        FloatingActionButton(
          heroTag: 'add_income',
          onPressed: () =>
              _navigateToScreen(AddIncomeScreen(), after: _loadData),
          backgroundColor: Colors.green[600],
          tooltip: 'Add Income',
          child: Icon(Icons.account_balance_wallet),
        ),
      ],
    );
  }

  void _navigateToScreen(Widget screen, {VoidCallback? after}) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((
      _,
    ) {
      after?.call();
    });
  }

  // Dialog Methods
  void _showPeriodPicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedPeriod,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() => _selectedPeriod = DateTime(date.year, date.month));
        _loadData();
      }
    });
  }

  void _showAddGoalDialog() {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime? selectedDeadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('New Savings Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Goal Name'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Target Amount (₹)'),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('Deadline: '),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365 * 10)),
                      );
                      if (picked != null) {
                        setState(() => selectedDeadline = picked);
                      }
                    },
                    child: Text(
                      selectedDeadline != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDeadline!)
                          : 'Select Date',
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    targetController.text.isEmpty ||
                    selectedDeadline == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }
                try {
                  await DatabaseHelper.addNewSavingsGoal(
                    nameController.text,
                    double.parse(targetController.text),
                    selectedDeadline!,
                  );
                  await _loadData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Goal created successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: Text('Create Goal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDetails(Map<String, dynamic> goal) {
    final current = _safeDouble(goal['current_amount'] ?? 0);
    final target = _safeDouble(goal['target_amount'] ?? 1);
    final progress = (current / target * 100).clamp(0.0, 100.0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${goal['name']} Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: (progress / 100).clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildDetailRow('Target', _format(target)),
            _buildDetailRow('Saved', _format(current)),
            _buildDetailRow('Remaining', _format(target - current)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _addQuickContribution(
    Map<String, dynamic> goal,
    double amount,
  ) async {
    try {
      await DatabaseHelper.addSavingsContribution(goal['name'], amount);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added ₹${_format(amount)} to ${goal['name']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding contribution: $e')));
    }
  }

  // Helper Methods
  double _safeDouble(dynamic value) => (value is num ? value.toDouble() : 0.0);

  String _getProgressVisual(double progress) {
    final blocks = (progress / 10).floor().clamp(0, 6);
    return '${'█' * blocks}${'░' * (6 - blocks)}';
  }

  String _getGoalMessage(
    double progress,
    bool isCompleted,
    double remaining,
    String name,
  ) {
    if (isCompleted) return '✅ Good job! $name complete!';
    if (progress > 80)
      return '🎉 Almost there! Just ₹${_format(remaining)} left';
    if (progress > 50) return '👍 Great progress on $name';
    if (progress > 0) return '📈 Started $name - keep going!';
    return '💡 Set monthly target for $name';
  }

  String _format(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}
