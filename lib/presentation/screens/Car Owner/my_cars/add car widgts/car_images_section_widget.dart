import 'dart:io';
import 'package:car_rental_app/presentation/screens/Car%20Owner/my_cars/add%20car%20widgts/form_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../../config/theme.dart';

class CarImagesSectionWidget extends StatefulWidget {
  final List<File?> carImages;
  final Function(int) onImageSelected;

  const CarImagesSectionWidget({
    super.key,
    required this.carImages,
    required this.onImageSelected,
  });

  @override
  State<CarImagesSectionWidget> createState() => _CarImagesSectionWidgetState();
}

class _CarImagesSectionWidgetState extends State<CarImagesSectionWidget> {
  @override
  Widget build(BuildContext context) {
    return FormSectionWidget(
      title: 'Car Images',
      icon: SvgPicture.asset(
        'assets/svg/camera.svg',
        width: 24,
        height: 24,
        color: AppTheme.lightBlue,
      ),
      children: [
        const Text(
          'Upload 4 different angles of your car',
          style: TextStyle(color: AppTheme.mediumBlue),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => widget.onImageSelected(index),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.darkNavy,
                  border: Border.all(color: AppTheme.mediumBlue, width: 1),
                ),
                child:
                    widget.carImages[index] == null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/svg/camera-plus.svg',
                              width: 40,
                              height: 40,
                              color: Colors.white70,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Angle ${index + 1}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            widget.carImages[index]!,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
            );
          },
        ),
      ],
    );
  }
}
