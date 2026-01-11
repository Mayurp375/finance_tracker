import 'package:finance_tracker/provider/provider.dart';
import 'package:finance_tracker/service/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  String _category = 'Food';
  String _paymentMode = 'UPI';
  String _vehicle = '';
  double? _liters;
  bool _showFuelFields = false;
  
  final List<String> categories = ['Food', 'Travel', 'Diesel', 'Rent', 'Shopping', 'Entertainment'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Expense'), backgroundColor: Colors.blue[800]),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Amount Input (Big)
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount ₹',
                prefixIcon: Icon(Icons.attach_money, size: 30, color: Colors.green),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (value) {
                setState(() {
                  _category = value!;
                  _showFuelFields = value == 'Diesel';
                });
              },
            ),
            
            if (_showFuelFields) ...[
              SizedBox(height: 15),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Vehicle (Bike/Car)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (value) => _vehicle = value,
              ),
              SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Liters',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (value) => _liters = double.tryParse(value),
              ),
            ],
            
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _paymentMode,
              decoration: InputDecoration(
                labelText: 'Payment Mode',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['Cash', 'UPI', 'Card'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (value) => _paymentMode = value!,
            ),
            
            Spacer(),
            // BIG Save Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Save Expense', style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveExpense() async {
    if (_amountController.text.isEmpty) return;
    
    final expense = {
      'amount': double.parse(_amountController.text),
      'category': _category,
      'date': DateTime.now().toIso8601String(),
      'payment_mode': _paymentMode,
      'vehicle': _vehicle,
      'liters': _liters,
    };
    
    await DatabaseHelper.addExpense(expense);
    
    // Refresh dashboard
   final provider = Provider.of<FinanceProvider>(context, listen: false);
  await provider.loadSummary(provider.currentPeriod);
    
    Navigator.pop(context);
  }
}
