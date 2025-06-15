import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../shared/models/car_model.dart';

class FeaturesTabContent extends StatelessWidget {
  final CarModel car;
  final Widget Function(String) sectionTitleBuilder;

  const FeaturesTabContent({
    super.key,
    required this.car,
    required this.sectionTitleBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitleBuilder('Car Features'),
          const SizedBox(height: 16),
          ...car.features.map((feature) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2.0),
                    child: SvgPicture.asset(
                      'assets/svg/check.svg',
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodyMedium,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            );
          }),
          // Add some bottom padding to ensure content doesn't get cut off
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
