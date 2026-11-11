# 24CS2016 – Building Applications using Flutter
## Lab Record - Exercise No. 4

**Ex. No.:** 4  
**Title of the Exercise:** Form Validation using Stateful Widgets in Flutter (Car Mileage Calculator)  
**Date of Exercise:** 11-11-2026  
**GitHub Code Link:** https://github.com/Allwyy08/Flutter-Lab-Experiments/tree/main/Experiment-04  
**Video Link:** *(Paste your Google Drive screen recording link here)*  

---

### 1. Aim
To develop a Flutter application titled **"Car Mileage Calculator"** that accepts distance travelled and fuel consumed, validates the inputs, and dynamically calculates the vehicle's mileage:
1. Creating an `AppBar` with the title **"Car Mileage Calculator"**.
2. Creating a Flutter Form using a `GlobalKey<FormState>`.
3. Adding two `TextFormField` input fields:
   - Distance Travelled (in kilometres)
   - Fuel Consumed (in litres)
4. Adding proper input validation:
   - Both fields must not be empty.
   - Only positive numeric values are accepted.
   - Fuel consumption must be strictly greater than zero.
5. Adding a **"Calculate Mileage"** button.
6. Calculating mileage using the formula:
   $$\text{Mileage} = \frac{\text{Distance Travelled}}{\text{Fuel Consumed}}$$
7. Displaying the calculated mileage dynamically in **km/l**.
8. Displaying a friendly validation error if the inputs are invalid.
9. Adding a **"Reset"** button to clear all inputs, validation errors, and results.
10. Using `StatefulWidget` and `setState()` to update the result dynamically.
11. Using `TextEditingController` for reading and clearing input values.

---

### 2. Description
Form handling and input validation are fundamental requirements for robust software applications. Flutter provides first-class support for stateful forms via the `Form` widget, `FormField` abstractions (`TextFormField`), and global form keys. In this exercise, the following architectural concepts are demonstrated:

1. **`StatefulWidget` and `setState()`**:
   The `MileageCalculatorScreen` maintains dynamic state variables (`_calculatedMileage`, `_recordedDistance`, `_recordedFuel`). When the user triggers calculations or resets the form, `setState()` is invoked to rebuild the interface, rendering the highlighted result card or placeholder card reactively.

2. **`GlobalKey<FormState>`**:
   A `GlobalKey<FormState>` uniquely identifies the `Form` widget in the element tree. Calling `_formKey.currentState!.validate()` iterates through every child `FormField`, executes their individual `validator` callbacks, and updates the UI with error text if any validation constraint fails.

3. **`TextFormField` and `TextEditingController`**:
   - `_distanceController` and `_fuelController` manage the text fields, providing access to raw string values (`_distanceController.text.trim()`) and enabling atomic clearing via `clear()`.
   - The controllers are properly disposed of in `dispose()` to prevent memory leaks.
   - Fields are decorated with informative prefix icons (`Icons.route`, `Icons.local_gas_station`), units (`km`, `litres`), and helper descriptions.

4. **Input Validation Logic**:
   - **Empty check:** Prevents computation when either field is empty.
   - **Type check:** Ensures inputs are valid floating-point numbers (`double.tryParse`).
   - **Positivity & Non-Zero check:** Rejects negative values and specifically guarantees fuel consumption $> 0$ to prevent mathematical division by zero.

5. **Mileage Formula & Dynamic Formatting**:
   $$\text{Mileage (km/l)} = \frac{\text{Distance Travelled (km)}}{\text{Fuel Consumed (L)}}$$
   Whole numbers are formatted cleanly as `${mileage.toInt()} km/l` (e.g., `30 km/l`), while floating-point results retain two decimal places (e.g., `18.75 km/l`).

6. **Highlighted Result Card**:
   The calculated mileage is displayed inside a custom highlighted Card styled with a green accent border and background. It details the large mileage figure, an efficiency evaluation badge (e.g., *Exceptional Fuel Economy*, *Great Fuel Efficiency*), and a three-column breakdown showing Distance, Fuel Used, and the applied formula.

---

### 3. Flowchart & State Architecture

```
+-------------------------------------------------------------+
|                     User Taps "Calculate Mileage"          |
+-------------------------------------------------------------+
                               │
                               ▼
               _formKey.currentState!.validate()
                               │
            ┌──────────────────┴──────────────────┐
            ▼                                     ▼
      Validation Fails                      Validation Passes
  (Empty, Negative, 0 Fuel)                (e.g., 150 km, 5 L)
            │                                     │
            ▼                                     ▼
 Displays friendly error text            double distance = parse(_distanceController.text)
 beneath input fields                    double fuel = parse(_fuelController.text)
                                                  │
                                                  ▼
                                       setState(() {
                                         _calculatedMileage = distance / fuel;
                                         _recordedDistance = distance;
                                         _recordedFuel = fuel;
                                       });
                                                  │
                                                  ▼
                                        Renders Highlighted
                                            Result Card:
                                             "30 km/l"
```

---

