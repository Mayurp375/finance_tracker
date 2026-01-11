import 'package:finance_tracker/pages/dashboard.dart';
import 'package:finance_tracker/provider/provider.dart';
import 'package:finance_tracker/service/database_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Add test data ONCE to see dynamic flow
  // await DatabaseHelper.addTestData();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => FinanceProvider(),
      
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker - DYNAMIC',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

