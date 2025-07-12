import 'package:car_rental_app/models/customer%20models/booking%20model/rent_request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:car_rental_app/config/theme.dart';
import 'package:intl/intl.dart';

class RentRequestInfoCard extends StatelessWidget {
  final RentRequest rentRequest;
  const RentRequestInfoCard({super.key, required this.rentRequest});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { /* Handle tap if needed */ },
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
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCompactInfoGrid(),
                  const SizedBox(height: 12),
                  _buildBottomRow(context),
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
          if (rentRequest.carImageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                rentRequest.carImageUrl,
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
                        rentRequest.carName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${rentRequest.id}',
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
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Icon(Icons.person, color: AppTheme.lightBlue, size: 16),
                const SizedBox(width: 6),
                Text(
                  rentRequest.customerName,
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
        rentRequest.status,
        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCompactInfoGrid() {
    final startDate = (rentRequest.rentalPeriod['startDate'] as Timestamp).toDate();
    final endDate = (rentRequest.rentalPeriod['endDate'] as Timestamp).toDate();
    return Column(
      children: [
        _buildInfoRow(Icons.calendar_today, 'From', DateFormat('MMM d, yyyy').format(startDate)),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.calendar_today, 'To', DateFormat('MMM d, yyyy').format(endDate)),
      ],
    );
  }

  Future<void> _cancelBooking(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('rent_request')
          .doc(rentRequest.id)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled and removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling booking: $e')),
      );
    }
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total: ₱${rentRequest.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton(
          onPressed: () => _cancelBooking(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Cancel', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.lightBlue),
        const SizedBox(width: 8),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        Text(value),
      ],
    );
  }

  Color _getStatusColor() {
    switch (rentRequest.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return AppTheme.lightBlue;
      default:
        return Colors.grey;
    }
  }
}