import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/simple_profile_providers.dart';
import '../../../shared/widgets/hb_app_bar.dart';
import '../../../shared/widgets/hb_button.dart';
import '../../../shared/widgets/hb_text_field.dart';
import '../../../shared/widgets/hb_card.dart';
import '../../../shared/theme/design_system.dart';
import '../../../shared/navigation/app_router.dart';
import '../services/profile_service.dart';

class ProfileFormScreen extends ConsumerStatefulWidget {
  final FamilyMemberProfile? profile;

  const ProfileFormScreen({super.key, this.profile});

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _insuranceInfoController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _allergiesController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  String _selectedGender = 'Male';
  String _selectedRelationship = 'Self';
  bool _isMainUserProfile = false;
  String? _selectedBloodType;
  bool _isLoading = false;
  bool _isMandatoryFirstProfile = false;
  bool _dateOfBirthTouched = false;
  bool _hasUnsavedChanges = false;
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // Focus nodes for better keyboard navigation
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _middleNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _heightFocus = FocusNode();
  final _weightFocus = FocusNode();
  final _medicalConditionsFocus = FocusNode();
  final _allergiesFocus = FocusNode();
  final _emergencyContactFocus = FocusNode();
  final _emergencyPhoneFocus = FocusNode();
  final _insuranceFocus = FocusNode();

  final List<String> _genders = ['Male', 'Female', 'Other', 'Unspecified'];
  final List<String> _relationships = [
    'Self',
    'Spouse',
    'Child',
    'Parent',
    'Sibling',
    'Grandparent',
    'Grandchild',
    'Other Family',
    'Guardian',
  ];
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  bool get _isEditing => widget.profile != null;

  @override
  void initState() {
    super.initState();
    _determineProfileType();
    _initializeFields();
    _checkIfMandatoryFirstProfile();
  }

  void _determineProfileType() {
    // If we're editing a profile, check if it's the main user profile
    // This can be determined by checking if we're editing and the relationship is 'Self'
    // or if this is the mandatory first profile
    if (_isEditing && widget.profile != null) {
      // For now, assume any profile being edited from settings is the main user profile
      // In the future, we could add a flag or check relationship when it's added to DB
      _isMainUserProfile = true;
      _selectedRelationship = 'Self'; // Main user is always 'Self'
    }
  }

  Future<void> _checkIfMandatoryFirstProfile() async {
    if (!_isEditing) {
      try {
        final database = AppDatabase.instance;
        final profilesQuery = await database
            .select(database.familyMemberProfiles)
            .get();
        setState(() {
          _isMandatoryFirstProfile = profilesQuery.isEmpty;
        });
      } catch (e) {
        // If there's an error, assume it might be the first profile
        setState(() {
          _isMandatoryFirstProfile = true;
        });
      }
    }
  }

