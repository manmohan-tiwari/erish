import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/erish_button.dart';
import '../../../core/widgets/erish_image.dart';
import '../../../models/cart_item.dart';
import '../../../services/cart_provider.dart';
import '../../../services/firebase_service.dart';
import '../../cart/data/payment_service.dart';
import '../../auth/services/auth_service.dart';

/// ERISH Official Checkout Flow
/// Multi-step progressive checkout:
/// Step 1: Customer Contact & Shipping Address (Indian PIN Code validation)
/// Step 2: Delivery Speed Selection (Standard vs Express)
/// Step 3: Payment Option & Invocation (Razorpay / UPI / Card / COD)
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0; // 0: Address, 1: Shipping, 2: Payment
  bool _isProcessing = false;

  // Form Fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController(text: 'Maharashtra');
  final _pincodeController = TextEditingController();

  // Shipping Selection: 0 = Standard, 1 = Express
  int _shippingMethod = 0;

  // Payment Selection: 0 = UPI, 1 = Card, 2 = NetBanking, 3 = COD
  int _paymentMethod = 0;

  @override
  void initState() {
    super.initState();
    final auth = AuthService();
    if (auth.isAuthenticated) {
      if (auth.displayName != 'Valued Guest') {
        _nameController.text = auth.displayName;
      }
      _emailController.text = auth.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  int _calculateShippingFee(CartProvider cart) {
    if (_shippingMethod == 1) {
      return 199; // Express
    }
    return cart.hasFreeShipping ? 0 : 99; // Standard
  }

  int _calculateGrandTotal(CartProvider cart) {
    return cart.totalAmount + _calculateShippingFee(cart);
  }

  Future<void> _processOrder(CartProvider cart) async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _currentStep = 0);
      return;
    }

    setState(() => _isProcessing = true);

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final grandTotal = _calculateGrandTotal(cart);
    final itemsList = List<CartItem>.from(cart.items);
    final shippingFee = _calculateShippingFee(cart);
    final shippingAddressMap = {
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'pincode': _pincodeController.text.trim(),
    };

    final paymentMethodName = _paymentMethod == 0
        ? 'UPI / QR Code'
        : (_paymentMethod == 1
              ? 'Credit / Debit Card'
              : (_paymentMethod == 2
                    ? 'Net Banking'
                    : 'Cash on Delivery'));

    try {
      // 1. Process payment via PaymentService for non-COD options
      String? paymentId;
      if (_paymentMethod != 3) {
        final paymentService = PaymentService();
        final tempId =
            'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
        final paymentResult = await paymentService.processCheckoutPayment(
          orderId: tempId,
          amountInPaise: grandTotal * 100,
          customerName: _nameController.text.trim(),
          customerEmail: _emailController.text.trim(),
          customerPhone: _phoneController.text.trim(),
          paymentMethod: paymentMethodName,
        );

        if (!paymentResult.isSuccess) {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: ${paymentResult.errorMessage ?? 'Payment could not be completed.'}'),
              backgroundColor: Colors.red.shade800,
            ),
          );
          return;
        }
        paymentId = paymentResult.paymentId;
      }

      // 2. Persist compliant order to Firestore matching firestore.rules
      final orderId = await firebaseService.placeOrder(
        items: itemsList,
        totalAmount: grandTotal,
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        shippingAddress: shippingAddressMap,
        paymentMethod: paymentMethodName,
        shippingFee: shippingFee,
      );

      final confirmationId =
          orderId ??
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';

      // Clear cart
      cart.clearCart();

      if (!mounted) return;
      setState(() => _isProcessing = false);
      context.go(
        '/order-confirmation',
        extra: {
          'orderId': confirmationId,
          'customerName': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address':
              '${_addressController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()} - ${_pincodeController.text.trim()}',
          'totalAmount': grandTotal,
          'paymentMethod': paymentMethodName,
          'paymentId': paymentId,
          'items': itemsList,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing order: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 960;

    if (cart.items.isEmpty && !_isProcessing) {
      return Scaffold(
        backgroundColor: AppColors.warmIvory,
        appBar: _buildSimpleHeader(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: AppColors.muted,
              ),
              const SizedBox(height: 16),
              Text(
                'Your shopping bag is empty.',
                style: AppTypography.sectionTitle(color: AppColors.espresso),
              ),
              const SizedBox(height: 24),
              ErishButton(
                text: 'Return to Catalog',
                onPressed: () => context.go('/'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: _buildSimpleHeader(),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60.0 : 20.0,
                vertical: 32.0,
              ),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Step Forms
                        Expanded(
                          flex: 6,
                          child: _buildFormWorkflow(context, cart),
                        ),
                        const SizedBox(width: 48),

                        // Right Column: Sticky Order Summary
                        Expanded(flex: 4, child: _buildOrderSummary(cart)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildOrderSummary(cart),
                        const SizedBox(height: 32),
                        _buildFormWorkflow(context, cart),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSimpleHeader() {
    return AppBar(
      backgroundColor: AppColors.warmIvory,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 68,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.espresso),
        onPressed: () => context.go('/'),
      ),
      title: GestureDetector(
        onTap: () => context.go('/'),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Image.asset(
            'assets/images/erish-logo.png',
            height: 44,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Text(
              'ERISH',
              style: AppTypography.cardTitle(color: AppColors.espresso),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: Center(
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 14,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 6),
                Text(
                  'SECURE CHECKOUT',
                  style: AppTypography.button(
                    color: AppColors.muted,
                  ).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['1. Address', '2. Shipping', '3. Payment'];

    return Row(
      children: List.generate(steps.length, (index) {
        final isActive = _currentStep == index;
        final isDone = _currentStep > index;

        return Expanded(
          child: InkWell(
            onTap: isDone ? () => setState(() => _currentStep = index) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  steps[index].toUpperCase(),
                  style: AppTypography.button(
                    color: isActive
                        ? AppColors.pink
                        : (isDone ? AppColors.espresso : AppColors.muted),
                  ).copyWith(fontSize: 10),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 2,
                  color: isActive
                      ? AppColors.pink
                      : (isDone ? AppColors.espresso : AppColors.sandBorder),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFormWorkflow(BuildContext context, CartProvider cart) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(),
          const SizedBox(height: 36),

          // STEP 0: Contact & Address
          if (_currentStep == 0) ...[
            Text(
              'Shipping & Contact Details',
              style: AppTypography.sectionTitle(
                color: AppColors.espresso,
              ).copyWith(fontSize: 26),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hintText: 'e.g. Radhika Sharma',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter your name'
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hintText: 'radhika@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || !v.contains('@') || !v.contains('.')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hintText: '9876543210',
                    prefixText: '+91 ',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) => (v == null || v.length < 10)
                        ? '10-digit number required'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Street Address & Apartment',
              hintText: 'Flat 402, Sea Green Apartments, Bandra West',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Address required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    hintText: 'Mumbai',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'City required'
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _pincodeController,
                    label: 'PIN Code',
                    hintText: '400050',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (v) {
                      if (v == null ||
                          !RegExp(r'^[1-9][0-9]{5}$').hasMatch(v)) {
                        return 'Valid 6-digit PIN code required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ErishButton(
              text: 'Continue to Shipping Method',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() => _currentStep = 1);
                }
              },
            ),
          ],

          // STEP 1: Shipping Method
          if (_currentStep == 1) ...[
            Text(
              'Select Shipping Method',
              style: AppTypography.sectionTitle(
                color: AppColors.espresso,
              ).copyWith(fontSize: 26),
            ),
            const SizedBox(height: 20),
            _buildShippingOption(
              index: 0,
              title: 'Standard Ground Delivery',
              subtitle: 'Estimated delivery: 4–6 business days',
              price: cart.hasFreeShipping ? 'FREE' : '₹99',
            ),
            const SizedBox(height: 12),
            _buildShippingOption(
              index: 1,
              title: 'Express Priority Air Delivery',
              subtitle:
                  'Estimated delivery: 1–2 business days with SMS updates',
              price: '₹199',
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                ErishButton.ghost(
                  text: 'Back',
                  onPressed: () => setState(() => _currentStep = 0),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ErishButton(
                    text: 'Continue to Payment',
                    onPressed: () => setState(() => _currentStep = 2),
                  ),
                ),
              ],
            ),
          ],

          // STEP 2: Payment
          if (_currentStep == 2) ...[
            Text(
              'Select Payment Method',
              style: AppTypography.sectionTitle(
                color: AppColors.espresso,
              ).copyWith(fontSize: 26),
            ),
            const SizedBox(height: 8),
            Text(
              'All transactions are 256-bit encrypted and secured via Razorpay gateway.',
              style: AppTypography.caption(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            _buildPaymentOption(
              index: 0,
              title: 'Instant UPI / QR Code',
              subtitle: 'Google Pay, PhonePe, Paytm, BHIM',
              icon: Icons.qr_code,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              index: 1,
              title: 'Credit / Debit Card',
              subtitle: 'Visa, MasterCard, RuPay, American Express',
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              index: 2,
              title: 'Net Banking',
              subtitle: 'HDFC, ICICI, SBI, Axis and 40+ banks',
              icon: Icons.account_balance,
            ),
            const SizedBox(height: 12),
            _buildPaymentOption(
              index: 3,
              title: 'Cash on Delivery (COD)',
              subtitle: 'Pay cash or UPI upon delivery at doorstep',
              icon: Icons.payments_outlined,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                ErishButton.ghost(
                  text: 'Back',
                  onPressed: () => setState(() => _currentStep = 1),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ErishButton(
                    text: 'Place Order · ₹${_calculateGrandTotal(cart)}',
                    isLoading: _isProcessing,
                    onPressed: () => _processOrder(cart),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    String? prefixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.caption(
            color: AppColors.espresso,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          style: AppTypography.body(color: AppColors.espresso),
          decoration: InputDecoration(
            prefixText: prefixText,
            hintText: hintText,
            hintStyle: AppTypography.caption(color: AppColors.muted),
            filled: true,
            fillColor: AppColors.paperWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.sandBorder),
              borderRadius: BorderRadius.zero,
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.sandBorder),
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.espresso, width: 1.5),
              borderRadius: BorderRadius.zero,
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingOption({
    required int index,
    required String title,
    required String subtitle,
    required String price,
  }) {
    final isSelected = _shippingMethod == index;

    return InkWell(
      onTap: () => setState(() => _shippingMethod = index),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.paperWhite : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.espresso : AppColors.sandBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.pink : AppColors.muted,
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.button(color: AppColors.espresso),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.caption(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: AppTypography.price(
                color: isSelected ? AppColors.pink : AppColors.espresso,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == index;

    return InkWell(
      onTap: () => setState(() => _paymentMethod = index),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.paperWhite : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.espresso : AppColors.sandBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.pink : AppColors.muted,
              size: 20,
            ),
            const SizedBox(width: 14),
            Icon(icon, size: 22, color: AppColors.espresso),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.button(color: AppColors.espresso),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    final shippingFee = _calculateShippingFee(cart);
    final grandTotal = _calculateGrandTotal(cart);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.paperWhite,
        border: Border.all(color: AppColors.sandBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ORDER SUMMARY (${cart.itemCount})',
            style: AppTypography.button(color: AppColors.espresso),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.sandBorder),
          const SizedBox(height: 12),

          // Items Preview List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cart.items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: ErishImage(
                      imagePath: item.product.image,
                      width: 50,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.cardTitle(
                            color: AppColors.espresso,
                          ).copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Size: ${item.selectedSize} · Qty: ${item.quantity}',
                          style: AppTypography.caption(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.totalItemPrice}',
                    style: AppTypography.price(
                      color: AppColors.espresso,
                    ).copyWith(fontSize: 14),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.sandBorder),
          const SizedBox(height: 16),

          // Price Calculation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: AppTypography.body(color: AppColors.muted),
              ),
              Text(
                cart.formattedTotal,
                style: AppTypography.body(color: AppColors.espresso),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: AppTypography.body(color: AppColors.muted),
              ),
              Text(
                shippingFee == 0 ? 'FREE' : '₹$shippingFee',
                style: AppTypography.body(
                  color: shippingFee == 0
                      ? AppColors.softOlive
                      : AppColors.espresso,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.sandBorder),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GRAND TOTAL',
                style: AppTypography.button(color: AppColors.espresso),
              ),
              Text(
                '₹$grandTotal',
                style: AppTypography.price(
                  color: AppColors.pink,
                ).copyWith(fontSize: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
