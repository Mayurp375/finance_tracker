# finance_tracker

A new Flutter project.

📊 Personal Finance Tracker – Flutter App

A modern, offline-first personal finance management app built with Flutter to help users track daily expenses, income, savings goals, and analyze monthly financial health.

This app is designed for working professionals who want clarity, control, and discipline over their money — without complex spreadsheets.

🚀 Features
💰 Income & Expense Tracking

Add monthly salary and other income

Track daily expenses in seconds

Categorize expenses:

Fixed

Variable

Travel / Out-of-station

Emergency

Special support for Diesel / Petrol tracking

📆 Monthly Financial Dashboard

Total Income

Total Expenses

Balance (Savings potential)

Category-wise pie chart

Month selection (history supported)

🎯 Savings & Goals

Track:

Emergency Fund

SIP

Other savings

Set target amounts

See real-time progress bars

Get visual feedback when goals are achieved

📈 Smart Insights

Travel and spending trends

Expense vs income comparison

Monthly improvement tracking

🔐 Offline First

All data is stored locally on device

No internet required

Fast, private, and secure

🛠 Tech Stack
Layer	Technology
UI	Flutter
State Management	Provider
Charts	fl_chart
Local Database	SQLite / Hive
Architecture	MVVM-style (Provider + Services)
🧱 App Architecture
lib/
 ├── pages/
 │    ├── dashboard.dart
 │    ├── add_expense.dart
 │    ├── add_income.dart
 │    └── data_manager.dart
 ├── provider/
 │    └── finance_provider.dart
 ├── service/
 │    └── database_service.dart
 └── main.dart

🔄 How It Works

User enters monthly income

Adds daily expenses (10–15 seconds per entry)

App stores data locally

Monthly dashboard auto-calculates:

Total spend

Savings

Category trends

User reviews progress and adjusts habits

📱 Screens

Dashboard (monthly view)

Add Expense

Add Income

Savings & Goals

Data Manager (history)

🧠 Why I Built This

Most people:

Earn well

But don’t know where their money goes

This app gives:

Clarity

Discipline

Confidence

It is built for real-world personal finance, not accounting.

🔮 Future Enhancements

Cloud sync (Firebase / Supabase)

Budget limits per category

Export to Excel / PDF

App lock (PIN / biometrics)

🧑‍💻 Developer

Built by Mayur Polojwar
Backend Engineer (SQlite, Fintech)
Learning Flutter for building real-world products.
