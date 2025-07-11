import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/models/Firebase_car_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:car_rental_app/presentation/screens/Car Owner/my_cars/edit_car_details_screen.dart';

class SampleCarData {
  final String name;
  final String brand;
  final String model;
  final String image; // Keep for backward compatibility
  final List<String> imageGallery; // List of image URLs
  final double price;
  final String pricePeriod;
  final String seatsCount;
  final String luggageCapacity;
  final String transmissionType;
  final String fuelType;
  final String year;
  final bool isAvailable;

  SampleCarData({
    required this.name,
    required this.brand,
    required this.model,
    required this.image,
    required this.imageGallery,
    required this.price,
    required this.pricePeriod,
    required this.seatsCount,
    required this.luggageCapacity,
    required this.transmissionType,
    required this.fuelType,
    required this.year,
    required this.isAvailable,
  });
}

class OwnerCarCard extends StatefulWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final CarModel carData; // Now required and of type CarModel

  const OwnerCarCard({
    super.key,
    required this.carData,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  State<OwnerCarCard> createState() => _OwnerCarCardState();
}

class _OwnerCarCardState extends State<OwnerCarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  late CarModel car;

  @override
  void initState() {
    super.initState();
    car = widget.carData;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
    );

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.navy, AppTheme.navy.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      _isPressed
                          ? AppTheme.lightBlue.withOpacity(0.5)
                          : AppTheme.mediumBlue.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: AppTheme.lightBlue.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Header with car image and quick info
                    _buildCarHeader(theme, currencyFormat),
                    // Main content area
                    _buildMainContent(theme, currencyFormat),
                    // Action buttons footer
                    _buildActionFooter(theme),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarHeader(ThemeData theme, NumberFormat currencyFormat) {
    return Container(
      height: 180, // Increased height to accommodate more content
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.mediumBlue.withOpacity(0.2),
            AppTheme.darkNavy.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(child: CustomPaint(painter: _PatternPainter())),

          // Car image - positioned on the right
          Positioned(
            right: 16,
            top: 16,
            child: Hero(
              tag: 'car_image_${car.type}_${car.brand}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child:
                    (car.imageGallery.isNotEmpty)
                        ? SizedBox(
                          width:
                              100, // Reduced width to give more space for text
                          height: 80, // Reduced height
                          child: PageView.builder(
                            itemCount: car.imageGallery.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                car.imageGallery[index],
                                width: 100,
                                height: 80,
                                fit: BoxFit.cover,
                                loadingBuilder: (
                                  context,
                                  child,
                                  loadingProgress,
                                ) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      width: 100,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppTheme.darkNavy.withOpacity(
                                          0.5,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppTheme.lightBlue.withOpacity(
                                            0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.directions_car,
                                            color: AppTheme.lightBlue
                                                .withOpacity(0.7),
                                            size: 24,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'No Image',
                                            style: TextStyle(
                                              color: AppTheme.paleBlue
                                                  .withOpacity(0.7),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              );
                            },
                          ),
                        )
                        : Image.asset(
                          car.image,
                          width: 100,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 100,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.darkNavy.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppTheme.lightBlue.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      color: AppTheme.lightBlue.withOpacity(
                                        0.7,
                                      ),
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No Image',
                                      style: TextStyle(
                                        color: AppTheme.paleBlue.withOpacity(
                                          0.7,
                                        ),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ),
              ),
            ),
          ),

          // Left side content - properly spaced
          Positioned(
            left: 16,
            top: 16,
            right:
                130, // Leave space for the image (100px + 16px margin + 14px buffer)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status chips
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    _buildStatusChip(theme),
                    _buildVerificationStatusChip(theme),
                  ],
                ),
                const SizedBox(height: 4),
                _buildVerificationStatusText(theme),
                const SizedBox(height: 8),

                // Brand and model - main title
                Text(
                  '${car.brand} ${car.model}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                    fontSize: 18, // Slightly smaller to prevent overflow
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Car type with icon
                Row(
                  children: [
                    const Icon(
                      Icons.directions_car,
                      color: AppTheme.lightBlue,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        car.type,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightBlue,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Pricing details - bottom left
          Positioned(
            bottom: 16,
            left: 16,
            right: 130, // Match the spacing with top content
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/svg/peso.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${car.hourlyRate.toStringAsFixed(0)}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ hour',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.paleBlue.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Available for rent',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.paleBlue.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          // Car specifications and stats in a row
          Row(
            children: [
              // Specs on the left
              Expanded(flex: 2, child: _buildSpecsPreview(theme)),
              const SizedBox(width: 16),
              // Quick stats on the right
              _buildQuickStats(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildStatItem(
          icon: Icons.event_seat,
          value: car.seatsCount.isNotEmpty ? car.seatsCount : '5',
          theme: theme,
        ),
        const SizedBox(height: 6),
        _buildStatItem(
          icon: Icons.luggage,
          value:
              car.luggageCapacity.isNotEmpty
                  ? car.luggageCapacity.split(' ')[0]
                  : '2',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.paleBlue, size: 16),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsPreview(ThemeData theme) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _buildSpecChip(
          icon: Icons.settings,
          label: _truncateText(
            car.transmissionType.isNotEmpty ? car.transmissionType : 'Auto',
            6,
          ),
          theme: theme,
        ),
        _buildSpecChip(
          icon: Icons.local_gas_station,
          label: _truncateText(
            car.fuelType.isNotEmpty ? car.fuelType : 'Petrol',
            6,
          ),
          theme: theme,
        ),
        _buildSpecChip(
          icon: Icons.calendar_today,
          label: car.year.isNotEmpty ? car.year : '2023',
          theme: theme,
        ),
      ],
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildSpecChip({
    required IconData icon,
    required String label,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.mediumBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.lightBlue, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: AppTheme.mediumBlue.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
              label: const Text('View Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.lightBlue,
                side: BorderSide(color: AppTheme.lightBlue.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCarDetailsScreen(car: car),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // Delete button
          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.redAccent.withOpacity(0.8),
              ),
              onPressed: () => _showDeleteDialog(context),
              tooltip: 'Delete Car',
              padding: const EdgeInsets.all(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    String statusText;
    Color statusColor;

    switch (car.availabilityStatus) {
      case AvailabilityStatus.available:
        statusText = 'Available';
        statusColor = Colors.green;
        break;
      case AvailabilityStatus.rented:
        statusText = 'Rented';
        statusColor = Colors.orange;
        break;
      case AvailabilityStatus.maintenance:
        statusText = 'Maintenance';
        statusColor = Colors.blueGrey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor.withOpacity(0.9),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusChip(ThemeData theme) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    switch (car.verificationStatus) {
      case VerificationStatus.approved:
        statusText = 'Approved';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case VerificationStatus.rejected:
        statusText = 'Rejected';
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
      case VerificationStatus.pending:
        statusText = 'Pending';
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 12,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor.withOpacity(0.9),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatusText(ThemeData theme) {
    String message;
    Color color;

    switch (car.verificationStatus) {
      case VerificationStatus.approved:
        message = 'Verified and ready for rental.';
        color = Colors.green;
        break;
      case VerificationStatus.rejected:
        message = 'Submission rejected. Check details.';
        color = Colors.red;
        break;
      case VerificationStatus.pending:
        message = 'Awaiting admin verification.';
        color = Colors.orange;
        break;
    }

    return Text(
      message,
      style: theme.textTheme.bodySmall?.copyWith(
        color: color.withOpacity(0.9),
        fontSize: 11,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 12),
              const Text('Delete Car', style: TextStyle(color: AppTheme.white)),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${car.type}"? This action cannot be undone.',
            style: TextStyle(color: AppTheme.paleBlue),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for background pattern
class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppTheme.lightBlue.withOpacity(0.05)
          ..style = PaintingStyle.fill;

    // Draw subtle pattern
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 5; j++) {
        final x = (i * 30.0) - 20;
        final y = (j * 30.0) - 10;
        if (x < size.width && y < size.height) {
          canvas.drawCircle(Offset(x, y), 2, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
