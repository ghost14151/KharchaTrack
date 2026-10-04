import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const KharchaTrackApp());
}

class TransactionItem {
  final String title;
  final String category;
  final double amount;
  final bool isIncome;
  final DateTime date;

  TransactionItem({
    required this.title,
    required this.category,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'isIncome': isIncome,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      title: map['title'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      isIncome: map['isIncome'] as bool,
      date: DateTime.parse(map['date'] as String),
    );
  }
}

class KharchaTrackApp extends StatelessWidget {
  const KharchaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KharchaTrack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<TransactionItem> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('transactions');

    if (saved == null) return;

    final List<dynamic> data = jsonDecode(saved);

    if (!mounted) return;

    setState(() {
      transactions.clear();
      transactions.addAll(
        data.map(
          (item) => TransactionItem.fromMap(
            Map<String, dynamic>.from(item),
          ),
        ),
      );
    });
  }

  Future<void> saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final data = transactions.map((item) => item.toMap()).toList();
    await prefs.setString('transactions', jsonEncode(data));
  }

  double get income => transactions
      .where((t) => t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get expense => transactions
      .where((t) => !t.isIncome)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => income - expense;

  void addTransaction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddTransactionSheet(
        onSave: (item) {
          setState(() {
            transactions.insert(0, item);
          });
          saveTransactions();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHome(),
      buildHistory(),
      buildAnalytics(),
      buildSettings(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KharchaTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: pages[selectedIndex],
      floatingActionButton: selectedIndex < 2
          ? FloatingActionButton.extended(
              onPressed: addTransaction,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('Total Balance'),
                const SizedBox(height: 8),
                Text(
                  '₹${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: summaryCard(
                'Income',
                income,
                Icons.arrow_downward,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: summaryCard(
                'Expense',
                expense,
                Icons.arrow_upward,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (transactions.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No transactions yet.\nTap Add to start.'),
              ),
            ),
          )
        else
          ...transactions.take(5).map(transactionTile),
      ],
    );
  }

  Widget summaryCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(title),
            const SizedBox(height: 4),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transactionTile(TransactionItem item) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          ),
        ),
        title: Text(item.title),
        subtitle: Text(
          '${item.category} • ${item.date.day}/${item.date.month}/${item.date.year}',
        ),
        trailing: Text(
          '${item.isIncome ? '+' : '-'}₹${item.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: item.isIncome ? Colors.green : Colors.red,
          ),
        ),
        onLongPress: () {
          setState(() {
            transactions.remove(item);
          });
          saveTransactions();
        },
      ),
    );
  }

  Widget buildHistory() {
    return transactions.isEmpty
        ? const Center(child: Text('No transactions yet.'))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${transactions.length} Transactions',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...transactions.map(transactionTile),
            ],
          );
  }

  Widget buildAnalytics() {
    final total = income + expense;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Monthly Analytics',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Income: ₹${income.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: total == 0 ? 0 : income / total,
                  minHeight: 12,
                ),
                const SizedBox(height: 20),
                Text('Expense: ₹${expense.toStringAsFixed(0)}'),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: total == 0 ? 0 : expense / total,
                  minHeight: 12,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSettings() {
    return ListView(
      children: [
        const ListTile(
          leading: Icon(Icons.currency_rupee),
          title: Text('Currency'),
          subtitle: Text('Indian Rupee (₹)'),
        ),
        const ListTile(
          leading: Icon(Icons.dark_mode_outlined),
          title: Text('Dark Mode'),
          subtitle: Text('Coming soon'),
        ),
        const ListTile(
          leading: Icon(Icons.file_download_outlined),
          title: Text('Export Data'),
          subtitle: Text('Coming soon'),
        ),
        const ListTile(
          leading: Icon(Icons.privacy_tip_outlined),
          title: Text('Privacy'),
          subtitle: Text('Your data stays on your device'),
        ),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('About'),
          subtitle: Text('KharchaTrack v1.0.0'),
        ),
      ],
    );
  }
}

class AddTransactionSheet extends StatefulWidget {
  final Future<void> Function(TransactionItem) onSave;

  const AddTransactionSheet({
    super.key,
    required this.onSave,
  });

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final amountController = TextEditingController();
  final titleController = TextEditingController();

  bool isIncome = false;

  final categories = [
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Recharge',
    'Other',
  ];

  String category = 'Food';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {isIncome},
              onSelectionChanged: (value) {
                setState(() {
                  isIncome = value.first;
                });
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Lunch',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }

  void save() {
    final amount = double.tryParse(amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final title = titleController.text.trim().isEmpty
        ? category
        : titleController.text.trim();

    widget.onSave(
      TransactionItem(
        title: title,
        category: category,
        amount: amount,
        isIncome: isIncome,
        date: DateTime.now(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    amountController.dispose();
    titleController.dispose();
    super.dispose();
  }
}
