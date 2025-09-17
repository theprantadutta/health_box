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
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/theme/app_theme.dart';
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: !_isMandatoryFirstProfile && !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasUnsavedChanges && !_isMandatoryFirstProfile) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing
                ? 'Edit Profile'
                : _isMandatoryFirstProfile
                ? 'Create Your First Profile'
                : 'Add New Profile',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          automaticallyImplyLeading: !_isMandatoryFirstProfile,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(isDarkMode),
            ),
          ),
          actions: [
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
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
            else
              TextButton(
                onPressed: _saveProfile,
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile Image Section
              Hero(
                tag: widget.profile != null
                    ? 'profile_${widget.profile!.id}'
                    : 'new_profile',
                child: ModernCard(
                  elevation: CardElevation.medium,
                  child: _buildProfileImageSection(),
                ),
              ),
              const SizedBox(height: 24),

              // Mandatory Profile Message for first profile
              if (_isMandatoryFirstProfile)
                ModernCard(
                  elevation: CardElevation.low,
                  color: theme.colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onPrimaryContainer,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Create Your Profile',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'To get started with HealthBox, please create your profile. You can add family members later.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isMandatoryFirstProfile) const SizedBox(height: 24),

              // Basic Information Card
              ModernCard(
                elevation: CardElevation.medium,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // First Name
                    TextFormField(
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        if (value.length > 50) {
                          return 'First name cannot exceed 50 characters';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _lastNameFocus.requestFocus(),
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    TextFormField(
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        if (value.length > 50) {
                          return 'Last name cannot exceed 50 characters';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _middleNameFocus.requestFocus(),
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 16),

                    // Middle Name
                    TextFormField(
                      controller: _middleNameController,
                      focusNode: _middleNameFocus,
                      decoration: const InputDecoration(
                        labelText: 'Middle Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value != null && value.length > 50) {
                          return 'Middle name cannot exceed 50 characters';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth
                    _buildDateOfBirthField(),
                    const SizedBox(height: 16),

                    // Gender
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Gender *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGender,
                          isExpanded: true,
                          items: _genders.map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Relationship (only show when creating new profiles, not when editing main user)
                    if (!_isMainUserProfile)
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Relationship *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.family_restroom),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRelationship,
                            isExpanded: true,
                            items: _relationships.map((relationship) {
                              return DropdownMenuItem(
                                value: relationship,
                                child: Text(relationship),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedRelationship = value!;
                                _hasUnsavedChanges = true;
                              });
                            },
                          ),
                        ),
                      ),
                    if (!_isMainUserProfile) const SizedBox(height: 16),
                    const SizedBox(height: 24),

                    // Contact Information
                    Text(
                      'Contact Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        hintText: '+1 (555) 123-4567',
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          // Basic phone validation
                          if (value.length < 10) {
                            return 'Phone number must be at least 10 digits';
                          }
                        }
                        return null;
                      },
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 16),

                    // Email Address
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        hintText: 'example@email.com',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _addressFocus.requestFocus(),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          // Email validation
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                        }
                        return null;
                      },
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      focusNode: _addressFocus,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home),
                        hintText: 'Street address, city, state, zip',
                      ),
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _heightFocus.requestFocus(),
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 24),

                    // Medical Information
                    Text(
                      'Medical Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Blood Type
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Blood Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.bloodtype),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _selectedBloodType,
                          isExpanded: true,
                          hint: const Text('Select blood type'),
                          items: _bloodTypes.map((bloodType) {
                            return DropdownMenuItem(
                              value: bloodType,
                              child: Text(bloodType),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBloodType = value;
                              _hasUnsavedChanges = true;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Height and Weight Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            focusNode: _heightFocus,
                            decoration: const InputDecoration(
                              labelText: 'Height (cm)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.height),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _weightFocus.requestFocus(),
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
                            onChanged: (_) =>
                                setState(() => _hasUnsavedChanges = true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            focusNode: _weightFocus,
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monitor_weight),
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _medicalConditionsFocus.requestFocus(),
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
                            onChanged: (_) =>
                                setState(() => _hasUnsavedChanges = true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Medical Conditions
                    TextFormField(
                      controller: _medicalConditionsController,
                      focusNode: _medicalConditionsFocus,
                      decoration: const InputDecoration(
                        labelText: 'Medical Conditions',
                        hintText: 'Diabetes, hypertension, asthma, etc.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _allergiesFocus.requestFocus(),
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 16),

                    // Allergies
                    TextFormField(
                      controller: _allergiesController,
                      focusNode: _allergiesFocus,
                      decoration: const InputDecoration(
                        labelText: 'Allergies',
                        hintText:
                            'Food allergies, medications, environmental, etc.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.warning_amber),
                      ),
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          _emergencyContactFocus.requestFocus(),
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 24),

                    // Emergency Information
                    Text(
                      'Emergency Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Emergency Contact Name
                    TextFormField(
                      controller: _emergencyContactController,
                      focusNode: _emergencyContactFocus,
                      decoration: const InputDecoration(
                        labelText: 'Emergency Contact Name',
                        hintText: 'Full name of emergency contact',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.emergency),
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          _emergencyPhoneFocus.requestFocus(),
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 16),

                    // Emergency Contact Phone
                    TextFormField(
                      controller: _emergencyPhoneController,
                      focusNode: _emergencyPhoneFocus,
                      decoration: const InputDecoration(
                        labelText: 'Emergency Contact Phone',
                        hintText: '+1 (555) 123-4567',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_in_talk),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) => _insuranceFocus.requestFocus(),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (value.length < 10) {
                            return 'Emergency phone must be at least 10 digits';
                          }
                        }
                        return null;
                      },
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 16),

                    // Insurance Information
                    TextFormField(
                      controller: _insuranceInfoController,
                      focusNode: _insuranceFocus,
                      decoration: const InputDecoration(
                        labelText: 'Insurance Information',
                        hintText: 'Provider, policy number, etc.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) =>
                          setState(() => _hasUnsavedChanges = true),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
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
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
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
          const SizedBox(height: 12),
          Text(
            _isEditing ? 'Update Profile Photo' : 'Add Profile Photo',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    return InkWell(
      onTap: _selectDateOfBirth,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth *',
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
          errorText: _dateOfBirthTouched && _selectedDateOfBirth == null
              ? 'Date of birth is required'
              : null,
        ),
        child: Text(
          _selectedDateOfBirth != null
              ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
              : 'Select date of birth',
          style: _selectedDateOfBirth != null
              ? null
              : TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: HealthButton(
            onPressed: _isLoading ? null : _saveProfile,
            isLoading: _isLoading,
            size: HealthButtonSize.large,
            style: HealthButtonStyle.primary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isLoading)
                  Icon(
                    _isEditing ? Icons.save : Icons.person_add,
                    color: Colors.white,
                  ),
                if (!_isLoading) const SizedBox(width: 8),
                Text(_isEditing ? 'Save Changes' : 'Add Profile'),
              ],
            ),
          ),
        ),
        if (!_isMandatoryFirstProfile) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      if (_hasUnsavedChanges) {
                        final shouldPop = await _showUnsavedChangesDialog();
                        if (shouldPop && mounted) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
              child: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
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
      initialDate:
          _selectedDateOfBirth ??
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
    // Mark date of birth as touched if validation fails
    if (_selectedDateOfBirth == null) {
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
            backgroundColor: Theme.of(context).colorScheme.error,
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
            const SnackBar(
              content: Text(
                'Welcome to HealthBox! Your profile has been created.',
              ),
            ),
          );
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Profile updated successfully'
                    : 'Profile created successfully',
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
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
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Stay'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
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
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _removeImage();
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
            backgroundColor: Theme.of(context).colorScheme.error,
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
