import 'package:flutter/material.dart';

import 'order_screen.dart';
import 'package:yummy/features/orders/domain/entities/order_enums.dart';

class QuickBillingScreen extends StatelessWidget {
  const QuickBillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Billing')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Quick Bill',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start a quick bill for takeaway or counter orders.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/order-screen',
                  arguments: const OrderScreenArgs(
                    contextLabel: 'Quick Bill',
                    channel: OrderChannel.quickBilling,
                  ),
                ),
                child: const Text('Start Quick Billing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
