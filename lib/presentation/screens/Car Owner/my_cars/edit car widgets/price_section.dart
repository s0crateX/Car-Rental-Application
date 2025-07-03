import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PricingSection extends StatelessWidget {
  final TextEditingController price6hController;
  final TextEditingController price12hController;
  final TextEditingController price1dController;
  final TextEditingController price1wController;
  final TextEditingController price1mController;

  const PricingSection({
    super.key,
    required this.price6hController,
    required this.price12hController,
    required this.price1dController,
    required this.price1wController,
    required this.price1mController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Pricing Structure', Icons.attach_money),
        const SizedBox(height: 16),

        _buildInfoCard(
          'Set competitive prices for different rental durations. '
          'Consider market rates and your car\'s value when pricing.',
          Icons.info_outline,
        ),
        const SizedBox(height: 20),

        // Short term pricing
        _buildPricingCategory('Short Term Rentals', Icons.schedule, [
          _buildPriceCard(
            controller: price6hController,
            title: '6 Hours',
            subtitle: 'Half day rental',
            icon: Icons.wb_sunny,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildPriceCard(
            controller: price12hController,
            title: '12 Hours',
            subtitle: 'Full day rental',
            icon: Icons.brightness_6,
            color: Colors.blue,
          ),
        ]),
        const SizedBox(height: 24),

        // Long term pricing
        _buildPricingCategory('Long Term Rentals', Icons.date_range, [
          _buildPriceCard(
            controller: price1dController,
            title: '1 Day',
            subtitle: '24 hours',
            icon: Icons.today,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildPriceCard(
            controller: price1wController,
            title: '1 Week',
            subtitle: '7 days',
            icon: Icons.view_week,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildPriceCard(
            controller: price1mController,
            title: '1 Month',
            subtitle: '30 days',
            icon: Icons.calendar_month,
            color: Colors.teal,
          ),
        ]),
        const SizedBox(height: 20),

        _buildPricingSummary(),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightBlue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.lightBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.lightBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCategory(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildPriceCard({
    required TextEditingController controller,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SvgPicture.asset(
                      'assets/svg/peso.svg',
                      width: 16,
                      height: 16,
                      color: color,
                    ),
                  ),
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navy.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                'Pricing Tips',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip('Research competitor pricing in your area'),
          _buildTip('Offer discounts for longer rental periods'),
          _buildTip('Consider seasonal adjustments'),
          _buildTip('Factor in fuel, insurance, and maintenance costs'),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
