import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  // **COMPLETELY DYNAMIC** - Real monthly/yearly summary
  // REPLACE your existing getSummary() with this FRESH version
  static Future<Map<String, dynamic>> getSummary(DateTime period) async {
    final db = await database; // Fresh connection

    final start = DateTime(period.year, period.month, 1).toIso8601String();
    final end = DateTime(
      period.year,
      period.month + 1,
      0,
      23,
      59,
      59,
    ).toIso8601String();

    print('🔥 FRESH DATA for $start to $end');

    final incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM income WHERE date >= ? AND date <= ?',
      [start, end],
    );

    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total, category FROM expenses WHERE date >= ? AND date <= ? GROUP BY category',
      [start, end],
    );

    double income = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    double totalExpenses = 0;
    Map<String, double> categories = {};

    for (var row in expenseResult) {
      final amount = (row['total'] as num?)?.toDouble() ?? 0.0;
      totalExpenses += amount;
      categories[row['category'] as String] = amount;
    }

    print('📊 LIVE: Income ₹$income | Expenses ₹$totalExpenses');

    return {
      'income': income,
      'expenses': totalExpenses,
      'balance': income - totalExpenses,
      'categories': categories,
      'period': DateFormat(
        'MMM yyyy',
      ).format(DateTime.parse(start.split('.')[0])),
    };
  }

  static Future<void> addExpense(Map<String, dynamic> expense) async {
    final db = await database;
    await db.insert('expenses', expense);
    print('Expense added: ${expense['amount']} - ${expense['category']}');
  }

  static Future<void> addIncome(Map<String, dynamic> incomeData) async {
    final db = await database;
    await db.insert('income', incomeData);
  }

  // **FULL CRUD OPERATIONS**
  static Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final db = await database;
    return await db.query('expenses', orderBy: 'date DESC');
  }

  static Future<List<Map<String, dynamic>>> getAllIncome() async {
    final db = await database;
    return await db.query('income', orderBy: 'date DESC');
  }

  static Future<void> updateExpense(
    int id,
    Map<String, dynamic> expense,
  ) async {
    final db = await database;
    await db.update('expenses', expense, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteExpense(int id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateIncome(int id, Map<String, dynamic> income) async {
    final db = await database;
    await db.update('income', income, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteIncome(int id) async {
    final db = await database;
    await db.delete('income', where: 'id = ?', whereArgs: [id]);
  }

  // Get ALL dynamic savings progress
  static Future<List<Map<String, dynamic>>> getSavingsProgress() async {
    final db = await database;
    return await db.query('savings_goals');
  }

  static Database? _database;
  static const int _currentVersion = 5; // Track version here

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'finance_tracker.db');
    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // This handles ALL future table additions
      onDowngrade: _onDowngrade,
    );
  }

  // **CREATES ALL TABLES ON FRESH INSTALL**
  static Future<void> _onCreate(Database db, int version) async {
    await _createExpensesTable(db);
    await _createIncomeTable(db);
    await _createSavingsGoalsTable(db);
  }

  // **MIGRATES EXISTING DB TO NEW VERSION**
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    print('Migrating from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      await _createExpensesTable(db);
      await _createIncomeTable(db);
    }

    if (oldVersion < 3) {
      // Add savings_goals table
      await _createSavingsGoalsTable(db);
    }

    if (oldVersion < 5) {
      // Add created_at column to savings_goals
      try {
        await db.execute('ALTER TABLE savings_goals ADD COLUMN created_at TEXT DEFAULT CURRENT_TIMESTAMP');
      } catch (e) {
        // Column might already exist
      }
    }
  }

  static Future<void> _onDowngrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle downgrade if needed
  }

  // Table creators (reusable)
  static Future<void> _createExpensesTable(Database db) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        sub_category TEXT,
        date TEXT NOT NULL,
        payment_mode TEXT,
        vehicle TEXT,
        liters REAL,
        note TEXT
      )
    ''');
  }

  static Future<void> _createIncomeTable(Database db) async {
    await db.execute('''
      CREATE TABLE income(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  static Future<void> _createSavingsGoalsTable(Database db) async {
    await db.execute('''
      CREATE TABLE savings_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL DEFAULT 0,
        deadline TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  static Future<void> addSavingsContribution(
    String goalName,
    double amount,
  ) async {
    final db = await database;

    final existing = await db.query(
      'savings_goals',
      where: 'name = ?',
      whereArgs: [goalName],
    );

    if (existing.isEmpty) {
      // Create new goal
      await db.insert('savings_goals', {
        'name': goalName,
        'target_amount': amount * 12, // Assume yearly target
        'current_amount': amount,
      });
    } else {
      // Update existing
      final goalId = existing.first['id'] as int;
      final current = (existing.first['current_amount'] as double) + amount;
      await db.update(
        'savings_goals',
        {'current_amount': current},
        where: 'id = ?',
        whereArgs: [goalId],
      );
    }
  }

  static Future<void> addNewSavingsGoal(
    String name,
    double targetAmount,
    DateTime deadline,
  ) async {
    final db = await database;
    await db.insert('savings_goals', {
      'name': name,
      'target_amount': targetAmount,
      'current_amount': 0.0,
      'deadline': deadline.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static String _getProgressVisual(double progress) {
    final blocks = (progress / 10).floor(); // 10% per block
    final emptyBlocks = 6 - blocks;
    return '█' * blocks +
        '' * emptyBlocks +
        ' ${(progress).toStringAsFixed(0)}%';
  }

  static String _getGoalMessage(
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

  static String _format(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}
