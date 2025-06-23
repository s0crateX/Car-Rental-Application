import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/presentation/screens/Car%20Owner/home/widgets/widgets.dart';
import 'package:car_rental_app/shared/models/rental_request.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  // Sample data - In a real app, this would come from a state management solution
  final int totalCars = 12;
  final int rentedCars = 5;
  final int lateReturns = 2;
  final int vacantCars = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // TODO: Implement refresh logic
            await Future.delayed(const Duration(seconds: 1));
          },
          child: CustomScrollView(
            slivers: [
              // Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          SummaryCard(
                            title: 'Total Cars',
                            count: totalCars,
                            iconPath: 'assets/svg/car2.svg',
                            color: AppTheme.mediumBlue,
                          ),
                          SummaryCard(
                            title: 'Rented Cars',
                            count: rentedCars,
                            iconPath: 'assets/svg/car-rental2.svg',
                            iconColor: AppTheme.white,
                            color: const Color(0xFF10B981), // Green
                          ),
                          SummaryCard(
                            title: 'Late Returns',
                            count: lateReturns,
                            iconPath: 'assets/svg/warning.svg',
                            color: const Color(0xFFF59E0B), // Amber
                          ),
                          SummaryCard(
                            title: 'Vacant Cars',
                            count: vacantCars,
                            iconPath: 'assets/svg/parking.svg',
                            color: const Color(0xFF0D9488), // Teal
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Rental Requests Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Rental Requests',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Rental Requests List
              sampleRentalRequests.isEmpty
                  ? const SliverFillRemaining(
                    child: Center(
                      child: Text('No rental requests at the moment'),
                    ),
                  )
                  : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final request = sampleRentalRequests[index];
                      return RentalRequestItem(
                        request: request,
                        onViewDetails: () {
                          // TODO: Show request details
                        },
                        onApprove: () {
                          // TODO: Implement approve logic
                        },
                        onReject: () {
                          // TODO: Implement reject logic
                        },
                      );
                    }, childCount: sampleRentalRequests.length),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
