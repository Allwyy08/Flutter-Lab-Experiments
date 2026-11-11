# Experiment 4 – Form Validation using Stateful Widgets in Flutter

## 📌 Project Overview
**Car Mileage Calculator** is a clean, robust, and beginner-friendly Flutter application designed to calculate a vehicle's fuel efficiency dynamically based on user input. It demonstrates essential Flutter form handling techniques including **`Form`**, **`GlobalKey<FormState>`**, **`TextFormField`**, **`TextEditingController`**, and state manipulation with **`StatefulWidget`** and **`setState()`**.

The application enforces strict client-side validation to ensure clean and realistic inputs, dynamically updates the calculated mileage in **km/l**, highlights the result inside a dedicated summary Card with fuel economy insights, and provides a quick reset mechanism.

---

## 🎯 Requirements & Implementation Matrix

| Requirement | Implementation Details |
| :--- | :--- |
| **1. Professional AppBar** | Styled AppBar with title **"Car Mileage Calculator"**, vehicle icon, and quick-reset action button. |
| **2. Flutter Form with GlobalKey** | Uses `final GlobalKey<FormState> _formKey = GlobalKey<FormState>();` to manage form lifecycle and validation. |
| **3. Distance Travelled Field** | `TextFormField` with prefix icon (`Icons.route`), `km` suffix text, numeric decimal keyboard, and helper text. |
| **4. Fuel Consumed Field** | `TextFormField` with prefix icon (`Icons.local_gas_station`), `litres` suffix text, numeric decimal keyboard, and helper text. |
| **5. Input Validation** | Strict validator functions ensuring fields are not empty, values are positive numbers, and fuel consumption is strictly greater than 0. |
| **6. Calculate Mileage Button** | Primary green `ElevatedButton.icon` with calculator icon that triggers form validation and computes mileage. |
| **7. Mileage Formula** | Implements the formula: `Mileage = Distance Travelled (km) / Fuel Consumed (L)`. |
| **8. Dynamic Result Display** | Formats and displays mileage dynamically in **km/l** (e.g., `30 km/l` or `18.75 km/l`) alongside exact decimal notation. |
| **9. Validation Error Feedback** | Friendly, contextual error messages rendered below fields when validation fails (`Please enter distance travelled`, `Fuel consumption must be greater than zero`). |
| **10. Reset Functionality** | Clear/Reset button that wipes all input text fields, clears validation errors, resets state variables, and unfocuses keyboards. |
| **11. StatefulWidget & setState()** | Reactive state updates using Flutter's native `StatefulWidget` and `setState()` without any external state management overhead. |
| **12. TextEditingController** | `_distanceController` and `_fuelController` to manage text retrieval, input synchronization, and programmatic clearing with lifecycle `dispose()`. |
| **13. Highlighted Result Card** | Prominent green-accented card showcasing large mileage text, fuel efficiency badge, and breakdown summary. |
| **14. Responsive Web & Mobile** | Centered constrained container with scrollable viewport to prevent keyboard overlap on mobile devices and wide monitors. |

---

## 📐 Mathematical Formula & Logic

$$\text{Mileage (km/l)} = \frac{\text{Distance Travelled (km)}}{\text{Fuel Consumed (litres)}}$$

### Example Test Case:
- **Distance Travelled:** `150 km`
- **Fuel Consumed:** `5 litres`
- **Calculated Mileage:** $\frac{150}{5} = \mathbf{30\text{ km/l}}$

---

## 🏗️ Architecture & Code Structure

```
Experiment-04/
├── lib/
│   └── main.dart            # Complete application (CarMileageCalculatorApp, MileageCalculatorScreen)
├── test/
│   └── widget_test.dart     # Comprehensive unit and widget tests for validation, calculation, and reset
├── web/                     # Web platform runner and assets for Chrome/Browsers
├── windows/                 # Windows desktop runner and build configurations
├── pubspec.yaml             # Flutter project dependencies and metadata
├── analysis_options.yaml    # Flutter linting and static analysis rules
├── LAB_RECORD_EXP_4.md      # Laboratory record and academic report
└── README.md                # Project documentation and guide
```

---

## 🔄 Form Validation & State Flow

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

## 🧪 Automated Testing Suite

The project includes automated tests in `test/widget_test.dart`:
1. **Initial Rendering:** Confirms AppBar, input fields, buttons, and placeholder card render cleanly.
2. **Empty Validation:** Asserts error messages when clicking calculate with empty fields.
3. **Negative Values:** Checks that negative inputs are rejected.
4. **Zero Fuel Validation:** Confirms division by zero is prevented with a clear error prompt.
5. **Exact Calculation:** Tests `150 km` with `5 L` producing `30 km/l`.
6. **Reset Button:** Tests clearing all controllers, resetting form state, and hiding results.

---

## 🚀 How to Run the Project

1. Navigate to the Experiment-04 directory:
   ```bash
   cd Experiment-04
   ```

2. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application in Google Chrome:
   ```bash
   flutter run -d chrome
   ```

4. Run the automated test suite:
   ```bash
   flutter test
   ```

5. Run static analysis:
   ```bash
   flutter analyze
   ```
