import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/erish_button.dart';
import '../../../core/widgets/erish_image.dart';
import '../../../models/cart_item.dart';

/// ERISH Official Order Confirmation Page
/// Displays celebration banner, confirmed order ID, customer delivery destination,
/// payment receipt, itemized breakdown, and action to return to storefront.
class OrderConfirmationPage extends StatelessWidget {
  final Map<String, dynamic>? orderDetails;

  const OrderConfirmationPage({super.key, this.orderDetails});

  @override
  Widget build(BuildContext context) {
    if (orderDetails == null || orderDetails!.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.warmIvory,
        appBar: AppBar(
          backgroundColor: AppColors.warmIvory,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: () => context.go('/'),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Image.asset(
                'assets/images/erish-logo.png',
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Text(
                  'ERISH',
                  style: AppTypography.cardTitle(color: AppColors.espresso),
                ),
              ),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 48,
                  color: AppColors.muted,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Active Order Found',
                  style: AppTypography.sectionTitle(color: AppColors.espresso),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Text(
                    'If you recently placed an order, a confirmation receipt has been sent to your email. You can track your shipment anytime with your order ID.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(color: AppColors.muted),
                  ),
                ),
                const SizedBox(height: 28),
                ErishButton(
                  text: 'Return to Storefront',
                  onPressed: () => context.go('/'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final details = orderDetails!;
    final orderId = details['orderId'] ?? '';
    final customerName = details['customerName'] ?? 'Customer';
    final email = details['email'] ?? '';
    final address = details['address'] ?? '';
    final paymentMethod = details['paymentMethod'] ?? 'UPI / Cards';
    final totalAmount = details['totalAmount'] ?? 0;
    final items = (details['items'] as List<CartItem>?) ?? [];

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => context.go('/'),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Image.asset(
              'assets/images/erish-logo.png',
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                'ERISH',
                style: AppTypography.cardTitle(color: AppColors.espresso),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 20.0,
                vertical: 40.0,
              ),
              child: Column(
                children: [
                  // Celebration Icon & Headline
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.pink.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        color: AppColors.pink,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Order Confirmed!',
                    style: AppTypography.sectionTitle(
                      color: AppColors.espresso,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Thank you, $customerName. Your order has been placed successfully.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(color: AppColors.espresso),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    color: AppColors.espresso,
                    child: Text(
                      'ORDER ID: $orderId',
                      style: AppTypography.button(color: AppColors.warmIvory),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Order & Shipping Information Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.paperWhite,
                      border: Border.all(color: AppColors.sandBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DELIVERY DETAILS',
                          style: AppTypography.button(
                            color: AppColors.espresso,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.sandBorder),
                        const SizedBox(height: 16),
                        _buildInfoRow('Shipping Address', address),
                        const SizedBox(height: 12),
                        _buildInfoRow('Confirmation Sent To', email),
                        const SizedBox(height: 12),
                        _buildInfoRow('Payment Method', paymentMethod),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Estimated Delivery',
                          '4–6 Business Days (Dispatched within 24 hours)',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Itemized Receipt
                  if (items.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.paperWhite,
                        border: Border.all(color: AppColors.sandBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER RECEIPT',
                            style: AppTypography.button(
                              color: AppColors.espresso,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.sandBorder),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            separatorBuilder: (_, index) => const Divider(
                              color: AppColors.sandBorder,
                              height: 20,
                            ),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.zero,
                                    child: ErishImage(
                                      imagePath: item.product.image,
                                      width: 48,
                                      height: 62,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: AppTypography.cardTitle(
                                            color: AppColors.espresso,
                                          ).copyWith(fontSize: 16),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Size: ${item.selectedSize} · Qty: ${item.quantity}',
                                          style: AppTypography.caption(
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₹${item.totalItemPrice}',
                                    style: AppTypography.price(
                                      color: AppColors.espresso,
                                    ).copyWith(fontSize: 15),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: AppColors.sandBorder),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL PAID',
                                style: AppTypography.button(
                                  color: AppColors.espresso,
                                ),
                              ),
                              Text(
                                '₹$totalAmount',
                                style: AppTypography.price(
                                  color: AppColors.pink,
                                ).copyWith(fontSize: 22),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],

                  // Action Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 14,
                    alignment: WrapAlignment.center,
                    children: [
                      ErishButton(
                        text: 'Continue Shopping',
                        onPressed: () => context.go('/'),
                      ),
                      ErishButton.ghost(
                        text: 'Email Receipt',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Tax invoice and receipt sent to $email ✦',
                                style: AppTypography.button(
                                  color: AppColors.warmIvory,
                                ),
                              ),
                              backgroundColor: AppColors.espresso,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 170,
          child: Text(
            label,
            style: AppTypography.caption(
              color: AppColors.muted,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.body(
              color: AppColors.espresso,
            ).copyWith(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
