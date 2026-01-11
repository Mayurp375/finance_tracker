import 'package:finance_tracker/provider/provider.dart';
import 'package:finance_tracker/service/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddIncomeScreen extends StatefulWidget {
  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _amountController = TextEditingController();
  String _type = 'Salary';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Income'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount ₹',
                prefixIcon: Icon(Icons.account_balance_wallet),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _type,
              items: [
                'Salary',
                'Bonus',
                'Freelance',
              ].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (value) => _type = value!,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveIncome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                ),
                child: Text('Save Income', style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveIncome() async {
    if (_amountController.text.isEmpty) return;

    final income = {
      'amount': double.parse(_amountController.text),
      'type': _type,
      'date': DateTime.now().toIso8601String(),
    };

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    await provider.loadSummary(provider.currentPeriod);
    Navigator.pop(context);
  }
}
