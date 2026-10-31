import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:erish_app/main.dart';
import 'package:erish_app/features/product/presentation/product_detail_page.dart';
import 'package:erish_app/features/checkout/presentation/checkout_page.dart';
import 'package:erish_app/features/orders/presentation/order_confirmation_page.dart';
import 'package:erish_app/features/admin/presentation/admin_portal_page.dart';
import 'package:erish_app/services/cart_provider.dart';
import 'package:erish_app/services/firebase_service.dart';

void main() {
  testWidgets('ERISH app builds smoke test', (WidgetTester tester) async {
    final firebaseService = FirebaseService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          Provider.value(value: firebaseService),
        ],
        child: const ErishApp(),
      ),
    );

    expect(find.byType(ErishApp), findsOneWidget);
  });

  testWidgets('ProductDetailPage renders gallery and Add to Bag',
      (WidgetTester tester) async {
    final firebaseService = FirebaseService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          Provider.value(value: firebaseService),
        ],
        child: const MaterialApp(
          home: ProductDetailPage(slug: 'jaipur-paisley-maxi'),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Jaipur Paisley Maxi'), findsOneWidget);
    expect(find.text('ADD TO BAG'), findsOneWidget);
    expect(find.text('SELECT SIZE'), findsOneWidget);
  });

  testWidgets('CheckoutPage renders empty cart state when no items',
      (WidgetTester tester) async {
    final firebaseService = FirebaseService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          Provider.value(value: firebaseService),
        ],
        child: const MaterialApp(home: CheckoutPage()),
      ),
    );

    await tester.pump();

    expect(find.text('Your shopping bag is empty.'), findsOneWidget);
    expect(find.text('RETURN TO CATALOG'), findsOneWidget);
  });

  testWidgets('OrderConfirmationPage renders order details correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OrderConfirmationPage(
          orderDetails: {
            'orderId': 'ORD-TEST-1234',
            'customerName': 'Meera Patel',
            'email': 'meera@erish.test',
            'address': 'Bandra, Mumbai - 400050',
            'totalAmount': 2799,
          },
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Order Confirmed!'), findsOneWidget);
    expect(find.text('ORDER ID: ORD-TEST-1234'), findsOneWidget);
    expect(find.text('CONTINUE SHOPPING'), findsOneWidget);
  });

  testWidgets('AdminPortalPage renders login gate when unauthenticated', (
    WidgetTester tester,
  ) async {
    final firebaseService = FirebaseService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [Provider.value(value: firebaseService)],
        child: const MaterialApp(home: AdminPortalPage(initialAuthenticated: false)),
      ),
    );

    await tester.pump();

    expect(find.text('Admin Portal'), findsOneWidget);
    expect(find.text('SIGN IN TO CONSOLE'), findsOneWidget);
    expect(find.text('Commerce Metrics Overview'), findsNothing);
  });

  testWidgets('AdminPortalPage renders console and metrics when authenticated',
      (WidgetTester tester) async {
    final firebaseService = FirebaseService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: firebaseService),
        ],
        child: const MaterialApp(
          home: AdminPortalPage(initialAuthenticated: true),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('ADMIN CONSOLE'), findsOneWidget);
    expect(find.text('Commerce Metrics Overview'), findsOneWidget);
    expect(find.text('Gross Revenue'), findsOneWidget);
  });
}
