import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../../../config/theme.dart';
import '../../../../../core/authentication/auth_service.dart';

class ContractStatusIndicator extends StatelessWidget {
  const ContractStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final uid = authService.user?.uid;

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final contractUrl = data?['rentalContract'] as String?;
        final hasContract = contractUrl != null && contractUrl.isNotEmpty;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: hasContract 
                ? AppTheme.lightBlue.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasContract 
                  ? AppTheme.lightBlue.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                hasContract ? 'assets/svg/check.svg' : 'assets/svg/alert-triangle.svg',
                width: 12,
                height: 12,
                colorFilter: ColorFilter.mode(
                  hasContract ? AppTheme.lightBlue : Colors.orange,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                hasContract ? 'Contract Ready' : 'No Contract',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: hasContract ? AppTheme.lightBlue : Colors.orange,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}