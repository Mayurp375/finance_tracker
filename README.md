# finance_tracker

A new Flutter project.

📊 Personal Finance Tracker – Flutter App
A modern, offline-first personal finance management app built with Flutter to help users track daily expenses, income, savings goals, and analyze monthly financial health.
This app is designed for working professionals who want clarity, control, and discipline over their money — without complex spreadsheets.
________________________________________
🚀 Features
💰 Income & Expense Tracking
•	Add monthly salary and other income
•	Track daily expenses in seconds
•	Categorize expenses:
o	Fixed
o	Variable
o	Travel / Out-of-station
o	Emergency
•	Special support for Diesel / Petrol tracking
________________________________________
📆 Monthly Financial Dashboard
•	Total Income
•	Total Expenses
•	Balance (Savings potential)
•	Category-wise pie chart
•	Month selection (history supported)
________________________________________
🎯 Savings & Goals
•	Track:
o	Emergency Fund
o	SIP
o	Other savings
•	Set target amounts
•	See real-time progress bars
•	Get visual feedback when goals are achieved
________________________________________
📈 Smart Insights
•	Travel and spending trends
•	Expense vs income comparison
•	Monthly improvement tracking
________________________________________
🔐 Offline First
•	All data is stored locally on device
•	No internet required
•	Fast, private, and secure
________________________________________
🛠 Tech Stack
Layer	Technology
UI	Flutter
State Management	Provider
Charts	fl_chart
Local Database	SQLite / Hive
Architecture	MVVM-style (Provider + Services)
________________________________________
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
________________________________________
🔄 How It Works
1.	User enters monthly income
2.	Adds daily expenses (10–15 seconds per entry)
3.	App stores data locally
4.	Monthly dashboard auto-calculates:
o	Total spend
o	Savings
o	Category trends
5.	User reviews progress and adjusts habits
________________________________________
📱 Screens
•	Dashboard (monthly view)
•	Add Expense
•	Add Income
•	Savings & Goals
•	Data Manager (history)
________________________________________
🧠 Why I Built This
Most people:
•	Earn well
•	But don’t know where their money goes
This app gives:
•	Clarity
•	Discipline
•	Confidence
It is built for real-world personal finance, not accounting.
________________________________________
🔮 Future Enhancements
•	Cloud sync (Firebase / Supabase)
•	Budget limits per category
•	Export to Excel / PDF
•	App lock (PIN / biometrics)
________________________________________
🧑‍💻 Developer
Built by Mayur Polojwar
Backend Engineer (Java, Spring Boot, Fintech)
Learning Flutter for building real-world products.


