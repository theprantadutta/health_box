import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_loading.dart';

class MedicalRecordDetailScreen extends ConsumerWidget {
  final String recordId;
  final MedicalRecord? record;

  const MedicalRecordDetailScreen({
    super.key,
    required this.recordId,
    this.record,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use provided record or fetch by ID
    final recordAsync = record != null
        ? AsyncValue.data(record!)
        : ref.watch(medicalRecordByIdProvider(recordId));

    final recordGradient = recordAsync.value != null
        ? HealthBoxDesignSystem.getRecordTypeGradient(
            recordAsync.value!.recordType)
        : HealthBoxDesignSystem.medicalBlue;

    return Scaffold(
      body: recordAsync.when(
        loading: () => const HBLoading.circular(),
        error: (error, stack) => _buildErrorState(context, error),
        data: (record) => record == null
            ? _buildRecordNotFound(context)
            : _buildRecordDetail(context, ref, record, recordGradient),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppSizes.iconXl * 1.5,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.base),
            Text(
              'Error loading record',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpacing.base),
            HBButton.primary(
              text: 'Go Back',
              icon: Icons.arrow_back,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordNotFound(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsivePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: AppSizes.iconXl * 1.5,
              color: context.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: AppSpacing.base),
            Text(
              'Record not found',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: AppTypography.fontWeightBold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'The medical record you\'re looking for doesn\'t exist or has been deleted',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordDetail(
    BuildContext context,
    WidgetRef ref,
    MedicalRecord record,
    LinearGradient gradient,
  ) {
    final profileAsync = ref.watch(profileByIdProvider(record.profileId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // Hero App Bar with Gradient
        _buildHeroAppBar(context, record, gradient),

        // Content
        SliverToBoxAdapter(
          child: Column(
            children: [
              // Title and Description Card
              CommonTransitions.fadeSlideIn(
                child: _buildHeaderCard(context, record, gradient, isDark),
              ),

              // Profile Information
              CommonTransitions.fadeSlideIn(
                child: _buildProfileCard(context, profileAsync, gradient, isDark),
              ),

              // Record Details Grid
              CommonTransitions.fadeSlideIn(
                child: _buildDetailsGrid(context, record, gradient, isDark),
              ),

              // Metadata Card
              CommonTransitions.fadeSlideIn(
                child: _buildMetadataCard(context, record, gradient, isDark),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroAppBar(
    BuildContext context,
    MedicalRecord record,
    LinearGradient gradient,
  ) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: gradient.colors.first,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(60, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getRecordTypeIcon(record.recordType),
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getDisplayName(record.recordType),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Medical Record Details',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            onPressed: () => _navigateToEdit(context, record),
            tooltip: 'Edit Record',
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value, record),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Delete',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    MedicalRecord record,
    LinearGradient gradient,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.1),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient Header
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: HealthBoxDesignSystem.coloredShadow(
                          gradient.colors.first,
                          opacity: 0.35,
                        ),
                      ),
                      child: Icon(
                        _getRecordTypeIcon(record.recordType),
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              height: 1.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (!record.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'INACTIVE',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(record.recordDate),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (record.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
                          : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_rounded,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Description',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          record.description!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    AsyncValue<FamilyMemberProfile?> profileAsync,
    LinearGradient gradient,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return profileAsync.when(
      loading: () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        final age = _calculateAge(profile.dateOfBirth);
        final initials = '${profile.firstName[0]}${profile.lastName[0]}'.toUpperCase();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: gradient.colors.first.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.08),
                offset: const Offset(0, 4),
                blurRadius: 16,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: _getGenderGradient(profile.gender),
                  shape: BoxShape.circle,
                  boxShadow: HealthBoxDesignSystem.coloredShadow(
                    _getGenderGradient(profile.gender).colors.first,
                    opacity: 0.3,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Information',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.firstName} ${profile.lastName}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$age years',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            profile.gender,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
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
      },
    );
  }

  Widget _buildDetailsGrid(
    BuildContext context,
    MedicalRecord record,
    LinearGradient gradient,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Record Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailItem(
            context,
            'Record Type',
            _getDisplayName(record.recordType),
            Icons.category_rounded,
            gradient.colors.first,
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            context,
            'Record Date',
            _formatDateTime(record.recordDate),
            Icons.calendar_today_rounded,
            gradient.colors.first,
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            context,
            'Status',
            record.isActive ? 'Active' : 'Inactive',
            record.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
            record.isActive ? HealthBoxDesignSystem.successColor : theme.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(
    BuildContext context,
    MedicalRecord record,
    LinearGradient gradient,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: gradient.colors.first.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Record Metadata',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailItem(
            context,
            'Created At',
            _formatDateTime(record.createdAt),
            Icons.add_circle_outline_rounded,
            gradient.colors.first,
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            context,
            'Last Updated',
            _formatDateTime(record.updatedAt),
            Icons.edit_calendar_rounded,
            gradient.colors.first,
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            context,
            'Record ID',
            record.id,
            Icons.fingerprint_rounded,
            gradient.colors.first,
            monospace: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool monospace = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontFamily: monospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getRecordTypeIcon(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return Icons.medication_rounded;
      case 'medication':
        return Icons.medical_services_rounded;
      case 'lab_report':
      case 'lab report':
        return Icons.science_rounded;
      case 'vaccination':
        return Icons.vaccines_rounded;
      case 'allergy':
        return Icons.warning_rounded;
      case 'chronic_condition':
      case 'chronic condition':
        return Icons.health_and_safety_rounded;
      case 'surgical_record':
      case 'surgical record':
        return Icons.medical_services_outlined;
      case 'radiology_record':
      case 'radiology record':
        return Icons.medical_information_rounded;
      case 'pathology_record':
      case 'pathology record':
        return Icons.biotech_rounded;
      case 'discharge_summary':
      case 'discharge summary':
        return Icons.exit_to_app_rounded;
      case 'hospital_admission':
      case 'hospital admission':
        return Icons.local_hospital_rounded;
      case 'dental_record':
      case 'dental record':
        return Icons.healing_rounded;
      case 'mental_health_record':
      case 'mental health record':
        return Icons.psychology_rounded;
      case 'general_record':
      case 'general record':
        return Icons.description_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  String _getDisplayName(String recordType) {
    switch (recordType.toLowerCase()) {
      case 'prescription':
        return 'PRESCRIPTION';
      case 'medication':
        return 'MEDICATION';
      case 'lab_report':
        return 'LAB REPORT';
      case 'vaccination':
        return 'VACCINATION';
      case 'allergy':
        return 'ALLERGY';
      case 'chronic_condition':
        return 'CHRONIC CONDITION';
      case 'surgical_record':
        return 'SURGICAL';
      case 'radiology_record':
        return 'RADIOLOGY';
      case 'pathology_record':
        return 'PATHOLOGY';
      case 'discharge_summary':
        return 'DISCHARGE';
      case 'hospital_admission':
        return 'ADMISSION';
      case 'dental_record':
        return 'DENTAL';
      case 'mental_health_record':
        return 'MENTAL HEALTH';
      case 'general_record':
        return 'GENERAL';
      default:
        return recordType.toUpperCase().replaceAll('_', ' ');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  int _calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  LinearGradient _getGenderGradient(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        );
      case 'female':
        return const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
    }
  }

  void _navigateToEdit(BuildContext context, MedicalRecord? record) {
    if (record == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit ${record.recordType} - Will be implemented in future update',
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    MedicalRecord? record,
  ) {
    if (record == null) return;

    switch (action) {
      case 'share':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Share functionality will be implemented soon',
            ),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, record);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete "${record.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Delete functionality will be implemented with service integration',
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
