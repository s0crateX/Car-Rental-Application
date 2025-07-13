import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/presentation/screens/customer/owner/owner_cars_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/Firebase_car_model.dart';
import 'widgets/car_app_bar.dart';
import 'widgets/car_bottom_bar.dart';
import 'widgets/car_header_info.dart';
import 'widgets/car_tab_bar.dart';
import 'widgets/details_tab_content.dart';
import 'widgets/reviews_tab_content.dart';

class CarDetailsScreen extends StatefulWidget {
  final CarModel car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar
            CarAppBar(
              car: widget.car,
              currentImageIndex: _currentImageIndex,
              onImageTap: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),

            // Sticky Header (Car Name, Rating, and Tabs)
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                car: widget.car,
                tabController: _tabController,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Details Tab
            DetailsTabContent(
              car: widget.car,
              formatDate: _formatDate,
              sectionTitleBuilder: _sectionTitle,
            ),

            // Reviews Tab
            ReviewsTabContent(
              car: widget.car,
              sectionTitleBuilder: _sectionTitle,
              formatDate: _formatDate,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CarBottomBar(car: widget.car),
    );
  }

  // Helper widgets
  Widget _sectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineMedium);
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final CarModel car;
  final TabController tabController;
  static const double tabBarHeight = 48.0;

  _StickyHeaderDelegate({required this.car, required this.tabController});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: overlapsContent ? 4.0 : 0.0,
      child: SizedBox(
        height: maxExtent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Car Header Info - Use Expanded to take available space
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    CarHeaderInfo(car: car),
                    SizedBox(height: 10),
                    _buildOwnerInfo(context),
                  ],
                ),
              ),
            ),

            // Tab Bar - Fixed height container at the bottom
            SizedBox(
              height: tabBarHeight,
              child: CarTabBar(tabController: tabController),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerInfo(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getUserById(car.carOwnerDocumentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Could not load owner info'));
        }

        final ownerData = snapshot.data!;
        final ownerName = ownerData['fullName'] ?? 'Car Owner';
        final ownerImageUrl = ownerData['profileImageUrl'];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OwnerCarsScreen(
                  ownerId: car.carOwnerDocumentId,
                  ownerName: ownerName,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              SizedBox(
                width: 40,
                height: 40,
                child: ownerImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: CachedNetworkImage(
                          imageUrl: ownerImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person, size: 40),
                        ),
                      )
                    : const CircleAvatar(
                        radius: 20,
                        child: Icon(Icons.person, size: 20),
                      ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: $ownerName',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (ownerData['organizationName'] != null && ownerData['organizationName'].isNotEmpty)
                    Text(
                      'Organization: ${ownerData['organizationName']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
       );
      },
    );
  }

  @override
  double get maxExtent => 260.0; // Increased height to accommodate content

  @override
  double get minExtent => 260.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate is! _StickyHeaderDelegate ||
        oldDelegate.car != car ||
        oldDelegate.tabController != tabController;
  }
}
