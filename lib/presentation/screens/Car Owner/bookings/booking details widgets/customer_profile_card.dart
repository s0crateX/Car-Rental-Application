import 'package:flutter/material.dart';
import '../../../../../shared/models/customer_model.dart';

class CustomerProfileCard extends StatelessWidget {
  final Customer customer;

  const CustomerProfileCard({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Profile',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Icon Placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.account_circle,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                // Customer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Verification Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              customer.fullName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 75), // Ensure minimum width for status
                            margin: const EdgeInsets.only(left: 4), // Add some left margin
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: customer.isFullyVerified
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              customer.isFullyVerified ? 'Verified' : 'Pending',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: customer.isFullyVerified
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Contact Info
                      _buildInfoRow(Icons.phone, customer.phoneNumber, theme),
                      if (customer.email.isNotEmpty)
                        _buildInfoRow(Icons.email, customer.email, theme),
                      if (customer.age != null && customer.gender != null)
                        _buildInfoRow(
                          Icons.person_outline,
                          '${customer.gender}, ${customer.age} years',
                          theme,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Emergency Contact
            if (customer.emergencyContact != null)
              _buildSection(
                'Emergency Contact',
                Icons.emergency,
                customer.emergencyContact!,
                theme,
              ),
            // Address
            if (customer.address != null)
              _buildSection(
                'Address',
                Icons.location_on,
                customer.address!,
                theme,
              ),
            const SizedBox(height: 8),
            // Document Status
            _buildDocumentStatus(customer, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title, IconData icon, String content, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              content,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatusList() {
    final documentStatus = customer.documentStatus;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: DocumentType.values.map((docType) {
        final isVerified = documentStatus[docType] ?? false;
        final docName = Customer.getDocumentName(docType);
        final status = isVerified ? 'Verified' : 'Pending';
        final statusColor = isVerified ? Colors.green : Colors.orange;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(
                isVerified ? Icons.verified : Icons.pending,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  docName,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDocumentStatus(Customer customer, ThemeData theme) {
    final documentStatus = customer.documentStatus;
    if (documentStatus.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Verification',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildDocumentStatusList(),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: customer.verificationPercentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            customer.isFullyVerified ? Colors.green : theme.primaryColor,
          ),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 4),
        Text(
          '${(customer.verificationPercentage * 100).toInt()}% complete',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
