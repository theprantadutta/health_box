import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_state_widgets.dart';

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
        ? RecordTypeUtils.getGradient(recordAsync.value!.recordType)
        : AppColors.primaryGradient;

    return Scaffold(
      body: recordAsync.when(
        loading: () => const HBLoading.large(
          message: 'Loading record details...',
        ),
        error: (error, stack) => HBErrorState(
          error: error,
          onRetry: () => context.pop(),
        ),
        data: (record) => record == null
            ? HBErrorState.notFound(resourceName: 'Medical Record')
            : _buildRecordDetail(context, ref, record, recordGradient),
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

    return CustomScrollView(
      slivers: [
        // Hero App Bar with Gradient
        _buildHeroAppBar(context, record, gradient),

        // Content
        SliverPadding(
          padding: EdgeInsets.all(context.responsivePadding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Title and Description Card
              CommonTransitions.fadeSlideIn(
                child: _buildHeaderCard(context, record, gradient),
              ),
              SizedBox(height: AppSpacing.base),

              // Profile Information
              CommonTransitions.fadeSlideIn(
                child: _buildProfileCard(context, profileAsync, gradient),
              ),
              SizedBox(height: AppSpacing.base),

              // Record Details
              CommonTransitions.fadeSlideIn(
                child: _buildDetailsCard(context, record, gradient),
              ),
              SizedBox(height: AppSpacing.base),

              // Metadata Card
              CommonTransitions.fadeSlideIn(
                child: _buildMetadataCard(context, record, gradient),
              ),

              SizedBox(height: AppSpacing.xl2),
            ]),
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
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl2 * 2,
                AppSpacing.lg,
                AppSpacing.base,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: AppRadii.radiusMd,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          RecordTypeUtils.getIcon(record.recordType),
                          size: AppSizes.iconSm,
                          color: Colors.white,
                        ),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          _getDisplayName(record.recordType),
                          style: context.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: AppTypography.fontWeightBold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'Medical Record Details',
                    style: context.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.fontWeightBold,
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
          margin: EdgeInsets.only(right: AppSpacing.xs),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: AppRadii.radiusMd,
          ),
          child: IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            onPressed: () => _navigateToEdit(context, record),
            tooltip: 'Edit Record',
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: AppRadii.radiusMd,
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (value) => _handleMenuAction(context, value, record),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.radiusLg,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer
                            .withValues(alpha: 0.3),
                        borderRadius: AppRadii.radiusSm,
                      ),
                      child: Icon(
                        Icons.share_rounded,
                        size: AppSizes.iconSm,
                        color: context.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    const Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: context.colorScheme.errorContainer
                            .withValues(alpha: 0.3),
                        borderRadius: AppRadii.radiusSm,
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        size: AppSizes.iconSm,
                        color: context.colorScheme.error,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      'Delete',
                      style: TextStyle(color: context.colorScheme.error),
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
  ) {
    return HBCard.elevated(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient Header Strip
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadii.md),
                topRight: Radius.circular(AppRadii.md),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    HBRecordIcon(
                      recordType: record.recordType,
                      size: AppSizes.xl2,
                      useGradient: true,
                    ),
                    SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.title,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: AppTypography.fontWeightBold,
                              color: context.colorScheme.onSurface,
                              height: 1.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              if (!record.isActive)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  margin: EdgeInsets.only(right: AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.error
                                        .withValues(alpha: 0.1),
                                    borderRadius: AppRadii.radiusSm,
                                    border: Border.all(
                                      color: context.colorScheme.error
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    'INACTIVE',
                                    style: context.textTheme.labelSmall
                                        ?.copyWith(
                                      color: context.colorScheme.error,
                                      fontWeight: AppTypography.fontWeightBold,
                                      fontSize: AppTypography.fontSizeXs,
                                    ),
                                  ),
                                ),
                              Icon(
                                Icons.calendar_today_rounded,
                                size: AppSizes.iconXs,
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                _formatDate(record.recordDate),
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                  fontWeight: AppTypography.fontWeightSemiBold,
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
                  SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: EdgeInsets.all(AppSpacing.base),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? context.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4)
                          : context.colorScheme.surfaceContainerHigh
                              .withValues(alpha: 0.6),
                      borderRadius: AppRadii.radiusMd,
                      border: Border.all(
                        color: context.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description_rounded,
                              size: AppSizes.iconSm,
                              color: context.colorScheme.primary,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text(
                              'Description',
                              style: context.textTheme.titleSmall?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: AppTypography.fontWeightBold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          record.description!,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colorScheme.onSurface,
                            height: AppTypography.lineHeightRelaxed,
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
  ) {
    return profileAsync.when(
      loading: () => HBCard.elevated(
        child: const HBLoading.small(),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();

        final age = _calculateAge(profile.dateOfBirth);
        final initials =
            '${profile.firstName[0]}${profile.lastName[0]}'.toUpperCase();

        return HBCard.elevated(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: AppSizes.xl2,
                height: AppSizes.xl2,
                decoration: BoxDecoration(
                  gradient: _getGenderGradient(profile.gender),
                  shape: BoxShape.circle,
                  boxShadow: AppElevation.coloredShadow(
                    _getGenderGradient(profile.gender).colors.first,
                    opacity: 0.3,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: AppTypography.fontWeightBold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Information',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: AppTypography.fontWeightBold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      '${profile.firstName} ${profile.lastName}',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: AppTypography.fontWeightBold,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: AppRadii.radiusSm,
                          ),
                          child: Text(
                            '$age years',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: AppTypography.fontWeightSemiBold,
                              fontSize: AppTypography.fontSizeXs,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.secondaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: AppRadii.radiusSm,
                          ),
                          child: Text(
                            profile.gender,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.secondary,
                              fontWeight: AppTypography.fontWeightSemiBold,
                              fontSize: AppTypography.fontSizeXs,
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

  Widget _buildDetailsCard(
    BuildContext context,
    MedicalRecord record,
    LinearGradient gradient,
  ) {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: AppRadii.radiusMd,
                ),
                child: Icon(
                  Icons.info_rounded,
                  size: AppSizes.iconMd,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                'Record Information',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.fontWeightBold,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          HBDetailRow(
            label: 'Record Type',
            value: _getDisplayName(record.recordType),
            icon: Icons.category_rounded,
          ),
          HBDetailRow(
            label: 'Record Date',
            value: _formatDateTime(record.recordDate),
            icon: Icons.calendar_today_rounded,
          ),
          HBDetailRow(
            label: 'Status',
            value: record.isActive ? 'Active' : 'Inactive',
            icon: record.isActive
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            valueColor: record.isActive
                ? AppColors.success
                : context.colorScheme.error,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(
    BuildContext context,
    MedicalRecord record,
    LinearGradient gradient,
  ) {
    return HBCard.elevated(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: AppRadii.radiusMd,
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  size: AppSizes.iconMd,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                'Record Metadata',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.fontWeightBold,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          HBDetailRow(
            label: 'Created At',
            value: _formatDateTime(record.createdAt),
            icon: Icons.add_circle_outline_rounded,
          ),
          HBDetailRow(
            label: 'Last Updated',
            value: _formatDateTime(record.updatedAt),
            icon: Icons.edit_calendar_rounded,
          ),
          HBDetailRow(
            label: 'Record ID',
            value: record.id,
            icon: Icons.fingerprint_rounded,
          ),
        ],
      ),
    );
  }

  String _getDisplayName(String recordType) {
    return recordType
        .toUpperCase()
        .replaceAll('_', ' ')
        .replaceAll('RECORD', '')
        .trim();
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusMd,
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
          SnackBar(
            content: const Text(
              'Share functionality will be implemented soon',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.radiusMd,
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
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusLg,
        ),
        title: const Text('Delete Record'),
        content: Text(
          'Are you sure you want to delete "${record.title}"? This action cannot be undone.',
        ),
        actions: [
          HBButton.text(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          HBButton.destructive(
            onPressed: () {
              context.pop();
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Delete functionality will be implemented with service integration',
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadii.radiusMd,
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
