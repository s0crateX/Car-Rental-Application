import 'package:car_rental_app/models/car%20owner%20%20models/booking%20model/rent.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:intl/intl.dart';

import '../../../../../models/car owner  models/booking model/vehicle.dart';
import '../screens/rental_details_screen.dart';

class BookingInfoCard extends StatelessWidget {
  final Rent rent;
  final bool isHistory;
  const BookingInfoCard({super.key, required this.rent, this.isHistory = false});

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
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.navy, AppTheme.navy.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with car image and key info
            _buildHeader(),
            
            // Compact info section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCompactInfoGrid(),
                  const SizedBox(height: 12),
                  _buildBottomRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.grey[900],
      ),
      child: Stack(
        children: [
          // Car image
          if (rent.carImageUrl != null && rent.carImageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                rent.carImageUrl!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildImagePlaceholder();
                },
              ),
            )
          else
            _buildImagePlaceholder(),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Header content
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rent.carName ?? 'Vehicle',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${rent.id}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
          ),
          
          // Bottom info
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Icon(Icons.person, color: AppTheme.lightBlue, size: 16),
                const SizedBox(width: 6),
                Text(
                  rent.customerName ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7), size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: const Center(
        child: Icon(
          Icons.directions_car,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color statusColor = _getStatusColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        rent.status?.toUpperCase() ?? 'N/A',
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildCompactInfoGrid() {
    final lateDuration = isHistory ? _calculateLateDuration() : null;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoChip(
                Icons.calendar_today,
                'Start',
                _formatCompactDate(rent.rentalPeriod?.startDate),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoChip(
                Icons.event,
                'End',
                _formatCompactDate(rent.rentalPeriod?.endDate),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInfoChip(
                Icons.timer,
                'Duration',
                _formatDuration(rent.rentalPeriod),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoChip(
                Icons.payment,
                'Total',
                rent.formatCurrency(rent.totalPrice),
              ),
            ),
          ],
        ),
        if (lateDuration != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildInfoChip(
              Icons.warning_amber_rounded,
              'Late Return',
              lateDuration,
              chipColor: Colors.red.withOpacity(0.1),
              iconColor: Colors.red,
              labelColor: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value, {
    Color chipColor = const Color.fromRGBO(255, 255, 255, 0.1),
    Color iconColor = AppTheme.lightBlue,
    Color labelColor = AppTheme.lightBlue,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        if (rent.bookingType != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rent.bookingType!.toUpperCase(),
              style: TextStyle(
                color: AppTheme.lightBlue,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (rent.customerPhone != null) ...[
          Icon(Icons.phone, color: AppTheme.lightBlue, size: 14),
          const SizedBox(width: 4),
          Text(
            rent.customerPhone!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const Spacer(),
        ],
        if (rent.deliveryAddress?.address != null) ...[
          Icon(Icons.location_on, color: Colors.orange, size: 14),
          const SizedBox(width: 4),
          Text(
            'Delivery',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
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
    if (status == 'PENDING' || status == 'CANCELLED' || rent.rentalPeriod?.endDate == null) {
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
}