import 'package:finance_tracker/service/database_service.dart';
import 'package:flutter/material.dart';

class DataManagerScreen extends StatefulWidget {
  const DataManagerScreen({super.key});

  @override
  createState() => _DataManagerScreenState();
}

class _DataManagerScreenState extends State<DataManagerScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _expenses = [];
  List<Map<String, dynamic>> _income = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }
  
  Future<void> _loadAllData() async {
    final expenses = await DatabaseHelper.getAllExpenses();
    final income = await DatabaseHelper.getAllIncome();
    setState(() {
      _expenses = expenses;
      _income = income;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Data'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.receipt_long), text: 'Expenses'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Income'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExpenseList(),
          _buildIncomeList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadAllData,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Data',
      ),
    );
  }
  
  Widget _buildExpenseList() {
    if (_expenses.isEmpty) {
      return Center(child: Text('No expenses yet'));
    }
    
    return ListView.builder(
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        return Dismissible(
          key: Key(expense['id'].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await _showDeleteDialog('expense');
          },
          onDismissed: (direction) {
            DatabaseHelper.deleteExpense(expense['id']);
            _expenses.removeAt(index);
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(expense['category']),
              child: Text(expense['category'][0], style: TextStyle(color: Colors.white)),
            ),
            title: Text('${expense['category']} - ₹${expense['amount']}'),
            subtitle: Text('${expense['sub_category'] ?? ''} • ${expense['payment_mode'] ?? ''}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editExpense(expense),
                ),
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () => _showExpenseDetails(expense),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildIncomeList() {
    if (_income.isEmpty) {
      return Center(child: Text('No income yet'));
    }
    
    return ListView.builder(
      itemCount: _income.length,
      itemBuilder: (context, index) {
        final incomeItem = _income[index];
        return Dismissible(
          key: Key(incomeItem['id'].toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            return await _showDeleteDialog('income');
          },
          onDismissed: (direction) {
            DatabaseHelper.deleteIncome(incomeItem['id']);
            _income.removeAt(index);
          },
          child: ListTile(
            leading: Icon(Icons.account_balance_wallet, color: Colors.green),
            title: Text('${incomeItem['type']} - ₹${incomeItem['amount']}'),
            subtitle: Text(incomeItem['date']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editIncome(incomeItem),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _editExpense(Map<String, dynamic> expense) async {
    // Navigate to edit screen (same as add but pre-filled)
    // Implementation similar to AddExpenseScreen but with update
  }
  
  Future<void> _editIncome(Map<String, dynamic> income) async {
    // Navigate to edit screen (same as add but pre-filled)
    // Implementation similar to AddIncomeScreen but with update
  }
  
  void _showExpenseDetails(Map<String, dynamic> expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${expense['category']} Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹${expense['amount']}'),
            Text('Category: ${expense['category']}'),
            if (expense['sub_category'] != null) Text('Sub: ${expense['sub_category']}'),
            Text('Date: ${expense['date']}'),
            if (expense['vehicle'] != null) Text('Vehicle: ${expense['vehicle']}'),
            if (expense['liters'] != null) Text('Liters: ${expense['liters']}'),
            Text('Payment: ${expense['payment_mode']}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Close')),
        ],
      ),
    );
  }
  
  Future<bool?> _showDeleteDialog(String type) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete this $type?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Travel': return Colors.blue;
      case 'Diesel': return Colors.green;
      case 'Rent': return Colors.red;
      default: return Colors.grey;
    }
  }
}
