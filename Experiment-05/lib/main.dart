import 'package:flutter/material.dart';

void main() {
  runApp(const PersonalBudgetCalculatorApp());
}

/// Root Application Widget
class PersonalBudgetCalculatorApp extends StatelessWidget {
  const PersonalBudgetCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Primary Blue and Emerald Green Accents
    const primaryBlue = Color(0xFF1565C0); // Deep Royal Blue
    const accentGreen = Color(0xFF2E7D32); // Emerald Green

    return MaterialApp(
      title: 'Personal Budget Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: accentGreen,
          surface: Colors.white,
          surfaceContainerHighest: const Color(0xFFF0F4F8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCFD8DC), width: 1.2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCFD8DC), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
          ),
          prefixIconColor: primaryBlue,
          labelStyle: const TextStyle(color: Color(0xFF546E7A)),
          floatingLabelStyle: const TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF546E7A),
            side: const BorderSide(color: Color(0xFFB0BEC5), width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const BudgetCalculatorScreen(),
    );
  }
}

/// Main Screen Widget with Form Validation & Dynamic State Management
class BudgetCalculatorScreen extends StatefulWidget {
  const BudgetCalculatorScreen({super.key});

  @override
  State<BudgetCalculatorScreen> createState() => _BudgetCalculatorScreenState();
}

class _BudgetCalculatorScreenState extends State<BudgetCalculatorScreen> {
  // GlobalKey used to identify and validate the Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TextEditingControllers to read and clear input fields
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _expensesController = TextEditingController();

