import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exp_10/main.dart';
import 'package:exp_10/models/user_profile.dart';
import 'package:exp_10/services/auth_service.dart';
import 'package:exp_10/firebase_options.dart';

void main() {
  setUp(() {
    AuthService.resetSimulation();
  });

  group('Experiment 10 - UserProfile Model Unit Tests', () {
    final sampleUser = UserProfile(
      uid: 'uid-test-123',
      name: 'Allwyn Noble',
      email: 'allwyn@example.com',
      createdAt: DateTime(2026, 11, 11, 10, 0, 0),
    );

    test('UserProfile.toMap produces correct Firestore schema without password', () {
      final map = sampleUser.toMap();
      expect(map['name'], 'Allwyn Noble');
      expect(map['email'], 'allwyn@example.com');
      expect(map.containsKey('created_at'), true);
      // Critical security check: Never store passwords in Firestore!
      expect(map.containsKey('password'), false);
    });

    test('UserProfile.fromMap parses properties accurately', () {
      final parsed = UserProfile.fromMap('uid-test-456', {
        'name': 'Jane Doe',
        'email': 'jane@example.com',
        'created_at': DateTime(2026, 11, 11, 12, 0, 0),
      });

      expect(parsed.uid, 'uid-test-456');
      expect(parsed.name, 'Jane Doe');
      expect(parsed.email, 'jane@example.com');
    });

    test('UserProfile.copyWith creates updated copy', () {
      final updated = sampleUser.copyWith(name: 'Allwyn N.');
      expect(updated.name, 'Allwyn N.');
      expect(updated.email, 'allwyn@example.com');
      expect(updated.uid, 'uid-test-123');
    });

    test('DefaultFirebaseOptions isConfigured checks for placeholder values', () {
      expect(DefaultFirebaseOptions.web.apiKey, 'YOUR_WEB_API_KEY');
      expect(DefaultFirebaseOptions.isConfigured, false);
    });
  });

  group('Experiment 10 - Login Screen UI & Validation Tests', () {
    testWidgets('Login screen renders all required elements', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const AuthApp(
          isFirebaseInitialized: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Secure User Login'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('navigate_to_register_button')), findsOneWidget);
    });

    testWidgets('Empty fields display appropriate validation error messages', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const AuthApp(
          isFirebaseInitialized: false,
        ),
      );
      await tester.pumpAndSettle();

      final loginBtn = find.byKey(const Key('login_submit_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email address.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('Invalid email format triggers validation error', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const AuthApp(
          isFirebaseInitialized: false,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('login_email_field')), 'invalid-email-format');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'password123');

      final loginBtn = find.byKey(const Key('login_submit_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address.'), findsOneWidget);
    });

    testWidgets('Password with less than 6 characters triggers validation error', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const AuthApp(
          isFirebaseInitialized: false,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('login_email_field')), 'user@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), '12345');

      final loginBtn = find.byKey(const Key('login_submit_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.text('Password must contain at least 6 characters.'), findsOneWidget);
    });

    testWidgets('Password visibility toggle toggles obscureText', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const AuthApp(
          isFirebaseInitialized: false,
        ),
      );
      await tester.pumpAndSettle();

      final passwordFieldFinder = find.byKey(const Key('login_password_field'));
      EditableText editableText = tester.widget(find.descendant(of: passwordFieldFinder, matching: find.byType(EditableText)));
      expect(editableText.obscureText, true);

      // Tap visibility toggle
      await tester.tap(find.byKey(const Key('login_toggle_password_visibility')));
      await tester.pumpAndSettle();

      editableText = tester.widget(find.descendant(of: passwordFieldFinder, matching: find.byType(EditableText)));
      expect(editableText.obscureText, false);
    });

    testWidgets('Login with unregistered email displays friendly error', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authService = AuthService(isFirebaseAvailable: false);

      await tester.pumpWidget(
        AuthApp(
          isFirebaseInitialized: false,
          authService: authService,
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('login_email_field')), 'notfound@example.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'secret123');

      final loginBtn = find.byKey(const Key('login_submit_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('No account found with this email address'), findsWidgets);
    });
  });

  group('Experiment 10 - Registration Screen Validation & Flow Tests', () {
    testWidgets('Registration screen displays all required fields', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const AuthApp(
          isFirebaseInitialized: false,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Register screen
      final navBtn = find.byKey(const Key('navigate_to_register_button'));
      await tester.ensureVisible(navBtn);
      await tester.tap(navBtn);
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsWidgets);
      expect(find.byKey(const Key('register_name_field')), findsOneWidget);
      expect(find.byKey(const Key('register_email_field')), findsOneWidget);
      expect(find.byKey(const Key('register_password_field')), findsOneWidget);
      expect(find.byKey(const Key('register_confirm_password_field')), findsOneWidget);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
    });

    testWidgets('Confirm password mismatch triggers validation error', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const AuthApp(
          isFirebaseInitialized: false,
        ),
      );
      await tester.pumpAndSettle();

      final navBtn = find.byKey(const Key('navigate_to_register_button'));
      await tester.ensureVisible(navBtn);
      await tester.tap(navBtn);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('register_name_field')), 'Allwyn Noble');
      await tester.enterText(find.byKey(const Key('register_email_field')), 'allwyn@example.com');
      await tester.enterText(find.byKey(const Key('register_password_field')), 'password123');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'differentPassword');

      final regBtn = find.byKey(const Key('register_submit_button'));
      await tester.ensureVisible(regBtn);
      await tester.tap(regBtn);
      await tester.pumpAndSettle();

      expect(find.text('Confirm Password must match Password.'), findsOneWidget);
    });

    testWidgets('Successful registration navigates to Home Dashboard displaying user name and email', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authService = AuthService(isFirebaseAvailable: false);

      await tester.pumpWidget(
        AuthApp(
          isFirebaseInitialized: false,
          authService: authService,
        ),
      );
      await tester.pumpAndSettle();

      final navBtn = find.byKey(const Key('navigate_to_register_button'));
      await tester.ensureVisible(navBtn);
      await tester.tap(navBtn);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('register_name_field')), 'Allwyn Noble');
      await tester.enterText(find.byKey(const Key('register_email_field')), 'allwyn@example.com');
      await tester.enterText(find.byKey(const Key('register_password_field')), 'secret123');
      await tester.enterText(find.byKey(const Key('register_confirm_password_field')), 'secret123');

      final regBtn = find.byKey(const Key('register_submit_button'));
      await tester.ensureVisible(regBtn);
      await tester.tap(regBtn);
      await tester.pumpAndSettle();

      // Verify dashboard is displayed
      expect(find.text('Home Dashboard'), findsOneWidget);
      expect(find.byKey(const Key('dashboard_user_name_display')), findsOneWidget);
      expect(find.text('Allwyn Noble'), findsWidgets);
      expect(find.text('allwyn@example.com'), findsWidgets);
      expect(find.byKey(const Key('dashboard_logout_button')), findsOneWidget);
    });

    testWidgets('Login after registration succeeds with valid credentials and fails with wrong password', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final authService = AuthService(isFirebaseAvailable: false);

      // Pre-register user in auth service
      await authService.registerUser(
        name: 'Sarah Connor',
        email: 'sarah@skynet.com',
        password: 'terminatorPassword',
      );
      await authService.signOut();

      await tester.pumpWidget(
        AuthApp(
          isFirebaseInitialized: false,
          authService: authService,
        ),
      );
      await tester.pumpAndSettle();

      // Test wrong password first
      await tester.enterText(find.byKey(const Key('login_email_field')), 'sarah@skynet.com');
      await tester.enterText(find.byKey(const Key('login_password_field')), 'wrongPassword');

      var loginBtn = find.byKey(const Key('login_submit_button'));
      await tester.ensureVisible(loginBtn);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('Incorrect password'), findsWidgets);

      // Test correct password
      await tester.enterText(find.byKey(const Key('login_password_field')), 'terminatorPassword');
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      // Verified reached Dashboard
      expect(find.text('Home Dashboard'), findsOneWidget);
      expect(find.text('Sarah Connor'), findsWidgets);
      expect(find.text('sarah@skynet.com'), findsWidgets);
    });
  });

  group('Experiment 10 - Dashboard & Logout Flow Tests', () {
    testWidgets('Unauthenticated user cannot view dashboard', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const AuthApp(
          isFirebaseInitialized: false,
          initialUser: null,
        ),
      );
      await tester.pumpAndSettle();

      // Only Login screen should be present
      expect(find.text('Home Dashboard'), findsNothing);
      expect(find.text('Secure User Login'), findsOneWidget);
    });

    testWidgets('Logout signs out and navigates back to Login screen', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final testUser = UserProfile(
        uid: 'uid-777',
        name: 'Allwyn Noble',
        email: 'allwyn@example.com',
        createdAt: DateTime.now(),
      );
      final authService = AuthService(isFirebaseAvailable: false);

      await tester.pumpWidget(
        AuthApp(
          isFirebaseInitialized: false,
          authService: authService,
          initialUser: testUser,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Dashboard'), findsOneWidget);

      // Tap appbar logout button
      final logoutBtn = find.byKey(const Key('dashboard_appbar_logout_button'));
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Confirm logout dialog appears
      expect(find.text('Confirm Logout'), findsOneWidget);

      // Confirm logout
      await tester.tap(find.byKey(const Key('confirm_logout_button')));
      await tester.pumpAndSettle();

      // Verified returned to Login screen
      expect(find.text('Secure User Login'), findsOneWidget);
      expect(find.text('Home Dashboard'), findsNothing);
    });
  });
}
