import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/database/app_database.dart';
import '../../../shared/animations/common_transitions.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/providers/medical_records_providers.dart';
import '../../../shared/providers/simple_profile_providers.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/widgets/hb_state_widgets.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../test_alarm_notification.dart';
import '../widgets/recent_activity_widget.dart';
import '../widgets/upcoming_reminders_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(simpleProfilesProvider);
    final selectedProfileAsync = ref.watch(simpleSelectedProfileProvider);

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainerLowest,
      body: HBRefreshIndicator(
        onRefresh: () async {
          ref.invalidate(simpleProfilesProvider);
          ref.invalidate(simpleSelectedProfileProvider);
        },
        child: CustomScrollView(
          slivers: [
            // App Bar with gradient
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  boxShadow: AppElevation.coloredShadow(
                    AppColors.primary,
                    opacity: 0.3,
                  ),
                ),
              ),
              title: Text(
                'HealthBox',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppTypography.fontWeightBold,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  onPressed: () => _showSearchDialog(context),
                  tooltip: 'Search',
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  onPressed: () => context.push(AppRoutes.reminders),
                  tooltip: 'Notifications',
                ),
                SizedBox(width: context.responsivePadding / 2),
              ],
            ),

            // Main content
            SliverPadding(
              padding: EdgeInsets.all(context.responsivePadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Hero section - welcome
                  _buildHeroSection(selectedProfileAsync, profilesAsync),
                  SizedBox(height: AppSpacing.lg),

                  // Statistics overview
                  _buildStatsSection(),
                  SizedBox(height: AppSpacing.lg),

                  // Quick actions
                  _buildQuickActionsSection(),
                  SizedBox(height: AppSpacing.lg),

                  // Activity section
                  _buildActivitySection(),

                  SizedBox(height: AppSpacing.xl2 * 3), // FAB space
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeroSection(
    AsyncValue<FamilyMemberProfile?> selectedProfileAsync,
    AsyncValue<List<FamilyMemberProfile>> profilesAsync,
  ) {
    return selectedProfileAsync.when(
      loading: () => CommonTransitions.fadeIn(
        child: HBCard.gradient(
          gradient: AppColors.primaryGradient,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: AppTypography.fontSizeLg,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => CommonTransitions.fadeSlideIn(
        child: HBCard.gradient(
          gradient: AppColors.primaryGradient,
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'HealthBox',
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: AppTypography.fontWeightBold,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Your family\'s health management hub',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (selectedProfile) => CommonTransitions.fadeSlideIn(
        child: HBCard.elevated(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gradient Header Strip
              Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadii.md),
                    topRight: Radius.circular(AppRadii.md),
                  ),
                ),
              ),
              // Card Content
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    // Avatar
                    if (selectedProfile != null)
                      Container(
                        width: AppSizes.xl2,
                        height: AppSizes.xl2,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppRadii.radiusMd,
                          boxShadow: AppElevation.coloredShadow(
                            AppColors.primary,
                            opacity: 0.35,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${selectedProfile.firstName[0]}${selectedProfile.lastName[0]}'
                                .toUpperCase(),
                            style: context.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: AppTypography.fontWeightBold,
                              fontSize: AppTypography.fontSize2Xl,
                            ),
                          ),
                        ),
                      ),
                    if (selectedProfile != null) SizedBox(width: AppSpacing.md),
                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedProfile != null
                                ? 'Welcome back,'
                                : 'Welcome to',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              fontWeight: AppTypography.fontWeightMedium,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            selectedProfile != null
                                ? selectedProfile.firstName
                                : 'HealthBox',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: AppTypography.fontWeightBold,
                              color: context.colorScheme.onSurface,
                              height: 1.1,
                            ),
                          ),
                          if (selectedProfile != null) ...[
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              '${selectedProfile.firstName} ${selectedProfile.lastName}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                                fontWeight: AppTypography.fontWeightMedium,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Switch Profile Button
                    if (selectedProfile != null)
                      Container(
                        decoration: BoxDecoration(
                          color: context.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.6),
                          borderRadius: AppRadii.radiusMd,
                        ),
                        child: IconButton(
                          onPressed: () =>
                              _showProfileSelector(context, profilesAsync),
                          padding: EdgeInsets.all(AppSpacing.sm),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            Icons.swap_horiz_rounded,
                            color: context.colorScheme.onSurfaceVariant,
                            size: AppSizes.iconMd,
                          ),
                          tooltip: 'Switch Profile',
                        ),
                      ),
                  ],
                ),
              ),
              // No Profile Selected Section
              if (selectedProfile == null) ...[
                SizedBox(height: AppSpacing.base),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: profilesAsync.when(
                    loading: () => const Center(
                      child: HBLoading.small(),
                    ),
                    error: (error, _) => Container(
                      padding: EdgeInsets.all(AppSpacing.base),
                      decoration: BoxDecoration(
                        color: context.colorScheme.errorContainer,
                        borderRadius: AppRadii.radiusMd,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: context.colorScheme.error,
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Error loading profiles',
                              style: TextStyle(
                                color: context.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    data: (profiles) => profiles.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Get started by adding your first family member',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                              SizedBox(height: AppSpacing.base),
                              HBButton.primary(
                                onPressed: () => context.push(AppRoutes.profiles),
                                icon: Icons.person_add_rounded,
                                child: const Text('Add Family Member'),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select a family member:',
                                style: context.textTheme.bodyLarge?.copyWith(
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                              SizedBox(height: AppSpacing.base),
                              Wrap(
                                spacing: AppSpacing.md,
                                runSpacing: AppSpacing.md,
                                children: profiles.map((profile) {
                                  return InkWell(
                                    onTap: () {
                                      ref
                                          .read(setSelectedProfileProvider)
                                          .call(profile.id);
                                    },
                                    borderRadius: AppRadii.radiusMd,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.base,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: context.colorScheme.surface,
                                        borderRadius: AppRadii.radiusMd,
                                        border: Border.all(
                                          color: context.colorScheme.outline
                                              .withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: AppSizes.lg,
                                            backgroundColor: context
                                                .colorScheme.primary
                                                .withValues(alpha: 0.1),
                                            child: Text(
                                              profile.firstName[0],
                                              style: TextStyle(
                                                color:
                                                    context.colorScheme.primary,
                                                fontWeight: AppTypography
                                                    .fontWeightSemiBold,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: AppSpacing.md),
                                          Text(
                                            '${profile.firstName} ${profile.lastName}',
                                            style: context.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: AppTypography
                                                  .fontWeightMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: AppSpacing.base),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final profilesAsync = ref.watch(simpleProfilesProvider);
    final medicalRecordsAsync = ref.watch(allMedicalRecordsProvider);

    final stats = [
      _StatItem(
        label: 'Family Members',
        value: profilesAsync.when(
          loading: () => '-',
          error: (_, __) => '0',
          data: (profiles) => profiles.length.toString(),
        ),
        icon: Icons.people_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
      ),
      _StatItem(
        label: 'Medical Records',
        value: medicalRecordsAsync.when(
          loading: () => '-',
          error: (_, __) => '0',
          data: (records) => records.length.toString(),
        ),
        icon: Icons.description_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF059669), Color(0xFF047857)],
        ),
      ),
      _StatItem(
        label: 'Active Reminders',
        value: '0',
        icon: Icons.notifications_active_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
      ),
      _StatItem(
        label: 'This Month',
        value: '0',
        icon: Icons.calendar_today_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        SizedBox(height: AppSpacing.base),
        Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard(stats[0])),
                SizedBox(width: AppSpacing.base),
                Expanded(child: _buildStatCard(stats[1])),
              ],
            ),
            SizedBox(height: AppSpacing.base),
            Row(
              children: [
                Expanded(child: _buildStatCard(stats[2])),
                SizedBox(width: AppSpacing.base),
                Expanded(child: _buildStatCard(stats[3])),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(_StatItem stat) {
    return HBCard.elevated(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient Header Strip
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: stat.gradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadii.md),
                topRight: Radius.circular(AppRadii.md),
              ),
            ),
          ),
          // Card Content
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: stat.gradient,
                    borderRadius: AppRadii.radiusMd,
                    boxShadow: AppElevation.coloredShadow(
                      stat.gradient.colors.first,
                      opacity: 0.3,
                    ),
                  ),
                  child: Icon(
                    stat.icon,
                    color: Colors.white,
                    size: AppSizes.iconMd,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stat.value,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: AppTypography.fontWeightBold,
                          color: context.colorScheme.onSurface,
                          fontSize: AppTypography.fontSize2Xl,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        stat.label,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontWeight: AppTypography.fontWeightSemiBold,
                          fontSize: AppTypography.fontSizeXs,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final actions = [
      _QuickAction(
        title: 'Add Record',
        icon: Icons.medical_information_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
        ),
        onTap: () => context.push(AppRoutes.medicalRecords),
      ),
      _QuickAction(
        title: 'Set Reminder',
        icon: Icons.alarm_add_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
        ),
        onTap: () => context.push(AppRoutes.reminders),
      ),
      _QuickAction(
        title: 'Scan Document',
        icon: Icons.document_scanner_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
        ),
        onTap: () => context.push(AppRoutes.ocrScan),
      ),
      _QuickAction(
        title: 'Track Vitals',
        icon: Icons.favorite_rounded,
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
        ),
        onTap: () => context.push(AppRoutes.vitalsTracking),
      ),
    ];

    if (kDebugMode) {
      actions.add(
        _QuickAction(
          title: 'Test Alarms 🧪',
          icon: Icons.bug_report_rounded,
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TestAlarmNotificationScreen(),
              ),
            );
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        SizedBox(height: AppSpacing.base),
        CommonTransitions.fadeSlideIn(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildActionCard(actions[0])),
                  SizedBox(width: AppSpacing.base),
                  Expanded(child: _buildActionCard(actions[1])),
                ],
              ),
              SizedBox(height: AppSpacing.base),
              Row(
                children: [
                  Expanded(child: _buildActionCard(actions[2])),
                  SizedBox(width: AppSpacing.base),
                  Expanded(child: _buildActionCard(actions[3])),
                ],
              ),
              if (kDebugMode) ...[
                SizedBox(height: AppSpacing.base),
                _buildActionCard(actions[4]),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(_QuickAction action) {
    return HBCard.elevated(
      onTap: action.onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient Header Strip
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: action.gradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadii.md),
                topRight: Radius.circular(AppRadii.md),
              ),
            ),
          ),
          // Card Content
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: action.gradient,
                    borderRadius: AppRadii.radiusMd,
                    boxShadow: AppElevation.coloredShadow(
                      action.gradient.colors.first,
                      opacity: 0.3,
                    ),
                  ),
                  child: Icon(
                    action.icon,
                    color: Colors.white,
                    size: AppSizes.iconMd,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  action.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: AppTypography.fontWeightBold,
                    fontSize: AppTypography.fontSizeSm,
                    color: context.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: AppTypography.fontWeightBold,
          ),
        ),
        SizedBox(height: AppSpacing.base),
        // Reminders
        CommonTransitions.fadeSlideIn(
          direction: Offset(0, AppSpacing.xl),
          child: HBCard.elevated(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gradient Header Strip
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadii.md),
                      topRight: Radius.circular(AppRadii.md),
                    ),
                  ),
                ),
                // Card Content
                Padding(
                  padding: EdgeInsets.all(AppSpacing.base),
                  child: const UpcomingRemindersWidget(),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AppSpacing.base),
        // Recent Activity
        CommonTransitions.fadeSlideIn(
          direction: Offset(0, AppSpacing.xl),
          child: HBCard.elevated(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gradient Header Strip
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF047857)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadii.md),
                      topRight: Radius.circular(AppRadii.md),
                    ),
                  ),
                ),
                // Card Content
                Padding(
                  padding: EdgeInsets.all(AppSpacing.base),
                  child: const RecentActivityWidget(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showQuickAddDialog(context),
      tooltip: 'Quick Add',
      icon: Icon(Icons.add_rounded, size: AppSizes.iconMd),
      label: Text(
        'Quick Add',
        style: TextStyle(
          fontWeight: AppTypography.fontWeightSemiBold,
          fontSize: AppTypography.fontSizeSm,
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.radiusLg,
        ),
        title: const Text('Search'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HBTextField.filled(
              hint: 'Search medical records, profiles...',
              prefixIcon: Icons.search_rounded,
            ),
            SizedBox(height: AppSpacing.base),
            const Text('Global search will be available in a future update.'),
          ],
        ),
        actions: [
          HBButton.text(
            onPressed: () => context.pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.lg),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.xl,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                'Quick Add',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: AppTypography.fontWeightBold,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              _buildQuickAddOption(
                context,
                Icons.person_add_rounded,
                'Add Family Member',
                () {
                  context.pop();
                  context.push(AppRoutes.profiles);
                },
              ),
              _buildQuickAddOption(
                context,
                Icons.medical_information_rounded,
                'Add Medical Record',
                () {
                  context.pop();
                  context.push(AppRoutes.medicalRecords);
                },
              ),
              _buildQuickAddOption(
                context,
                Icons.medication_rounded,
                'Add Medication',
                () {
                  context.pop();
                  context.push(AppRoutes.medicalRecords);
                },
              ),
              _buildQuickAddOption(
                context,
                Icons.alarm_add_rounded,
                'Set Reminder',
                () {
                  context.pop();
                  context.push(AppRoutes.reminders);
                },
              ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAddOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.radiusMd,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: AppRadii.radiusSm,
                ),
                child: Icon(
                  icon,
                  color: context.colorScheme.onPrimaryContainer,
                  size: AppSizes.iconLg,
                ),
              ),
              SizedBox(width: AppSpacing.base),
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: AppTypography.fontWeightMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileSelector(
    BuildContext context,
    AsyncValue<List<dynamic>> profilesAsync,
  ) {
    profilesAsync.when(
      loading: () {},
      error: (_, __) {},
      data: (profiles) {
        if (profiles.isEmpty) return;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) => Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadii.xl2),
                ),
                boxShadow: AppElevation.shadow(
                  AppElevation.level5,
                  isDark: context.isDark,
                ),
              ),
              child: Column(
                children: [
                  // Header Section
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.base,
                      AppSpacing.xl,
                      0,
                    ),
                    child: Column(
                      children: [
                        // Drag Handle
                        Container(
                          width: AppSizes.xl,
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.colorScheme.outline
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(AppRadii.xs),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl),
                        // Header with Icon and Title
                        Row(
                          children: [
                            Container(
                              width: AppSizes.xl2,
                              height: AppSizes.xl2,
                              decoration: BoxDecoration(
                                color: context.colorScheme.primaryContainer,
                                borderRadius: AppRadii.radiusMd,
                              ),
                              child: Icon(
                                Icons.people_rounded,
                                color: context.colorScheme.onPrimaryContainer,
                                size: AppSizes.iconLg,
                              ),
                            ),
                            SizedBox(width: AppSpacing.base),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Profile',
                                    style: context.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: AppTypography.fontWeightBold,
                                      color: context.colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Choose a family member',
                                    style: context.textTheme.bodyMedium
                                        ?.copyWith(
                                      color:
                                          context.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                  // Profile List
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      itemCount: profiles.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) =>
                          _buildProfileOption(context, profiles[index]),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    FamilyMemberProfile profile,
  ) {
    final selectedProfileAsync = ref.watch(simpleSelectedProfileProvider);
    final isSelected = selectedProfileAsync.maybeWhen(
      data: (selectedProfile) => selectedProfile?.id == profile.id,
      orElse: () => false,
    );
    final age = DateTime.now().year - profile.dateOfBirth.year;
    final genderColor = _getGenderColor(profile.gender);
    final initials =
        '${profile.firstName[0]}${profile.lastName[0]}'.toUpperCase();

    return HBCard.elevated(
      onTap: () {
        ref.read(setSelectedProfileProvider).call(profile.id);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to ${profile.firstName}\'s profile'),
            duration: AppDurations.short,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadii.radiusMd,
            ),
          ),
        );
      },
      borderColor: isSelected ? context.colorScheme.primary : null,
      borderWidth: isSelected ? 2 : 0,
      backgroundColor: isSelected
          ? context.colorScheme.primaryContainer
              .withValues(alpha: context.isDark ? 0.3 : 0.15)
          : null,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          // Avatar with Gradient
          Container(
            width: AppSizes.xl2,
            height: AppSizes.xl2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [genderColor, genderColor.withValues(alpha: 0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: AppElevation.coloredShadow(
                genderColor,
                opacity: 0.3,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: context.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: AppTypography.fontWeightBold,
                  fontSize: AppTypography.fontSizeLg,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: AppTypography.fontWeightSemiBold,
                    color: isSelected
                        ? context.colorScheme.primary
                        : context.colorScheme.onSurface,
                    height: 1.2,
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
                        color: context.colorScheme.surfaceContainerHighest,
                        borderRadius: AppRadii.radiusSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            size: AppSizes.iconXs,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            '$age years',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                              fontWeight: AppTypography.fontWeightMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: genderColor
                            .withValues(alpha: context.isDark ? 0.2 : 0.1),
                        borderRadius: AppRadii.radiusSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getGenderIcon(profile.gender),
                            size: AppSizes.iconXs,
                            color: genderColor,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            profile.gender,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: genderColor,
                              fontWeight: AppTypography.fontWeightSemiBold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Selection Indicator
          if (isSelected)
            Container(
              width: AppSizes.lg,
              height: AppSizes.lg,
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: AppSizes.iconMd,
              ),
            ),
        ],
      ),
    );
  }

  Color _getGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return context.isDark
            ? const Color(0xFF60A5FA)
            : const Color(0xFF3B82F6);
      case 'female':
        return context.isDark
            ? const Color(0xFFF472B6)
            : const Color(0xFFEC4899);
      default:
        return context.isDark
            ? const Color(0xFF34D399)
            : const Color(0xFF059669);
    }
  }

  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.person;
    }
  }
}

class _QuickAction {
  const _QuickAction({
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  final String label;
  final String value;
  final IconData icon;
  final Gradient gradient;
}
