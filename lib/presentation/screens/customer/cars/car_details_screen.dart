import 'package:flutter/material.dart';
import '../../../../shared/models/Final Model/Firebase_car_model.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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
                child: CarHeaderInfo(car: car),
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

  @override
  double get maxExtent => 180.0; // Increased height to accommodate content

  @override
  double get minExtent => 180.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate is! _StickyHeaderDelegate ||
        oldDelegate.car != car ||
        oldDelegate.tabController != tabController;
  }
}