  // State variables for calculated results
  double? _monthlyIncome;
  double? _monthlyExpenses;
  double? _remainingBalance;
  bool _hasCalculated = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _expensesController.dispose();
    super.dispose();
  }

  /// Trigger budget calculation with validation and setState()
  void _calculateBudget() {
    FocusScope.of(context).unfocus(); // Close on-screen keyboard
    if (_formKey.currentState?.validate() ?? false) {
      final double income = double.parse(_incomeController.text.trim());
      final double expenses = double.parse(_expensesController.text.trim());
      final double balance = income - expenses;

      setState(() {
        _monthlyIncome = income;
        _monthlyExpenses = expenses;
        _remainingBalance = balance;
        _hasCalculated = true;
      });
    }
  }

  /// Reset all form fields, controllers, and calculated state
  void _resetAll() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    _incomeController.clear();
    _expensesController.clear();

    setState(() {
      _monthlyIncome = null;
      _monthlyExpenses = null;
      _remainingBalance = null;
      _hasCalculated = false;
    });
  }

  /// Helper to format numeric values cleanly (e.g. 30000 or 18000.50)
  String _formatNumber(double amount) {
    if (amount % 1 == 0) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
  }

  /// Returns financial status message according to requirements:
  /// - positive: "Good! You have savings."
  /// - zero: "Your budget is balanced."
  /// - negative: "Warning! You are overspending."
  String _getStatusMessage(double balance) {
    if (balance > 0) {
      return 'Good! You have savings.';
    } else if (balance == 0) {
      return 'Your budget is balanced.';
    } else {
      return 'Warning! You are overspending.';
    }
  }

  /// Primary theme color for current status
  Color _getStatusColor(double balance) {
    if (balance > 0) {
      return const Color(0xFF2E7D32); // Forest Green
    } else if (balance == 0) {
      return const Color(0xFF0277BD); // Light / Ocean Blue
    } else {
      return const Color(0xFFC62828); // Crimson Red
    }
  }

  /// Soft background tint color for status card
  Color _getStatusBgColor(double balance) {
    if (balance > 0) {
      return const Color(0xFFE8F5E9); // Light Green
    } else if (balance == 0) {
      return const Color(0xFFE1F5FE); // Light Blue
    } else {
      return const Color(0xFFFFEBEE); // Light Red
    }
  }

  /// Border color for status card
  Color _getStatusBorderColor(double balance) {
    if (balance > 0) {
      return const Color(0xFFA5D6A7);
    } else if (balance == 0) {
      return const Color(0xFF81D4FA);
    } else {
      return const Color(0xFFEF9A9A);
    }
  }

  /// Status icon
  IconData _getStatusIcon(double balance) {
    if (balance > 0) {
      return Icons.savings_outlined;
    } else if (balance == 0) {
      return Icons.balance_outlined;
    } else {
      return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1565C0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Budget Calculator'),
        leading: const Icon(Icons.account_balance_wallet),
        actions: [
          IconButton(
            key: const Key('appbar_reset_button'),
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset All',
            onPressed: _resetAll,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Intro Banner
                    _buildIntroBanner(primaryBlue),
                    const SizedBox(height: 20),

                    // Input Card
                    _buildInputCard(primaryBlue),
                    const SizedBox(height: 20),

                    // Action Buttons (Calculate & Reset)
                    _buildActionButtons(),
                    const SizedBox(height: 24),

                    // Results or Placeholder
                    if (_hasCalculated && _remainingBalance != null) ...[
                      // Financial Status Badge Card
                      _buildFinancialStatusCard(),
                      const SizedBox(height: 16),

                      // Remaining Balance Highlight Card
                      _buildRemainingBalanceCard(),
                      const SizedBox(height: 16),

                      // Income & Expense Breakdown Cards
                      _buildBreakdownCards(),
                    ] else ...[
                      // Initial Placeholder Card
                      _buildPlaceholderCard(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Intro Header Card
  Widget _buildIntroBanner(Color primaryBlue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD9E2EC)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.insights, color: primaryBlue, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Financial Management',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102A43),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Track income and expenses with reactive Flutter state management to monitor your monthly savings.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF486581),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Input Fields Card
  Widget _buildInputCard(Color primaryBlue) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit_note, color: Color(0xFF1565C0), size: 22),
                SizedBox(width: 8),
                Text(
                  'Enter Financial Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

            // Monthly Income Field
            TextFormField(
              key: const Key('income_field'),
              controller: _incomeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monthly Income',
                hintText: 'Enter monthly income (e.g. 30000)',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                helperText: 'Total regular earnings per month',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your monthly income';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null) {
                  return 'Please enter a valid numeric amount';
                }
                if (parsed < 0) {
                  return 'Income must be a valid non-negative number (>= 0)';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Monthly Expenses Field
            TextFormField(
              key: const Key('expenses_field'),
              controller: _expensesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monthly Expenses',
                hintText: 'Enter monthly expenses (e.g. 18000)',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                helperText: 'Total regular expenditures per month',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your monthly expenses';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null) {
                  return 'Please enter a valid numeric amount';
                }
                if (parsed < 0) {
                  return 'Expenses must be a valid non-negative number (>= 0)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Action Buttons (Calculate & Reset)
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Calculate Budget Button
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            key: const Key('calculate_button'),
            onPressed: _calculateBudget,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('Calculate Budget'),
          ),
        ),
        const SizedBox(width: 12),

        // Reset Button
        Expanded(
          flex: 2,
          child: OutlinedButton.icon(
            key: const Key('reset_button'),
            onPressed: _resetAll,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ),
      ],
    );
  }

  /// Financial Status Card
  Widget _buildFinancialStatusCard() {
    final balance = _remainingBalance!;
    final statusColor = _getStatusColor(balance);
    final statusBgColor = _getStatusBgColor(balance);
    final statusBorderColor = _getStatusBorderColor(balance);
    final statusIcon = _getStatusIcon(balance);
    final statusText = _getStatusMessage(balance);

    return Card(
      key: const Key('status_card'),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusBorderColor, width: 1.5),
      ),
      color: statusBgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(statusIcon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'FINANCIAL STATUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusText,
                    key: const Key('status_message_text'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Remaining Balance Card
  Widget _buildRemainingBalanceCard() {
    final balance = _remainingBalance!;
    final statusColor = _getStatusColor(balance);
    final formattedBalance = _formatNumber(balance.abs());

    return Card(
      key: const Key('balance_card'),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'REMAINING BALANCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),

            // Remaining Balance Value (Formatted)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  balance < 0 ? '-₹ ' : '₹ ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Text(
                  formattedBalance,
                  key: const Key('remaining_balance_text'),
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Plain balance representation (e.g. 12000 or -5000)
            Text(
              'Remaining Balance: ${_formatNumber(balance)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 14),

            // Formula representation badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Text(
                'Formula: ${_formatNumber(_monthlyIncome!)} - ${_formatNumber(_monthlyExpenses!)} = ${_formatNumber(balance)}',
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Income & Expense Breakdown Cards
  Widget _buildBreakdownCards() {
    return Row(
      children: [
        // Monthly Income Card
        Expanded(
          child: Card(
            key: const Key('income_card'),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFC8E6C9)),
            ),
            color: const Color(0xFFF1F8E9),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_downward, color: Color(0xFF2E7D32), size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Monthly Income',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E7D32),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹ ${_formatNumber(_monthlyIncome!)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  Text(
                    _formatNumber(_monthlyIncome!),
                    key: const Key('income_value_text'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF388E3C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Monthly Expenses Card
        Expanded(
          child: Card(
            key: const Key('expenses_card'),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFFFCCBC)),
            ),
            color: const Color(0xFFFBE9E7),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_upward, color: Color(0xFFD84315), size: 16),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Monthly Expenses',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD84315),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹ ${_formatNumber(_monthlyExpenses!)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBF360C),
                    ),
                  ),
                  Text(
                    _formatNumber(_monthlyExpenses!),
                    key: const Key('expenses_value_text'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFFD84315),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Placeholder Card shown before calculation
  Widget _buildPlaceholderCard() {
    return Card(
      key: const Key('placeholder_card'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      color: const Color(0xFFFAFAFA),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 44, color: Color(0xFF90A4AE)),
            SizedBox(height: 12),
            Text(
              'No Budget Calculated Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF37474F),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Enter your monthly income and monthly expenses above, then tap "Calculate Budget" to view your remaining balance and financial status.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF78909C),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
