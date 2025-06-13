import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.car.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.car.brand} ${widget.car.model} ${widget.car.year}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                if (widget.car.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svg/location.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _isLoadingDistance
                          ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                          : Text(
                            _distanceText ?? 'Calculating distance...',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                    ],
                  ),
                  if (widget.car.locationAddress.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(
                          width: 22,
                        ), // For alignment with the location icon
                        Expanded(
                          child: Text(
                            widget.car.locationAddress,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            maxLines: 2,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  RatingBar.builder(
                    initialRating: widget.car.rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 16,
                    ignoreGestures: true,
                    itemBuilder:
                        (context, _) => SvgPicture.asset(
                          'assets/svg/star-filled.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            Colors.amber,
                            BlendMode.srcIn,
                          ),
                        ),
                    onRatingUpdate: (rating) {},
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.car.rating.toString(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.amber[800]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.car.type} • ${widget.car.transmissionType}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
              if (widget.car.location != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => CarLocationMapScreen(car: widget.car),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      'assets/svg/map-2.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
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
