import 'package:flutter/material.dart';
import '../../../../../shared/models/car_model.dart';
import 'widgets/car_app_bar.dart';
import 'widgets/car_bottom_bar.dart';
import 'widgets/car_header_info.dart';
import 'widgets/car_tab_bar.dart';
import 'widgets/details_tab_content.dart';
import 'widgets/features_tab_content.dart';
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
      body: CustomScrollView(
        slivers: [
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
          
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car Name and Rating
                CarHeaderInfo(car: widget.car),

                // Tabs
                CarTabBar(tabController: _tabController),

                // Tab Content
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6, // Adjust this value as needed
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Details Tab
                      SingleChildScrollView(
                        child: DetailsTabContent(
                          car: widget.car,
                          formatDate: _formatDate,
                          sectionTitleBuilder: _sectionTitle,
                        ),
                      ),

                      // Features Tab
                      SingleChildScrollView(
                        child: FeaturesTabContent(
                          car: widget.car,
                          sectionTitleBuilder: _sectionTitle,
                        ),
                      ),

                      // Reviews Tab
                      SingleChildScrollView(
                        child: ReviewsTabContent(
                          car: widget.car,
                          sectionTitleBuilder: _sectionTitle,
                          formatDate: _formatDate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
