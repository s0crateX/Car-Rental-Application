import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:intl/intl.dart';

import '../../../../../models/car owner  models/booking model/rent.dart';
import '../../../../../models/car owner  models/booking model/vehicle.dart';

class RentalDetailsScreen extends StatefulWidget {
  final Rent rent;
  
  const RentalDetailsScreen({super.key, required this.rent});

  @override
  State<RentalDetailsScreen> createState() => _RentalDetailsScreenState();
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // or your preferred background color
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class _RentalDetailsScreenState extends State<RentalDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            _buildAppBar(),
            SliverToBoxAdapter(
              child: _buildCarSection(),
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  labelColor: AppTheme.navy,
                  unselectedLabelColor: Colors.grey,
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 3.0, color: AppTheme.navy),
                    insets: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  tabs: const [
                    Tab(text: 'Renter'),
                    Tab(text: 'Payment'),
                    Tab(text: 'Details'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          children: [
            _buildRenterTab(),
            _buildPaymentTab(),
            _buildDetailsTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(),
    ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.navy,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroImage(),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Add share functionality
          },
          icon: const Icon(Icons.share),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.rent.carImageUrl != null && widget.rent.carImageUrl!.isNotEmpty)
          Image.network(
            widget.rent.carImageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
          )
        else
          _buildImagePlaceholder(),
        
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        
        // Car info overlay
        Positioned(
          bottom: 80,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.rent.carName ?? 'Vehicle',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatusChip(),
                  const SizedBox(width: 12),
                  Text(
                    'ID: ${widget.rent.id}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(
          Icons.directions_car,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 1.5),
      ),
      child: Text(
        widget.rent.status?.toUpperCase() ?? 'N/A',
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildCarSection() {
  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rental Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.navy,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Duration',
                _formatDuration(widget.rent.rentalPeriod),
                Icons.timer,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Cost',
                widget.rent.formatCurrency(widget.rent.totalPrice),
                Icons.payment,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Start Date',
                _formatDate(widget.rent.rentalPeriod?.startDate),
                Icons.calendar_today,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'End Date',
                _formatDate(widget.rent.rentalPeriod?.endDate),
                Icons.event,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}



  Widget _buildRenterTab() {
    return SizedBox.expand(
      child: SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            key: const PageStorageKey<String>('renter'),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      _buildDetailRow('Name', widget.rent.customerName ?? 'N/A', Icons.person),
                      if (widget.rent.customerPhone != null)
                        _buildDetailRow('Phone', widget.rent.customerPhone!, Icons.phone),
                      if (widget.rent.deliveryAddress?.address != null) ...[
                        const SizedBox(height: 16),
                        _buildDetailRow('Delivery Address', widget.rent.deliveryAddress!.address!, Icons.location_on),
                        if (widget.rent.deliveryAddress?.latitude != null && widget.rent.deliveryAddress?.longitude != null)
                          _buildDetailRow('Coordinates', 
                            '${widget.rent.deliveryAddress!.latitude}, ${widget.rent.deliveryAddress!.longitude}', 
                            Icons.map),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ));
  }

  Widget _buildPaymentTab() {
    return SizedBox.expand(
      child: SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            key: const PageStorageKey<String>('payment'),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      _buildDetailRow('Payment Method', widget.rent.paymentMethod ?? 'N/A', Icons.payment),
                      _buildDetailRow('Car Rental Cost', widget.rent.formatCurrency(widget.rent.carRentalCost ?? 0), Icons.directions_car),
                      _buildDetailRow('Total Amount', widget.rent.formatCurrency(widget.rent.totalPrice ?? 0), null, svgAsset: 'assets/svg/peso_blue.svg'),
                      if (widget.rent.downPayment != null && widget.rent.downPayment! > 0)
                        _buildDetailRow('Down Payment', widget.rent.formatCurrency(widget.rent.downPayment!), Icons.money),
                      
                      if (widget.rent.receiptImageUrl != null && widget.rent.receiptImageUrl!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Payment Receipt',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.navy,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.rent.receiptImageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ));
  }

  Widget _buildDetailsTab() {
    return SizedBox.expand(
      child: SafeArea(
      top: false,
      bottom: false,
      child: Builder(
        builder: (BuildContext context) {
          return CustomScrollView(
            key: const PageStorageKey<String>('details'),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(20.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      _buildDetailRow('Booking Type', widget.rent.bookingType?.toUpperCase() ?? 'N/A', Icons.category),
                      _buildDetailRow('Booking ID', widget.rent.id ?? 'N/A', Icons.confirmation_number),
                      if (widget.rent.notes != null && widget.rent.notes!.isNotEmpty)
                        _buildDetailRow('Notes', widget.rent.notes!, Icons.notes, isMultiline: true),
                      if (widget.rent.extraCharges?.notes != null && widget.rent.extraCharges!.notes!.isNotEmpty)
                        _buildDetailRow('Extra Charges Notes', widget.rent.extraCharges!.notes!, Icons.note_add, isMultiline: true),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ));
  }

  Widget _buildDetailRow(String label, String value, IconData? icon, {bool isMultiline = false, String? svgAsset}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: svgAsset != null
                ? SvgPicture.asset(svgAsset, color: AppTheme.lightBlue, width: 16, height: 16)
                : Icon(icon, color: AppTheme.lightBlue, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: isMultiline ? null : 2,
                  overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, yyyy, h:mm a').format(date);
  }

  String _formatDuration(RentalPeriod? period) {
    if (period == null || period.startDate == null || period.endDate == null) {
      return 'N/A';
    }
    final duration = period.endDate!.difference(period.startDate!);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    return '${days}d ${hours}h';
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _updateBookingStatus('CONFIRMED'),
              icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle,color: Colors.white),
              label: Text(_isLoading ? 'Processing...' : 'Approve'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _updateBookingStatus('CANCELLED'),
              icon: const Icon(Icons.cancel,color: Colors.white),
              label: const Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, yyyy hh:mm a').format(date);
  }

  String formatDuration(RentalPeriod? period) {
    if (period == null) return 'N/A';
    
    String duration = '';
    if (period.days != null && period.days! > 0) {
      duration += '${period.days} day${period.days! > 1 ? 's' : ''}';
    }
    if (period.hours != null && period.hours! > 0) {
      if (duration.isNotEmpty) duration += ', ';
      duration += '${period.hours} hour${period.hours! > 1 ? 's' : ''}';
    }
    return duration.isNotEmpty ? duration : 'N/A';
  }

  Color _getStatusColor() {
    switch (widget.rent.status?.toUpperCase()) {
      case 'CONFIRMED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _updateBookingStatus(String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final batch = FirebaseFirestore.instance.batch();
      final originalDocRef = FirebaseFirestore.instance.collection('rent_request').doc(widget.rent.id);

      if (status == 'CONFIRMED') {
        final newDocRef = FirebaseFirestore.instance.collection('rent_approve').doc(widget.rent.id);
        final approvedRentData = widget.rent.toMap()..['status'] = 'CONFIRMED';
        batch.set(newDocRef, approvedRentData);
        batch.delete(originalDocRef);
      } else if (status == 'CANCELLED') {
        final newDocRef = FirebaseFirestore.instance.collection('rent_rejected').doc(widget.rent.id);
        final rejectedRentData = widget.rent.toMap()..['status'] = 'CANCELLED';
        batch.set(newDocRef, rejectedRentData);
        batch.delete(originalDocRef);
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking has been ${status.toLowerCase()}'),
            backgroundColor: status == 'CONFIRMED' ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}