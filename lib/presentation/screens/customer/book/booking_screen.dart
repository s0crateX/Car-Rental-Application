import 'package:car_rental_app/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/approved_tab.dart';
import 'widgets/completed_tab.dart';
import 'widgets/rejected_tab.dart';
import 'widgets/requests_tab.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _onRefresh() async {
    // Simulate a network request
    await Future.delayed(const Duration(seconds: 2));
    // Add your refresh logic here, e.g., re-fetch data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkNavy,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Column(
        children: [
          // Custom header with modern tab design
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkNavy,
             
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header spacing
                  const SizedBox(height: 16),
                  
                  // Clean modern tab container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.navy.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.lightBlue.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppTheme.darkNavy,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: AppTheme.white,
                      unselectedLabelColor: AppTheme.paleBlue.withOpacity(0.8),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1.2,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        height: 1.2,
                      ),
                      tabs: [
                        _buildTab(
                          asset: 'assets/svg/clock-hour-3.svg',
                          label: 'Pending',
                        ),
                        _buildTab(
                          asset: 'assets/svg/circle-check.svg',
                          label: 'Approved',
                        ),
                        _buildTab(
                          asset: 'assets/svg/alert-square-rounded.svg',
                          label: 'Rejected',
                        ),
                        _buildTab(
                          asset: 'assets/svg/progress-check.svg',
                          label: 'Done',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                RequestsTab(),
                ApprovedTab(),
                RejectedTab(),
                CompletedTab(),
              ],
            ),
          ),
        ],
      ),
    ),);
  }
  
  Widget _buildTab({
    required String asset,
    required String label,
  }) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        final isSelected = _tabController.index == _getTabIndex(label);
        final color = isSelected ? AppTheme.white : AppTheme.lightBlue.withOpacity(0.7);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                asset,
                height: 18,
                width: 18,
                color: color,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
  
  int _getTabIndex(String label) {
    switch (label) {
      case 'Pending':
        return 0;
      case 'Approved':
        return 1;
      case 'Rejected':
        return 2;
      case 'Done':
        return 3;
      default:
        return 0;
    }
  }
}