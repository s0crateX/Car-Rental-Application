import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../config/theme.dart';
import '../../../../../../shared/models/car_model.dart';
import '../../../../../../shared/utils/location_utils.dart';
import 'car_location_map_screen.dart';

class CarHeaderInfo extends StatefulWidget {
  final CarModel car;

  const CarHeaderInfo({super.key, required this.car});

  @override
  State<CarHeaderInfo> createState() => _CarHeaderInfoState();
}

class _CarHeaderInfoState extends State<CarHeaderInfo> {
  String? _distanceText;
  bool _isLoadingDistance = false;

  @override
  void initState() {
    super.initState();
    _loadDistance();
  }

  Future<void> _loadDistance() async {
    if (widget.car.location == null) return;

    setState(() {
      _isLoadingDistance = true;
    });

    try {
      final distance = await LocationUtils().getDistanceToCarInKm(
        widget.car.location,
      );
      if (mounted) {
        setState(() {
          _distanceText = LocationUtils().formatDistance(distance);
          _isLoadingDistance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDistance = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), // Reduced top padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Important: minimize column height
              children: [
                Text(
                  widget.car.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 28, // Slightly smaller font
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // Reduced spacing
                Text(
                  '${widget.car.brand} ${widget.car.model} ${widget.car.year}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12, // Slightly smaller
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.car.location != null) ...[
                  const SizedBox(height: 10), // Reduced spacing
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/location.svg',
                        width: 14, // Slightly smaller icon
                        height: 14,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      _isLoadingDistance
                          ? SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                          : Flexible(
                            child: Text(
                              _distanceText ?? 'Calculating...',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                    ],
                  ),
                  if (widget.car.locationAddress.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const SizedBox(width: 18), // Adjusted for smaller icon
                        Expanded(
                          child: Text(
                            widget.car.locationAddress,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                            maxLines: 1, // Reduced to 1 line to save space
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(
            width: 8,
          ), // Add some spacing between left and right content
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RatingBar.builder(
                    initialRating: widget.car.rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 14, // Smaller stars
                    ignoreGestures: true,
                    itemBuilder:
                        (context, _) => SvgPicture.asset(
                          'assets/svg/star-filled.svg',
                          width: 14,
                          height: 14,
                          colorFilter: const ColorFilter.mode(
                            Colors.amber,
                            BlendMode.srcIn,
                          ),
                        ),
                    onRatingUpdate: (rating) {},
                  ),
                  const SizedBox(width: 3),
                  Text(
                    widget.car.rating.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.amber[800],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.car.type} • ${widget.car.transmissionType}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              if (widget.car.location != null) ...[
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => CarLocationMapScreen(car: widget.car),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(
                      5,
                    ), // Slightly smaller padding
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SvgPicture.asset(
                      'assets/svg/map-2.svg',
                      width: 35, // Smaller icon
                      height: 35,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
