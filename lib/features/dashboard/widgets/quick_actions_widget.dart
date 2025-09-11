import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profiles/screens/profile_form_screen.dart';
import '../../medical_records/screens/prescription_form_screen.dart';
import '../../medical_records/screens/medication_form_screen.dart';
import '../../medical_records/screens/lab_report_form_screen.dart';
import '../../medical_records/screens/medical_record_list_screen.dart';
import '../../profiles/screens/profile_list_screen.dart';

class QuickActionsWidget extends ConsumerWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // First row of actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.person_add,
                    label: 'Add Family Member',
                    color: Colors.blue,
                    onTap: () => _navigateToAddProfile(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.medication,
                    label: 'Add Prescription',
                    color: Colors.green,
                    onTap: () => _navigateToAddPrescription(context),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Second row of actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.medical_services,
                    label: 'Add Medication',
                    color: Colors.orange,
                    onTap: () => _navigateToAddMedication(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.science,
                    label: 'Add Lab Report',
                    color: Colors.purple,
                    onTap: () => _navigateToAddLabReport(context),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Third row of actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.search,
                    label: 'Search Records',
                    color: Colors.teal,
                    onTap: () => _navigateToSearch(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.family_restroom,
                    label: 'Manage Profiles',
                    color: Colors.indigo,
                    onTap: () => _navigateToManageProfiles(context),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Fourth row of actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.notification_add,
                    label: 'Set Reminder',
                    color: Colors.red,
                    onTap: () => _showReminderNotImplemented(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: Icons.file_download,
                    label: 'Export Data',
                    color: Colors.brown,
                    onTap: () => _showExportNotImplemented(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileFormScreen(),
      ),
    );
  }

  void _navigateToAddPrescription(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrescriptionFormScreen(),
      ),
    );
  }

  void _navigateToAddMedication(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MedicationFormScreen(),
      ),
    );
  }

  void _navigateToAddLabReport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LabReportFormScreen(),
      ),
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MedicalRecordListScreen(),
      ),
    );
  }

  void _navigateToManageProfiles(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileListScreen(),
      ),
    );
  }

  void _showReminderNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder system coming in Phase 3.9'),
      ),
    );
  }

  void _showExportNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export coming in Phase 3.12'),
      ),
    );
  }
}