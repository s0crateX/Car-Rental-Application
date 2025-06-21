import 'package:car_rental_app/config/theme.dart';
import 'package:car_rental_app/shared/models/car_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OwnerCarCard extends StatefulWidget {
  final CarModel car;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const OwnerCarCard({
    super.key,
    required this.car,
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

  @override
  void initState() {
    super.initState();
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      height: 140,
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
          // Car image
          Positioned(
            right: 16,
            top: 16,
            bottom: 16,
            child: Hero(
              tag: 'car_image_${widget.car.name}_${widget.car.brand}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  widget.car.image,
                  width: 120,
                  height: 108,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 120,
                        height: 108,
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
                              color: AppTheme.lightBlue.withOpacity(0.7),
                              size: 32,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No Image',
                              style: TextStyle(
                                color: AppTheme.paleBlue.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
              ),
            ),
          ),
          // Car name and status overlay
          Positioned(
            left: 20,
            top: 16,
            right: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusChip(theme),
                const SizedBox(height: 12),
                Text(
                  widget.car.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                    fontSize: 20,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.branding_watermark,
                      color: AppTheme.lightBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${widget.car.brand} ${widget.car.model}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightBlue,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Pricing section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.darkNavy.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lightBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: AppTheme.lightBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Starting from',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.paleBlue.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${currencyFormat.format(widget.car.price)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        '${widget.car.pricePeriod}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.paleBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quick stats
                _buildQuickStats(theme),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Car specifications preview
          _buildSpecsPreview(theme),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildStatItem(
          icon: Icons.event_seat,
          value: '${widget.car.seatsCount.isNotEmpty ? widget.car.seatsCount : '5'}',
          label: 'Seats',
          theme: theme,
        ),
        const SizedBox(height: 8),
        _buildStatItem(
          icon: Icons.luggage,
          value: '${widget.car.luggageCapacity.isNotEmpty ? widget.car.luggageCapacity.split(' ')[0] : '2'}',
          label: 'Bags',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 80), // Limit the width of each stat item
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.paleBlue, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.paleBlue.withOpacity(0.8),
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsPreview(ThemeData theme) {
    return Row(
      children: [
        Flexible(
          child: _buildSpecChip(
            icon: Icons.settings,
            label: _truncateText(widget.car.transmissionType.isNotEmpty ? widget.car.transmissionType : 'Auto', 8),
            theme: theme,
          ),
        ),
        const SizedBox(width: 8), // Reduced spacing between chips
        Flexible(
          child: _buildSpecChip(
            icon: Icons.local_gas_station,
            label: _truncateText(widget.car.fuelType.isNotEmpty ? widget.car.fuelType : 'Petrol', 8),
            theme: theme,
          ),
        ),
        const SizedBox(width: 8), // Reduced spacing between chips
        Flexible(
          child: _buildSpecChip(
            icon: Icons.calendar_today,
            label: widget.car.year.isNotEmpty ? widget.car.year : '2023',
            theme: theme,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Reduced padding
      decoration: BoxDecoration(
        color: AppTheme.mediumBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.mediumBlue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.lightBlue, size: 14), // Slightly smaller icon
          const SizedBox(width: 4), // Reduced spacing
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w500,
                fontSize: 11, // Slightly smaller font
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkNavy.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: AppTheme.mediumBlue.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          // View details button
          Expanded(
            child: TextButton.icon(
              onPressed: widget.onTap,
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('View Details'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.lightBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.lightBlue.withOpacity(0.3)),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Edit button
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.lightBlue.withOpacity(0.3)),
            ),
            child: IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppTheme.lightBlue),
              onPressed: widget.onEdit,
              tooltip: 'Edit Car',
              padding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(width: 8),

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
              padding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    // Mock status - in real app, this would come from the CarModel
    bool isAvailable = true;
    String statusText = isAvailable ? 'Available' : 'Rented';
    Color statusColor = isAvailable ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            width: 8,
            height: 8,
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
              fontSize: 12,
            ),
          ),
        ],
      ),
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
            'Are you sure you want to delete "${widget.car.name}"? This action cannot be undone.',
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
