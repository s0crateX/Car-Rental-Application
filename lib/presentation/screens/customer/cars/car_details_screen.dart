import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_rental_app/core/authentication/auth_service.dart';
import 'package:car_rental_app/presentation/screens/customer/owner/owner_cars_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../models/Firebase_car_model.dart';
import 'widgets/car_app_bar.dart';
import 'widgets/car_bottom_bar.dart';
import 'widgets/car_header_info.dart';
import 'widgets/car_tab_bar.dart';
import 'widgets/details_tab_content.dart';
import 'widgets/reviews_tab_content.dart';
import 'widgets/issues_tab_content.dart';

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
          physics: const ClampingScrollPhysics(),
          dragStartBehavior: DragStartBehavior.start,
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

            // Issues Tab
            IssuesTabContent(
              car: widget.car,
              sectionTitleBuilder: _sectionTitle,
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
                    const SizedBox(height: 10),
                    OwnerInfoWidget(carOwnerDocumentId: car.carOwnerDocumentId),
                  ],
                ),
              ),
            ),

            // Tab Bar - Fixed height container at the bottom
            Container(
              height: tabBarHeight,
              child: CarTabBar(tabController: tabController),
            ),
          ],
        ),
      ),
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

class OwnerInfoWidget extends StatefulWidget {
  final String carOwnerDocumentId;

  const OwnerInfoWidget({super.key, required this.carOwnerDocumentId});

  @override
  State<OwnerInfoWidget> createState() => _OwnerInfoWidgetState();
}

class _OwnerInfoWidgetState extends State<OwnerInfoWidget> {
  late Future<Map<String, dynamic>?> _ownerFuture;

  @override
  void initState() {
    super.initState();
    final authService = Provider.of<AuthService>(context, listen: false);
    _ownerFuture = authService.getUserById(widget.carOwnerDocumentId);
  }

  // Helper method to format messenger URL properly
  String _formatMessengerUrl(String messengerLink) {
    String link = messengerLink.trim();
    
    // If it's already a complete messenger URL, return as is
    if (link.startsWith('https://m.me/') || 
        link.startsWith('https://messenger.com/t/') ||
        link.startsWith('http://m.me/')) {
      return link;
    }
    
    // If it starts with m.me/, add https://
    if (link.startsWith('m.me/')) {
      return 'https://$link';
    }
    
    // If it's just a username or profile ID, format as m.me URL
    if (!link.contains('/') && !link.startsWith('http')) {
      return 'https://m.me/$link';
    }
    
    // If it's a facebook.com profile URL, extract username and convert
    if (link.contains('facebook.com/')) {
      RegExp regExp = RegExp(r'facebook\.com/([^/?]+)');
      Match? match = regExp.firstMatch(link);
      if (match != null) {
        String username = match.group(1)!;
        return 'https://m.me/$username';
      }
    }
    
    // Default: ensure it has https://
    if (!link.startsWith('http://') && !link.startsWith('https://')) {
      return 'https://$link';
    }
    
    return link;
  }

  // Method to launch messenger with fallback options
  Future<void> _launchMessenger(String messengerLink, BuildContext context) async {
    try {
      String formattedUrl = _formatMessengerUrl(messengerLink);
      Uri url = Uri.parse(formattedUrl);
      
      // Try to launch the URL
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        // If that fails, try with platformDefault mode
        launched = await launchUrl(
          url,
          mode: LaunchMode.platformDefault,
        );
      }
      
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Messenger. Please check the link or install Messenger app.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening Messenger: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _ownerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Could not load owner info'));
        }

        final ownerData = snapshot.data!;
        final ownerName = ownerData['fullName'] ?? 'Car Owner';
        final ownerImageUrl = ownerData['profileImageUrl'];
        final messengerLink = ownerData['messengerLink'];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OwnerCarsScreen(
                  ownerId: widget.carOwnerDocumentId,
                  ownerName: ownerName,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Row(
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
                                const Icon(Icons.person, size: 30),
                          ),
                        )
                      : const CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.person, size: 20),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: $ownerName',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (ownerData['organizationName'] != null &&
                          ownerData['organizationName'].isNotEmpty)
                        Text(
                          'Organization: ${ownerData['organizationName']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      if (ownerData['phoneNumber'] != null &&
                          ownerData['phoneNumber'].isNotEmpty)
                        Text(
                          'Phone: ${ownerData['phoneNumber']}',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (messengerLink != null && messengerLink.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _launchMessenger(messengerLink, context),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'assets/svg/brand-messenger.svg',
                          width: 24,
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.blue,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}