### 4. Program Code (`lib/main.dart`)

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const CarMileageCalculatorApp());
}

/// Root Application Widget
class CarMileageCalculatorApp extends StatelessWidget {
  const CarMileageCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    const greenPrimary = Color(0xFF2E7D32); // Forest Green accent
    const greenLight = Color(0xFFE8F5E9); // Light green background tint

    return MaterialApp(
      title: 'Car Mileage Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: greenPrimary,
          primary: greenPrimary,
          secondary: const Color(0xFF388E3C),
          surface: Colors.white,
          surfaceContainerHighest: greenLight,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: greenPrimary,
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
            borderSide: const BorderSide(color: greenPrimary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 2),
          ),
          prefixIconColor: greenPrimary,
          labelStyle: const TextStyle(color: Color(0xFF546E7A)),
          floatingLabelStyle: const TextStyle(
            color: greenPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: greenPrimary,
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
      home: const MileageCalculatorScreen(),
    );
  }
}

/// Main Screen Widget with Form Validation & Dynamic Calculation
class MileageCalculatorScreen extends StatefulWidget {
  const MileageCalculatorScreen({super.key});

  @override
  State<MileageCalculatorScreen> createState() => _MileageCalculatorScreenState();
}

class _MileageCalculatorScreenState extends State<MileageCalculatorScreen> {
  static const Color greenAccent = Color(0xFF2E7D32);

  // GlobalKey used to uniquely identify the Form and validate its fields
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TextEditingControllers to read and clear input values
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _fuelController = TextEditingController();

  // State variables for calculated results
  double? _calculatedMileage;
  double? _recordedDistance;
  double? _recordedFuel;

  @override
  void dispose() {
    _distanceController.dispose();
    _fuelController.dispose();
    super.dispose();
  }

  /// Validates input values and calculates mileage dynamically
  void _calculateMileage() {
    // Validate all form fields using the GlobalKey<FormState>
    if (_formKey.currentState!.validate()) {
      final double distance = double.parse(_distanceController.text.trim());
      final double fuel = double.parse(_fuelController.text.trim());

      // Update the state dynamically using setState()
      setState(() {
        _recordedDistance = distance;
        _recordedFuel = fuel;
        // Formula: Mileage = Distance Travelled / Fuel Consumed
        _calculatedMileage = distance / fuel;
      });

      // Dismiss virtual or hardware focus
      FocusScope.of(context).unfocus();
    }
  }

  /// Resets all inputs, errors, and calculated results
  void _resetForm() {
    _distanceController.clear();
    _fuelController.clear();
    _formKey.currentState?.reset();

    // Reset state variables
    setState(() {
      _calculatedMileage = null;
      _recordedDistance = null;
      _recordedFuel = null;
    });

    FocusScope.of(context).unfocus();
  }

  /// Helper to return a friendly mileage efficiency badge text and color
  String _getEfficiencyLabel(double mileage) {
    if (mileage >= 25.0) {
      return 'Exceptional Fuel Economy';
    } else if (mileage >= 18.0) {
      return 'Great Fuel Efficiency';
    } else if (mileage >= 12.0) {
      return 'Average Fuel Consumption';
    } else {
      return 'High Fuel Consumption';
    }
  }

