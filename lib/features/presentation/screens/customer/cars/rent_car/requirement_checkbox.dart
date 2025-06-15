import 'package:car_rental_app/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RequirementStatusIndicator extends StatefulWidget {
  final String label;
  final bool isUploaded;
  final bool isLoading;
  final VoidCallback? onTap;
  final String? uploadedDate;
  final String? description;

  const RequirementStatusIndicator({
    required this.label,
    required this.isUploaded,
    this.isLoading = false,
    this.onTap,
    this.uploadedDate,
    this.description,
    Key? key,
  }) : super(key: key);

  @override
  State<RequirementStatusIndicator> createState() =>
      _RequirementStatusIndicatorState();
}

class _RequirementStatusIndicatorState extends State<RequirementStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.grey.withOpacity(0.05),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _statusColor {
    if (widget.isLoading) return Colors.blue;
    return widget.isUploaded ? Colors.green : Colors.orange;
  }

  String get _statusSvg {
    if (widget.isLoading) return 'assets/svg/progress-check.svg';
    return widget.isUploaded ? 'assets/svg/check.svg' : 'assets/svg/upload.svg';
  }

  String get _statusText {
    if (widget.isLoading) return 'Processing...';
    if (widget.isUploaded) {
      return widget.uploadedDate != null
          ? 'Uploaded ${widget.uploadedDate}'
          : 'Verified';
    }
    return 'Upload required';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Semantics(
      label: '${widget.label}, ${widget.isUploaded ? 'completed' : 'pending'}',
      button: !widget.isUploaded && widget.onTap != null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: GestureDetector(
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                onTap:
                    !widget.isUploaded && widget.onTap != null
                        ? widget.onTap
                        : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _colorAnimation.value,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          widget.isUploaded
                              ? Colors.green.withOpacity(0.3)
                              : widget.isLoading
                              ? Colors.blue.withOpacity(0.3)
                              : Colors.orange.withOpacity(0.3),
                      width: widget.isUploaded ? 2 : 1,
                    ),
                    boxShadow:
                        _isHovered && !widget.isUploaded && widget.onTap != null
                            ? [
                              BoxShadow(
                                color: _statusColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Row(
                    children: [
                      // Status Icon with animation
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            widget.isLoading
                                ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _statusColor,
                                    ),
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    widget.isUploaded
                                        ? (isDarkMode
                                            ? Colors.green.shade300
                                            : Colors.green.shade700)
                                        : theme.textTheme.titleMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _statusText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.description!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Action Button or Status Badge
                      if (!widget.isUploaded &&
                          widget.onTap != null &&
                          !widget.isLoading)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton.icon(
                            onPressed: widget.onTap,
                            icon: SvgPicture.asset('assets/svg/upload.svg'),
                            label: const Text('Upload'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _statusColor,
                              foregroundColor: AppTheme.darkNavy,
                              elevation: _isHovered ? 4 : 2,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )
                      else if (widget.isUploaded)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: SvgPicture.asset(
                                  _statusSvg,
                                  colorFilter: ColorFilter.mode(
                                    widget.isUploaded
                                        ? Colors.green.shade600
                                        : widget.isLoading
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.secondary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Complete',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Example usage widget
class RequirementsList extends StatefulWidget {
  @override
  State<RequirementsList> createState() => _RequirementsListState();
}

class _RequirementsListState extends State<RequirementsList> {
  final List<Map<String, dynamic>> requirements = [
    {
      'label': 'Identity Document',
      'isUploaded': true,
      'uploadedDate': '2 days ago',
      'description': 'Government-issued photo ID',
    },
    {
      'label': 'Proof of Address',
      'isUploaded': false,
      'isLoading': false,
      'description': 'Utility bill or bank statement',
    },
    {
      'label': 'Income Verification',
      'isUploaded': false,
      'isLoading': true,
      'description': 'Recent pay stubs or tax returns',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Requirements')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Required Documents',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Please upload the following documents to complete your application',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: requirements.length,
                itemBuilder: (context, index) {
                  final req = requirements[index];
                  return RequirementStatusIndicator(
                    label: req['label'],
                    isUploaded: req['isUploaded'] ?? false,
                    isLoading: req['isLoading'] ?? false,
                    uploadedDate: req['uploadedDate'],
                    description: req['description'],
                    onTap:
                        req['isUploaded'] == false
                            ? () {
                              // Simulate upload process
                              setState(() {
                                requirements[index]['isLoading'] = true;
                              });
                              Future.delayed(const Duration(seconds: 2), () {
                                setState(() {
                                  requirements[index]['isLoading'] = false;
                                  requirements[index]['isUploaded'] = true;
                                  requirements[index]['uploadedDate'] =
                                      'just now';
                                });
                              });
                            }
                            : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