  void _initializeFields() {
    if (_isEditing) {
      final profile = widget.profile!;
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _middleNameController.text = profile.middleName ?? '';
      _selectedDateOfBirth = profile.dateOfBirth;
      _selectedGender = profile.gender;
      _selectedBloodType = profile.bloodType;
      _heightController.text = profile.height?.toString() ?? '';
      _weightController.text = profile.weight?.toString() ?? '';
      _emergencyContactController.text = profile.emergencyContact ?? '';
      _insuranceInfoController.text = profile.insuranceInfo ?? '';

      // Load existing profile image if available
      if (profile.profileImagePath != null &&
          profile.profileImagePath!.isNotEmpty) {
        final imageFile = File(profile.profileImagePath!);
        if (imageFile.existsSync()) {
          _selectedImage = imageFile;
        }
      }

      // Note: New fields (phone, email, address, etc.) are not part of existing profile data
      // They would need to be added to the database schema in a future migration
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _insuranceInfoController.dispose();
    _medicalConditionsController.dispose();
    _allergiesController.dispose();

    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _middleNameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _addressFocus.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
    _medicalConditionsFocus.dispose();
    _allergiesFocus.dispose();
    _emergencyContactFocus.dispose();
    _emergencyPhoneFocus.dispose();
    _insuranceFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isMandatoryFirstProfile && !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasUnsavedChanges && !_isMandatoryFirstProfile) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop && mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        appBar: HBAppBar.gradient(
          title: _isEditing
              ? 'Edit Profile'
              : _isMandatoryFirstProfile
                  ? 'Create Your First Profile'
                  : 'Add New Profile',
          gradient: HealthBoxDesignSystem.medicalGreen,
          automaticallyImplyLeading: !_isMandatoryFirstProfile,
          actions: _isLoading
              ? [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  )
                ]
              : [
                  HBButton.text(
                    text: 'SAVE',
                    onPressed: _saveProfile,
                    textColor: Colors.white,
                  ),
                ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: context.responsivePadding,
            children: [
              // Profile Image Section
              Hero(
                tag: widget.profile != null
                    ? 'profile_${widget.profile!.id}'
                    : 'new_profile',
                child: HBCard.elevated(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: _buildProfileImageSection(),
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Mandatory Profile Message for first profile
              if (_isMandatoryFirstProfile) ...[
                HBCard.elevated(
                  padding: EdgeInsets.all(AppSpacing.base),
                  backgroundColor: context.colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: context.colorScheme.onPrimaryContainer,
                        size: AppSizes.iconMd,
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Your Profile',
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: AppTypography.fontWeightBold,
                                color: context.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'To get started with HealthBox, please create your profile. You can add family members later.',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
              ],

              // Basic Information Card
              HBCard.elevated(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Basic Information',
                      Icons.person,
                      HealthBoxDesignSystem.medicalBlue,
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // First Name
                    HBTextField.filled(
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                      label: 'First Name *',
                      prefixIcon: Icons.person,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _lastNameFocus.requestFocus(),
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        if (value.length > 50) {
                          return 'First name cannot exceed 50 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Last Name
                    HBTextField.filled(
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      label: 'Last Name *',
                      prefixIcon: Icons.person,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _middleNameFocus.requestFocus(),
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        if (value.length > 50) {
                          return 'Last name cannot exceed 50 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Middle Name
                    HBTextField.filled(
                      controller: _middleNameController,
                      focusNode: _middleNameFocus,
                      label: 'Middle Name',
                      prefixIcon: Icons.person_outline,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                      validator: (value) {
                        if (value != null && value.length > 50) {
                          return 'Middle name cannot exceed 50 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Date of Birth
                    _buildDateOfBirthTile(),
                    SizedBox(height: AppSpacing.base),

                    // Gender
                    _buildDropdownTile(
                      label: 'Gender *',
                      icon: Icons.people,
                      value: _selectedGender,
                      items: _genders,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Relationship (only show when creating new profiles, not when editing main user)
                    if (!_isMainUserProfile) ...[
                      _buildDropdownTile(
                        label: 'Relationship *',
                        icon: Icons.family_restroom,
                        value: _selectedRelationship,
                        items: _relationships,
                        onChanged: (value) {
                          setState(() {
                            _selectedRelationship = value!;
                            _hasUnsavedChanges = true;
                          });
                        },
                      ),
                      SizedBox(height: AppSpacing.base),
                    ],
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Contact Information Card
              HBCard.elevated(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Contact Information',
                      Icons.contact_phone,
                      HealthBoxDesignSystem.medicalPurple,
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // Phone Number
                    HBTextField.filled(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      label: 'Phone Number',
                      prefixIcon: Icons.phone,
                      hint: '+1 (555) 123-4567',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 10) {
                            return 'Phone number must be at least 10 digits';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Email Address
                    HBTextField.filled(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      label: 'Email Address',
                      prefixIcon: Icons.email,
                      hint: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _addressFocus.requestFocus(),
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Address
                    HBTextField.multiline(
                      controller: _addressController,
                      focusNode: _addressFocus,
                      label: 'Address',
                      prefixIcon: Icons.home,
                      hint: 'Street address, city, state, zip',
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _heightFocus.requestFocus(),
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Medical Information Card
              HBCard.elevated(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Medical Information',
                      Icons.medical_information,
                      HealthBoxDesignSystem.medicalRed,
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // Blood Type
                    _buildDropdownTile(
                      label: 'Blood Type',
                      icon: Icons.bloodtype,
                      value: _selectedBloodType,
                      items: _bloodTypes,
                      hint: 'Select blood type',
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodType = value;
                          _hasUnsavedChanges = true;
                        });
                      },
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Height and Weight Row
                    Row(
                      children: [
                        Expanded(
                          child: HBTextField.number(
                            controller: _heightController,
                            focusNode: _heightFocus,
                            label: 'Height (cm)',
                            prefixIcon: Icons.height,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _weightFocus.requestFocus(),
                            onChanged: (_) =>
                                setState(() => _hasUnsavedChanges = true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,1}'),
                              ),
                            ],
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final height = double.tryParse(value);
                                if (height == null) {
                                  return 'Invalid height';
                                }
                                if (height < 30 || height > 300) {
                                  return 'Height must be between 30-300 cm';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: AppSpacing.base),
                        Expanded(
                          child: HBTextField.number(
                            controller: _weightController,
                            focusNode: _weightFocus,
                            label: 'Weight (kg)',
                            prefixIcon: Icons.monitor_weight,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _medicalConditionsFocus.requestFocus(),
                            onChanged: (_) =>
                                setState(() => _hasUnsavedChanges = true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,1}'),
                              ),
                            ],
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final weight = double.tryParse(value);
                                if (weight == null) {
                                  return 'Invalid weight';
                                }
                                if (weight < 0.5 || weight > 500) {
                                  return 'Weight must be between 0.5-500 kg';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Medical Conditions
                    HBTextField.multiline(
                      controller: _medicalConditionsController,
                      focusNode: _medicalConditionsFocus,
                      label: 'Medical Conditions',
                      prefixIcon: Icons.local_hospital,
                      hint: 'Diabetes, hypertension, asthma, etc.',
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _allergiesFocus.requestFocus(),
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Allergies
                    HBTextField.multiline(
                      controller: _allergiesController,
                      focusNode: _allergiesFocus,
                      label: 'Allergies',
                      prefixIcon: Icons.warning_amber,
                      hint: 'Food allergies, medications, environmental, etc.',
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          _emergencyContactFocus.requestFocus(),
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Emergency Information Card
              HBCard.elevated(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Emergency Information',
                      Icons.emergency,
                      HealthBoxDesignSystem.medicalOrange,
                    ),
                    SizedBox(height: AppSpacing.lg),

                    // Emergency Contact Name
                    HBTextField.filled(
                      controller: _emergencyContactController,
                      focusNode: _emergencyContactFocus,
                      label: 'Emergency Contact Name',
                      prefixIcon: Icons.emergency,
                      hint: 'Full name of emergency contact',
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _emergencyPhoneFocus.requestFocus(),
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Emergency Contact Phone
                    HBTextField.filled(
                      controller: _emergencyPhoneController,
                      focusNode: _emergencyPhoneFocus,
                      label: 'Emergency Contact Phone',
                      prefixIcon: Icons.phone_in_talk,
                      hint: '+1 (555) 123-4567',
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _insuranceFocus.requestFocus(),
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 10) {
                            return 'Emergency phone must be at least 10 digits';
                          }
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: AppSpacing.base),

                    // Insurance Information
                    HBTextField.multiline(
                      controller: _insuranceInfoController,
                      focusNode: _insuranceFocus,
                      label: 'Insurance Information',
                      prefixIcon: Icons.medical_services,
                      hint: 'Provider, policy number, etc.',
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() => _hasUnsavedChanges = true),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.xl),

              // Action Buttons
              _buildActionButtons(),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: HealthBoxDesignSystem.medicalGreen,
                  boxShadow: AppElevation.coloredShadow(
                    HealthBoxDesignSystem.medicalGreen.colors.first,
                    opacity: 0.3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colorScheme.surface,
                      width: 2,
                    ),
                    boxShadow: AppElevation.md,
                  ),
                  child: IconButton(
                    onPressed: _showImagePickerDialog,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    color: Colors.white,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            _isEditing ? 'Update Profile Photo' : 'Add Profile Photo',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Gradient gradient) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.md),
            boxShadow: AppElevation.coloredShadow(
              gradient.colors.first,
              opacity: 0.3,
            ),
          ),
          child: Icon(icon, size: AppSizes.iconMd, color: Colors.white),
        ),
        SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: AppTypography.fontWeightSemiBold,
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthTile() {
    final bool hasError = _dateOfBirthTouched && _selectedDateOfBirth == null;

    return InkWell(
      onTap: _selectDateOfBirth,
      borderRadius: AppRadii.radiusMd,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: AppRadii.radiusMd,
          border: Border.all(
            color: hasError
                ? context.colorScheme.error
                : context.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(
                Icons.calendar_today,
                size: AppSizes.iconSm,
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date of Birth *',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: hasError
                          ? context.colorScheme.error
                          : context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    _selectedDateOfBirth != null
                        ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                        : 'Select date of birth',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: _selectedDateOfBirth != null
                          ? context.colorScheme.onSurface
                          : context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  if (hasError) ...[
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Date of birth is required',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: AppSizes.iconXs,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    String? hint,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.radiusMd,
        border: Border.all(
          color: context.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              icon,
              size: AppSizes.iconSm,
              color: context.colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: value,
                    isExpanded: true,
                    isDense: true,
                    hint: hint != null ? Text(hint) : null,
                    items: items.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: context.textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: HBButton.primary(
            text: _isEditing ? 'Save Changes' : 'Add Profile',
            onPressed: _isLoading ? null : _saveProfile,
            isLoading: _isLoading,
            icon: _isEditing ? Icons.save : Icons.person_add,
          ),
        ),
        if (!_isMandatoryFirstProfile) ...[
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: HBButton.outlined(
              text: 'Cancel',
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_hasUnsavedChanges) {
                        final shouldPop = await _showUnsavedChangesDialog();
                        if (shouldPop && mounted) {
                          context.pop();
                        }
                      } else {
                        context.pop();
                      }
                    },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    setState(() {
      _dateOfBirthTouched = true;
    });

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _hasUnsavedChanges = true;
      });
    }
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

  Future<void> _saveProfile() async {
    print('=== SAVE PROFILE CALLED ===');
    print('Form valid: ${_formKey.currentState?.validate()}');
    print('Date of birth: $_selectedDateOfBirth');
    print('First name: ${_firstNameController.text}');
    print('Last name: ${_lastNameController.text}');

    // Mark date of birth as touched if validation fails
    if (_selectedDateOfBirth == null) {
      print('Date of birth is null, marking as touched');
      setState(() {
        _dateOfBirthTouched = true;
      });
    }

    // Validate age
    if (_selectedDateOfBirth != null) {
      final age = _calculateAge(_selectedDateOfBirth!);
      if (age > 150) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Please check the date of birth - age seems unrealistic',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    if (!_formKey.currentState!.validate() || _selectedDateOfBirth == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profileService = ref.read(simpleProfileServiceProvider);

      if (_isEditing) {
        // Save profile image first and get the path
        final String? newImagePath = await _saveProfileImage();

        // Delete old image if we have a new one and it's different
        if (newImagePath != null &&
            widget.profile!.profileImagePath != newImagePath) {
          await _deleteOldProfileImage(widget.profile!.profileImagePath);
        }

        // Update existing profile
        final updateRequest = UpdateProfileRequest(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          middleName: _middleNameController.text.trim().isEmpty
              ? null
              : _middleNameController.text.trim(),
          dateOfBirth: _selectedDateOfBirth,
          gender: _selectedGender,
          bloodType: _selectedBloodType,
          height: _heightController.text.isEmpty
              ? null
              : double.tryParse(_heightController.text),
          weight: _weightController.text.isEmpty
              ? null
              : double.tryParse(_weightController.text),
          emergencyContact: _emergencyContactController.text.trim().isEmpty
              ? null
              : _emergencyContactController.text.trim(),
          insuranceInfo: _insuranceInfoController.text.trim().isEmpty
              ? null
              : _insuranceInfoController.text.trim(),
          profileImagePath: newImagePath,
        );

        await profileService.updateProfile(widget.profile!.id, updateRequest);
        // Invalidate providers to refresh data
        ref.invalidate(simpleProfilesProvider);
        ref.invalidate(simpleSelectedProfileProvider);
      } else {
        // Create new profile
        final createRequest = CreateProfileRequest(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          middleName: _middleNameController.text.trim().isEmpty
              ? null
              : _middleNameController.text.trim(),
          dateOfBirth: _selectedDateOfBirth!,
          gender: _selectedGender,
          bloodType: _selectedBloodType,
          height: _heightController.text.isEmpty
              ? null
              : double.tryParse(_heightController.text),
          weight: _weightController.text.isEmpty
              ? null
              : double.tryParse(_weightController.text),
          emergencyContact: _emergencyContactController.text.trim().isEmpty
              ? null
              : _emergencyContactController.text.trim(),
          insuranceInfo: _insuranceInfoController.text.trim().isEmpty
              ? null
              : _insuranceInfoController.text.trim(),
          profileImagePath: await _saveProfileImage(),
        );

        await profileService.createProfile(createRequest);
        // Invalidate providers to refresh data
        ref.invalidate(simpleProfilesProvider);
        ref.invalidate(simpleSelectedProfileProvider);
      }

      if (mounted) {
        if (_isMandatoryFirstProfile) {
          // Navigate to dashboard after creating the first profile
          context.pushReplacement(AppRoutes.dashboard);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Welcome to HealthBox! Your profile has been created.',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Profile updated successfully'
                    : 'Profile created successfully',
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text(
                'You have unsaved changes. Are you sure you want to leave without saving?',
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(false),
                  child: const Text('Stay'),
                ),
                TextButton(
                  onPressed: () => context.pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colorScheme.error,
                  ),
                  child: const Text('Leave'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Profile Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  context.pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  context.pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: Icon(Icons.delete, color: AppColors.error),
                  title: Text(
                    'Remove Photo',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    context.pop();
                    _removeImage();
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _hasUnsavedChanges = true;
    });
  }

  Future<String?> _saveProfileImage() async {
    if (_selectedImage == null) return null;

    try {
      // Get the app documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final Directory profileImagesDir = Directory(
        path.join(appDocDir.path, 'profile_images'),
      );

      // Create directory if it doesn't exist
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      // Generate a unique filename
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(_selectedImage!.path);
      final String fileName = 'profile_${timestamp}$extension';
      final String savedImagePath = path.join(profileImagesDir.path, fileName);

      // Copy the image to the permanent location
      final File savedImage = await _selectedImage!.copy(savedImagePath);

      return savedImage.path;
    } catch (e) {
      print('Error saving profile image: $e');
      return null;
    }
  }

  Future<void> _deleteOldProfileImage(String? oldImagePath) async {
    if (oldImagePath == null || oldImagePath.isEmpty) return;

    try {
      final File oldImage = File(oldImagePath);
      if (await oldImage.exists()) {
        await oldImage.delete();
      }
    } catch (e) {
      print('Error deleting old profile image: $e');
    }
  }
}