  /// Formats mileage display nicely (e.g. 30 km/l or 18.45 km/l)
  String _formatMileage(double mileage) {
    if (mileage % 1 == 0) {
      return '${mileage.toInt()} km/l';
    } else {
      return '${mileage.toStringAsFixed(2)} km/l';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Mileage Calculator'),
        leading: const Icon(Icons.directions_car, color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Reset Form',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetForm,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header introduction banner
                  _buildIntroCard(greenAccent),
                  const SizedBox(height: 20),

                  // Form card container
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.edit_note, color: greenAccent, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'Enter Trip Details',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF263238),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 1),

                            // Distance Travelled Input Field
                            TextFormField(
                              key: const Key('distance_field'),
                              controller: _distanceController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Distance Travelled',
                                hintText: 'e.g., 150',
                                prefixIcon: Icon(Icons.route),
                                suffixText: 'km',
                                suffixStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: greenAccent,
                                ),
                                helperText: 'Total distance driven in kilometres',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter the distance travelled';
                                }
                                final distance = double.tryParse(value.trim());
                                if (distance == null) {
                                  return 'Please enter a valid numeric value';
                                }
                                if (distance <= 0) {
                                  return 'Distance must be a positive number greater than 0';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Fuel Consumed Input Field
                            TextFormField(
                              key: const Key('fuel_field'),
                              controller: _fuelController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Fuel Consumed',
                                hintText: 'e.g., 5',
                                prefixIcon: Icon(Icons.local_gas_station),
                                suffixText: 'litres',
                                suffixStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: greenAccent,
                                ),
                                helperText: 'Total fuel used in litres',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter the fuel consumed';
                                }
                                final fuel = double.tryParse(value.trim());
                                if (fuel == null) {
                                  return 'Please enter a valid numeric value';
                                }
                                if (fuel <= 0) {
                                  return 'Fuel consumption must be greater than zero';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Action Buttons (Calculate & Reset)
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: ElevatedButton.icon(
                                    key: const Key('calculate_button'),
                                    onPressed: _calculateMileage,
                                    icon: const Icon(Icons.calculate_outlined),
                                    label: const Text('Calculate Mileage'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: OutlinedButton.icon(
                                    key: const Key('reset_button'),
                                    onPressed: _resetForm,
                                    icon: const Icon(Icons.replay),
                                    label: const Text('Reset'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Dynamic Highlighted Result Card or Helpful Guide Card
                  if (_calculatedMileage != null)
                    _buildResultCard(greenAccent)
                  else
                    _buildPlaceholderCard(greenAccent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top introduction banner
  Widget _buildIntroCard(Color greenAccent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: greenAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fuel Efficiency Calculator',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Formula: Mileage = Distance Travelled / Fuel Consumed',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Highlighted result Card displaying dynamic mileage in km/l
  Widget _buildResultCard(Color greenAccent) {
    final mileage = _calculatedMileage!;
    final formattedMileage = _formatMileage(mileage);
    final efficiencyText = _getEfficiencyLabel(mileage);

    return Card(
      key: const Key('result_card'),
      elevation: 3,
      shadowColor: greenAccent.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: greenAccent.withValues(alpha: 0.5), width: 1.5),
      ),
      color: const Color(0xFFF1F8E9),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.speed, color: greenAccent, size: 28),
                const SizedBox(width: 8),
                Text(
                  'CALCULATED MILEAGE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Large Mileage Display (e.g. "30 km/l")
            Text(
              formattedMileage,
              key: const Key('mileage_result_text'),
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B5E20),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),

            // Secondary exact decimal notation
            Text(
              '(${mileage.toStringAsFixed(2)} km/l)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 14),

            // Efficiency category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: greenAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    efficiencyText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, thickness: 1, color: Color(0xFFC8E6C9)),
            const SizedBox(height: 14),

            // Breakdown Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: '${_recordedDistance! % 1 == 0 ? _recordedDistance!.toInt() : _recordedDistance} km',
                ),
                Container(width: 1, height: 36, color: const Color(0xFFC8E6C9)),
                _buildSummaryItem(
                  icon: Icons.local_gas_station,
                  label: 'Fuel Used',
                  value: '${_recordedFuel! % 1 == 0 ? _recordedFuel!.toInt() : _recordedFuel} L',
                ),
                Container(width: 1, height: 36, color: const Color(0xFFC8E6C9)),
                _buildSummaryItem(
                  icon: Icons.functions,
                  label: 'Formula',
                  value: '${_recordedDistance! % 1 == 0 ? _recordedDistance!.toInt() : _recordedDistance} / ${_recordedFuel! % 1 == 0 ? _recordedFuel!.toInt() : _recordedFuel}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Summary item widget
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF558B2F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  /// Placeholder card shown before calculation
  Widget _buildPlaceholderCard(Color greenAccent) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEEEEEE), width: 1),
      ),
      color: const Color(0xFFFAFAFA),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Icon(Icons.insights, size: 40, color: Color(0xFF9E9E9E)),
            SizedBox(height: 10),
            Text(
              'No Calculation Yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF616161),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Enter distance travelled and fuel consumed above, then tap "Calculate Mileage" to view results.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 5. Output Description & Test Cases

The application delivers a clean, responsive, and robust calculator interface:
- **Clean Form Structure:** Encapsulated inside a clean card with an emerald green theme (`#2E7D32`), featuring clear inputs for Distance (km) and Fuel Consumed (litres).
- **Test Case 1 (Standard Calculation):**
  - **Input:** Distance = `150`, Fuel = `5`
  - **Output:** The highlighted result card renders `30 km/l` (`30.00 km/l`) alongside the **"Exceptional Fuel Economy"** rating badge and trip breakdown.
- **Test Case 2 (Empty Fields Validation):**
  - Tapping "Calculate Mileage" with empty inputs displays immediate friendly error messages:
    - *"Please enter the distance travelled"*
    - *"Please enter the fuel consumed"*
- **Test Case 3 (Zero Fuel Validation):**
  - Entering Distance = `150`, Fuel = `0` displays:
    - *"Fuel consumption must be greater than zero"*
- **Test Case 4 (Negative Value Validation):**
  - Entering Distance = `-50` displays:
    - *"Distance must be a positive number greater than 0"*
- **Test Case 5 (Reset Button):**
  - Tapping "Reset" wipes both text fields, clears any active validation error states, and restores the initial informative placeholder card.

---

### 6. Result
The Flutter Car Mileage Calculator application with Form Validation was successfully developed, tested, and documented. The project meets all specified laboratory requirements:
- Implemented `Form`, `GlobalKey<FormState>`, `TextFormField`, and `TextEditingController`.
- Managed dynamic reactive updates using `StatefulWidget` and `setState()`.
- Successfully validated empty, zero, and negative values.
- Verified test cases on both Google Chrome and unit/widget test environments without errors or warnings.
