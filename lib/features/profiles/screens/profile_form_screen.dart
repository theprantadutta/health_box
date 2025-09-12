import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/providers/profile_providers.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/theme/app_theme.dart';
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
  final _emergencyContactController = TextEditingController();
  final _insuranceInfoController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  String _selectedGender = 'Male';
  String? _selectedBloodType;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other', 'Unspecified'];
  final List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Unknown'
  ];

  bool get _isEditing => widget.profile != null;

  @override
  void initState() {
    super.initState();
    _initializeFields();
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
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _emergencyContactController.dispose();
    _insuranceInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Profile' : 'Add New Profile',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getPrimaryGradient(isDarkMode),
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
              tag: widget.profile != null ? 'profile_${widget.profile!.id}' : 'new_profile',
              child: ModernCard(
                elevation: CardElevation.medium,
                child: _buildProfileImageSection(),
              ),
            ),
            const SizedBox(height: 24),
            
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
            ),
            const SizedBox(height: 16),
            
            // Last Name
            TextFormField(
              controller: _lastNameController,
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
            ),
            const SizedBox(height: 16),
            
            // Middle Name
            TextFormField(
              controller: _middleNameController,
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
                    return DropdownMenuItem(value: gender, child: Text(gender));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              ),
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
                    return DropdownMenuItem(value: bloodType, child: Text(bloodType));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBloodType = value;
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
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
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
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
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
            const SizedBox(height: 24),
            
            // Emergency Information
            Text(
              'Emergency Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            // Emergency Contact
            TextFormField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: 'Emergency Contact',
                hintText: 'Name and phone number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.emergency),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // Insurance Information
            TextFormField(
              controller: _insuranceInfoController,
              decoration: const InputDecoration(
                labelText: 'Insurance Information',
                hintText: 'Provider, policy number, etc.',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medical_services),
              ),
              maxLines: 3,
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
    );
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              // TODO: Implement image picker when available
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile image picker will be implemented in Phase 3.7'),
                ),
              );
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Change Photo'),
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
          errorText: _selectedDateOfBirth == null ? 'Date of birth is required' : null,
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
          child: GradientButton(
            onPressed: _isLoading ? null : _saveProfile,
            isLoading: _isLoading,
            size: GradientButtonSize.large,
            style: GradientButtonStyle.primary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_isLoading) Icon(
                  _isEditing ? Icons.save : Icons.person_add,
                  color: Colors.white,
                ),
                if (!_isLoading) const SizedBox(width: 8),
                Text(_isEditing ? 'Save Changes' : 'Add Profile'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _selectedDateOfBirth == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profileNotifier = ref.read(profileNotifierProvider.notifier);

      if (_isEditing) {
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
        );

        await profileNotifier.updateProfile(widget.profile!.id, updateRequest);
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
        );

        await profileNotifier.createProfile(createRequest);
      }

      if (mounted) {
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
}