import 'package:car_rental_app/models/car%20owner%20%20models/booking%20model/rent.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:car_rental_app/shared/constants/asset_paths.dart';

import '../../../../../core/authentication/auth_service.dart';
import '../../../../../models/car owner  models/booking model/vehicle.dart';
import '../screens/rental_details_screen.dart';

class BookingInfoCard extends StatelessWidget {
  final Rent rent;
  final bool isHistory;
  final bool isRequest;
  final bool isCarOwner;
  
  const BookingInfoCard({
    super.key,
    required this.rent,
    this.isHistory = false,
    this.isRequest = false,
    this.isCarOwner = false,
  });

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RentalDetailsScreen(
          rent: rent,
          isHistory: isHistory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isCustomer = authService.isCustomer;
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.navy,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Compact header with car image
            _buildCompactHeader(),
            
            // Main content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car name and rental period in one row
                  _buildCarAndDateRow(),
                  
                  const SizedBox(height: 12),
                  
                  // Duration and total price
                  _buildDurationAndPriceRow(),
                  
                  const SizedBox(height: 12),
                  
                  // Customer details in compact format
                  _buildCompactCustomerInfo(),
                  
                  const SizedBox(height: 12),
                  
                  // Action buttons
                  if (isCarOwner || (isCustomer && isRequest))
                    _buildCompactActionRow(context, isCustomer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader() {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          // Car image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: rent.carImageUrl != null && rent.carImageUrl!.isNotEmpty
                ? Image.network(
                    rent.carImageUrl!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [
                  AppTheme.black.withOpacity(0.4),
                  Colors.transparent,
                  AppTheme.black.withOpacity(0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Status chip
          Positioned(
            top: 12,
            right: 12,
            child: _buildCompactStatusChip(),
          ),
          
          // Booking ID
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ID: ${rent.id}',
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.navy.withOpacity(0.8), AppTheme.navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: SvgPicture.asset(
          AssetPaths.car,
          height: 32,
          width: 32,
          color: AppTheme.white.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildCompactStatusChip() {
    Color statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        rent.status?.toUpperCase() ?? 'N/A',
        style: const TextStyle(
          color: AppTheme.white,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildCarAndDateRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rent.carName ?? 'Vehicle',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (_calculateLateDuration() != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Late: ${_calculateLateDuration()!}',
                    style: const TextStyle(
                      color: AppTheme.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatCompactDate(rent.rentalPeriod?.startDate)} - ${_formatCompactDate(rent.rentalPeriod?.endDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationAndPriceRow() {
    return Row(
      children: [
        Expanded(
          child: _buildCompactInfoChip(
            AssetPaths.calendarWeek,
            _formatDuration(rent.rentalPeriod),
            AppTheme.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildCompactInfoChip(
            AssetPaths.peso,
            rent.formatCurrency(rent.totalPrice),
            AppTheme.green,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactInfoChip(String assetName, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(assetName, color: color, height: 14, width: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCustomerInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Customer name
          Row(
            children: [
              SvgPicture.asset(AssetPaths.user, height: 14, width: 14, color: AppTheme.white),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  rent.customerName ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 6),
          
          // Phone, booking type, and delivery info
          Row(
            children: [
              // Phone
              if (rent.customerPhone != null) ...[
                SvgPicture.asset(AssetPaths.phone, height: 12, width: 12, color: AppTheme.white),
                const SizedBox(width: 4),
                Text(
                  '+63 ${rent.customerPhone!}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              
              // Booking type
              if (rent.bookingType != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    rent.bookingType!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      color: AppTheme.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              // Delivery indicator
              if (rent.deliveryAddress?.address != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(AssetPaths.location, height: 10, width: 10, color: AppTheme.orange),
                      const SizedBox(width: 2),
                      Text(
                        'DELIVERY',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppTheme.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          // Delivery address (if available)
          if (rent.deliveryAddress?.address != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                SvgPicture.asset(AssetPaths.location, height: 12, width: 12, color: AppTheme.white),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    rent.deliveryAddress!.address!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactActionRow(BuildContext context, bool isCustomer) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _navigateToDetails(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.navy,
              side: BorderSide(color: AppTheme.navy),
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'View Details',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        
        if (isRequest && isCustomer) ...[
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showCancelDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetPaths.trash,
                    height: 14,
                    width: 14,
                    color: AppTheme.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.darkNavy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              SvgPicture.asset(
                AssetPaths.alertSquareRounded,
                height: 24,
                width: 24,
                color: AppTheme.orange,
              ),
              const SizedBox(width: 12),
              const Text('Cancel Booking', style: TextStyle(color: AppTheme.white)),
            ],
          ),
          content: const Text(
            'Are you sure you want to cancel this booking request?',
            style: TextStyle(color: AppTheme.paleBlue),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep Booking', style: TextStyle(color: AppTheme.lightBlue, fontSize: 11)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelBooking(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Confirm', style: TextStyle(fontSize: 11),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelBooking(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('rent_request')
          .doc(rent.id)
          .delete();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking request cancelled successfully'),
            backgroundColor: AppTheme.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling request: $e'),
            backgroundColor: AppTheme.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  String _formatCompactDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d').format(date);
  }

  String _formatDuration(RentalPeriod? period) {
    if (period == null) return 'N/A';
    
    String duration = '';
    if (period.days != null && period.days! > 0) {
      duration += '${period.days}d';
    }
    if (period.hours != null && period.hours! > 0) {
      if (duration.isNotEmpty) duration += ' ';
      duration += '${period.hours}h';
    }
    return duration.isNotEmpty ? duration : 'N/A';
  }

  String? _calculateLateDuration() {
    final status = rent.status?.toUpperCase();
    if (status != 'CONFIRMED' || rent.rentalPeriod?.endDate == null) {
      return null;
    }

    final now = DateTime.now().toUtc();
    final endDate = rent.rentalPeriod!.endDate!.toUtc();

    if (now.isBefore(endDate)) {
      return null;
    }

    final difference = now.difference(endDate);
    final days = difference.inDays;
    final hours = difference.inHours % 24;

    String duration = '';
    if (days > 0) {
      duration += '${days}d ';
    }
    if (hours > 0) {
      duration += '${hours}h';
    }

    return duration.trim().isNotEmpty ? duration.trim() : 'Late';
  }

  Color _getStatusColor() {
    switch (rent.status?.toUpperCase()) {
      case 'CONFIRMED':
        return AppTheme.green;
      case 'PENDING':
        return AppTheme.orange;
      case 'CANCELLED':
        return AppTheme.red;
      case 'COMPLETED':
        return AppTheme.blue;
      default:
        return AppTheme.mediumBlue;
    }
  }
}