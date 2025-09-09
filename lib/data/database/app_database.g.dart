// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FamilyMemberProfilesTable extends FamilyMemberProfiles
    with TableInfo<$FamilyMemberProfilesTable, FamilyMemberProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyMemberProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _middleNameMeta = const VerificationMeta(
    'middleName',
  );
  @override
  late final GeneratedColumn<String> middleName = GeneratedColumn<String>(
    'middle_name',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateOfBirthMeta = const VerificationMeta(
    'dateOfBirth',
  );
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
    'date_of_birth',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bloodTypeMeta = const VerificationMeta(
    'bloodType',
  );
  @override
  late final GeneratedColumn<String> bloodType = GeneratedColumn<String>(
    'blood_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<double> height = GeneratedColumn<double>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emergencyContactMeta = const VerificationMeta(
    'emergencyContact',
  );
  @override
  late final GeneratedColumn<String> emergencyContact = GeneratedColumn<String>(
    'emergency_contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _insuranceInfoMeta = const VerificationMeta(
    'insuranceInfo',
  );
  @override
  late final GeneratedColumn<String> insuranceInfo = GeneratedColumn<String>(
    'insurance_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileImagePathMeta = const VerificationMeta(
    'profileImagePath',
  );
  @override
  late final GeneratedColumn<String> profileImagePath = GeneratedColumn<String>(
    'profile_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    firstName,
    lastName,
    middleName,
    dateOfBirth,
    gender,
    bloodType,
    height,
    weight,
    emergencyContact,
    insuranceInfo,
    profileImagePath,
    createdAt,
    updatedAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_member_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyMemberProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('middle_name')) {
      context.handle(
        _middleNameMeta,
        middleName.isAcceptableOrUnknown(data['middle_name']!, _middleNameMeta),
      );
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
        _dateOfBirthMeta,
        dateOfBirth.isAcceptableOrUnknown(
          data['date_of_birth']!,
          _dateOfBirthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateOfBirthMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('blood_type')) {
      context.handle(
        _bloodTypeMeta,
        bloodType.isAcceptableOrUnknown(data['blood_type']!, _bloodTypeMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('emergency_contact')) {
      context.handle(
        _emergencyContactMeta,
        emergencyContact.isAcceptableOrUnknown(
          data['emergency_contact']!,
          _emergencyContactMeta,
        ),
      );
    }
    if (data.containsKey('insurance_info')) {
      context.handle(
        _insuranceInfoMeta,
        insuranceInfo.isAcceptableOrUnknown(
          data['insurance_info']!,
          _insuranceInfoMeta,
        ),
      );
    }
    if (data.containsKey('profile_image_path')) {
      context.handle(
        _profileImagePathMeta,
        profileImagePath.isAcceptableOrUnknown(
          data['profile_image_path']!,
          _profileImagePathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyMemberProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyMemberProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      middleName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}middle_name'],
      ),
      dateOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_of_birth'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      bloodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_type'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      emergencyContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emergency_contact'],
      ),
      insuranceInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurance_info'],
      ),
      profileImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_image_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $FamilyMemberProfilesTable createAlias(String alias) {
    return $FamilyMemberProfilesTable(attachedDatabase, alias);
  }
}

class FamilyMemberProfile extends DataClass
    implements Insertable<FamilyMemberProfile> {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final DateTime dateOfBirth;
  final String gender;
  final String? bloodType;
  final double? height;
  final double? weight;
  final String? emergencyContact;
  final String? insuranceInfo;
  final String? profileImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  const FamilyMemberProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    required this.gender,
    this.bloodType,
    this.height,
    this.weight,
    this.emergencyContact,
    this.insuranceInfo,
    this.profileImagePath,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || middleName != null) {
      map['middle_name'] = Variable<String>(middleName);
    }
    map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || bloodType != null) {
      map['blood_type'] = Variable<String>(bloodType);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<double>(height);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || emergencyContact != null) {
      map['emergency_contact'] = Variable<String>(emergencyContact);
    }
    if (!nullToAbsent || insuranceInfo != null) {
      map['insurance_info'] = Variable<String>(insuranceInfo);
    }
    if (!nullToAbsent || profileImagePath != null) {
      map['profile_image_path'] = Variable<String>(profileImagePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  FamilyMemberProfilesCompanion toCompanion(bool nullToAbsent) {
    return FamilyMemberProfilesCompanion(
      id: Value(id),
      firstName: Value(firstName),
      lastName: Value(lastName),
      middleName: middleName == null && nullToAbsent
          ? const Value.absent()
          : Value(middleName),
      dateOfBirth: Value(dateOfBirth),
      gender: Value(gender),
      bloodType: bloodType == null && nullToAbsent
          ? const Value.absent()
          : Value(bloodType),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      emergencyContact: emergencyContact == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContact),
      insuranceInfo: insuranceInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(insuranceInfo),
      profileImagePath: profileImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(profileImagePath),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
    );
  }

  factory FamilyMemberProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyMemberProfile(
      id: serializer.fromJson<String>(json['id']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      middleName: serializer.fromJson<String?>(json['middleName']),
      dateOfBirth: serializer.fromJson<DateTime>(json['dateOfBirth']),
      gender: serializer.fromJson<String>(json['gender']),
      bloodType: serializer.fromJson<String?>(json['bloodType']),
      height: serializer.fromJson<double?>(json['height']),
      weight: serializer.fromJson<double?>(json['weight']),
      emergencyContact: serializer.fromJson<String?>(json['emergencyContact']),
      insuranceInfo: serializer.fromJson<String?>(json['insuranceInfo']),
      profileImagePath: serializer.fromJson<String?>(json['profileImagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'middleName': serializer.toJson<String?>(middleName),
      'dateOfBirth': serializer.toJson<DateTime>(dateOfBirth),
      'gender': serializer.toJson<String>(gender),
      'bloodType': serializer.toJson<String?>(bloodType),
      'height': serializer.toJson<double?>(height),
      'weight': serializer.toJson<double?>(weight),
      'emergencyContact': serializer.toJson<String?>(emergencyContact),
      'insuranceInfo': serializer.toJson<String?>(insuranceInfo),
      'profileImagePath': serializer.toJson<String?>(profileImagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  FamilyMemberProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    Value<String?> middleName = const Value.absent(),
    DateTime? dateOfBirth,
    String? gender,
    Value<String?> bloodType = const Value.absent(),
    Value<double?> height = const Value.absent(),
    Value<double?> weight = const Value.absent(),
    Value<String?> emergencyContact = const Value.absent(),
    Value<String?> insuranceInfo = const Value.absent(),
    Value<String?> profileImagePath = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => FamilyMemberProfile(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    middleName: middleName.present ? middleName.value : this.middleName,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    gender: gender ?? this.gender,
    bloodType: bloodType.present ? bloodType.value : this.bloodType,
    height: height.present ? height.value : this.height,
    weight: weight.present ? weight.value : this.weight,
    emergencyContact: emergencyContact.present
        ? emergencyContact.value
        : this.emergencyContact,
    insuranceInfo: insuranceInfo.present
        ? insuranceInfo.value
        : this.insuranceInfo,
    profileImagePath: profileImagePath.present
        ? profileImagePath.value
        : this.profileImagePath,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
  );
  FamilyMemberProfile copyWithCompanion(FamilyMemberProfilesCompanion data) {
    return FamilyMemberProfile(
      id: data.id.present ? data.id.value : this.id,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      middleName: data.middleName.present
          ? data.middleName.value
          : this.middleName,
      dateOfBirth: data.dateOfBirth.present
          ? data.dateOfBirth.value
          : this.dateOfBirth,
      gender: data.gender.present ? data.gender.value : this.gender,
      bloodType: data.bloodType.present ? data.bloodType.value : this.bloodType,
      height: data.height.present ? data.height.value : this.height,
      weight: data.weight.present ? data.weight.value : this.weight,
      emergencyContact: data.emergencyContact.present
          ? data.emergencyContact.value
          : this.emergencyContact,
      insuranceInfo: data.insuranceInfo.present
          ? data.insuranceInfo.value
          : this.insuranceInfo,
      profileImagePath: data.profileImagePath.present
          ? data.profileImagePath.value
          : this.profileImagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMemberProfile(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('middleName: $middleName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('bloodType: $bloodType, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('insuranceInfo: $insuranceInfo, ')
          ..write('profileImagePath: $profileImagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    firstName,
    lastName,
    middleName,
    dateOfBirth,
    gender,
    bloodType,
    height,
    weight,
    emergencyContact,
    insuranceInfo,
    profileImagePath,
    createdAt,
    updatedAt,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyMemberProfile &&
          other.id == this.id &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.middleName == this.middleName &&
          other.dateOfBirth == this.dateOfBirth &&
          other.gender == this.gender &&
          other.bloodType == this.bloodType &&
          other.height == this.height &&
          other.weight == this.weight &&
          other.emergencyContact == this.emergencyContact &&
          other.insuranceInfo == this.insuranceInfo &&
          other.profileImagePath == this.profileImagePath &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive);
}

class FamilyMemberProfilesCompanion
    extends UpdateCompanion<FamilyMemberProfile> {
  final Value<String> id;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> middleName;
  final Value<DateTime> dateOfBirth;
  final Value<String> gender;
  final Value<String?> bloodType;
  final Value<double?> height;
  final Value<double?> weight;
  final Value<String?> emergencyContact;
  final Value<String?> insuranceInfo;
  final Value<String?> profileImagePath;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const FamilyMemberProfilesCompanion({
    this.id = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.middleName = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.gender = const Value.absent(),
    this.bloodType = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.insuranceInfo = const Value.absent(),
    this.profileImagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyMemberProfilesCompanion.insert({
    required String id,
    required String firstName,
    required String lastName,
    this.middleName = const Value.absent(),
    required DateTime dateOfBirth,
    required String gender,
    this.bloodType = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.insuranceInfo = const Value.absent(),
    this.profileImagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       firstName = Value(firstName),
       lastName = Value(lastName),
       dateOfBirth = Value(dateOfBirth),
       gender = Value(gender);
  static Insertable<FamilyMemberProfile> custom({
    Expression<String>? id,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? middleName,
    Expression<DateTime>? dateOfBirth,
    Expression<String>? gender,
    Expression<String>? bloodType,
    Expression<double>? height,
    Expression<double>? weight,
    Expression<String>? emergencyContact,
    Expression<String>? insuranceInfo,
    Expression<String>? profileImagePath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (middleName != null) 'middle_name': middleName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (bloodType != null) 'blood_type': bloodType,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (insuranceInfo != null) 'insurance_info': insuranceInfo,
      if (profileImagePath != null) 'profile_image_path': profileImagePath,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyMemberProfilesCompanion copyWith({
    Value<String>? id,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String?>? middleName,
    Value<DateTime>? dateOfBirth,
    Value<String>? gender,
    Value<String?>? bloodType,
    Value<double?>? height,
    Value<double?>? weight,
    Value<String?>? emergencyContact,
    Value<String?>? insuranceInfo,
    Value<String?>? profileImagePath,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return FamilyMemberProfilesCompanion(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (middleName.present) {
      map['middle_name'] = Variable<String>(middleName.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (bloodType.present) {
      map['blood_type'] = Variable<String>(bloodType.value);
    }
    if (height.present) {
      map['height'] = Variable<double>(height.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (emergencyContact.present) {
      map['emergency_contact'] = Variable<String>(emergencyContact.value);
    }
    if (insuranceInfo.present) {
      map['insurance_info'] = Variable<String>(insuranceInfo.value);
    }
    if (profileImagePath.present) {
      map['profile_image_path'] = Variable<String>(profileImagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyMemberProfilesCompanion(')
          ..write('id: $id, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('middleName: $middleName, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('gender: $gender, ')
          ..write('bloodType: $bloodType, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('insuranceInfo: $insuranceInfo, ')
          ..write('profileImagePath: $profileImagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicalRecordsTable extends MedicalRecords
    with TableInfo<$MedicalRecordsTable, MedicalRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medical_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicalRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_recordTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicalRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicalRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $MedicalRecordsTable createAlias(String alias) {
    return $MedicalRecordsTable(attachedDatabase, alias);
  }
}

class MedicalRecord extends DataClass implements Insertable<MedicalRecord> {
  final String id;
  final String profileId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  const MedicalRecord({
    required this.id,
    required this.profileId,
    required this.recordType,
    required this.title,
    this.description,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['record_type'] = Variable<String>(recordType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MedicalRecordsCompanion toCompanion(bool nullToAbsent) {
    return MedicalRecordsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      recordType: Value(recordType),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
    );
  }

  factory MedicalRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicalRecord(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'recordType': serializer.toJson<String>(recordType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  MedicalRecord copyWith({
    String? id,
    String? profileId,
    String? recordType,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => MedicalRecord(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    recordType: recordType ?? this.recordType,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    recordDate: recordDate ?? this.recordDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
  );
  MedicalRecord copyWithCompanion(MedicalRecordsCompanion data) {
    return MedicalRecord(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicalRecord(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicalRecord &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.recordType == this.recordType &&
          other.title == this.title &&
          other.description == this.description &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive);
}

class MedicalRecordsCompanion extends UpdateCompanion<MedicalRecord> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> recordType;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  final Value<int> rowid;
  const MedicalRecordsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicalRecordsCompanion.insert({
    required String id,
    required String profileId,
    required String recordType,
    required String title,
    this.description = const Value.absent(),
    required DateTime recordDate,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       recordType = Value(recordType),
       title = Value(title),
       recordDate = Value(recordDate);
  static Insertable<MedicalRecord> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? recordType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (recordType != null) 'record_type': recordType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicalRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? recordType,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? recordDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return MedicalRecordsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicalRecordsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrescriptionsTable extends Prescriptions
    with TableInfo<$PrescriptionsTable, Prescription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrescriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('prescription'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _medicationNameMeta = const VerificationMeta(
    'medicationName',
  );
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
    'medication_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prescribingDoctorMeta = const VerificationMeta(
    'prescribingDoctor',
  );
  @override
  late final GeneratedColumn<String> prescribingDoctor =
      GeneratedColumn<String>(
        'prescribing_doctor',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _pharmacyMeta = const VerificationMeta(
    'pharmacy',
  );
  @override
  late final GeneratedColumn<String> pharmacy = GeneratedColumn<String>(
    'pharmacy',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refillsRemainingMeta = const VerificationMeta(
    'refillsRemaining',
  );
  @override
  late final GeneratedColumn<int> refillsRemaining = GeneratedColumn<int>(
    'refills_remaining',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrescriptionActiveMeta =
      const VerificationMeta('isPrescriptionActive');
  @override
  late final GeneratedColumn<bool> isPrescriptionActive = GeneratedColumn<bool>(
    'is_prescription_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_prescription_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    medicationName,
    dosage,
    frequency,
    instructions,
    prescribingDoctor,
    pharmacy,
    startDate,
    endDate,
    refillsRemaining,
    isPrescriptionActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prescriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Prescription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('medication_name')) {
      context.handle(
        _medicationNameMeta,
        medicationName.isAcceptableOrUnknown(
          data['medication_name']!,
          _medicationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationNameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    }
    if (data.containsKey('prescribing_doctor')) {
      context.handle(
        _prescribingDoctorMeta,
        prescribingDoctor.isAcceptableOrUnknown(
          data['prescribing_doctor']!,
          _prescribingDoctorMeta,
        ),
      );
    }
    if (data.containsKey('pharmacy')) {
      context.handle(
        _pharmacyMeta,
        pharmacy.isAcceptableOrUnknown(data['pharmacy']!, _pharmacyMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('refills_remaining')) {
      context.handle(
        _refillsRemainingMeta,
        refillsRemaining.isAcceptableOrUnknown(
          data['refills_remaining']!,
          _refillsRemainingMeta,
        ),
      );
    }
    if (data.containsKey('is_prescription_active')) {
      context.handle(
        _isPrescriptionActiveMeta,
        isPrescriptionActive.isAcceptableOrUnknown(
          data['is_prescription_active']!,
          _isPrescriptionActiveMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Prescription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Prescription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      medicationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_name'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      ),
      prescribingDoctor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescribing_doctor'],
      ),
      pharmacy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pharmacy'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      refillsRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refills_remaining'],
      ),
      isPrescriptionActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_prescription_active'],
      )!,
    );
  }

  @override
  $PrescriptionsTable createAlias(String alias) {
    return $PrescriptionsTable(attachedDatabase, alias);
  }
}

class Prescription extends DataClass implements Insertable<Prescription> {
  final String id;
  final String profileId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String? instructions;
  final String? prescribingDoctor;
  final String? pharmacy;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? refillsRemaining;
  final bool isPrescriptionActive;
  const Prescription({
    required this.id,
    required this.profileId,
    required this.recordType,
    required this.title,
    this.description,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    this.instructions,
    this.prescribingDoctor,
    this.pharmacy,
    this.startDate,
    this.endDate,
    this.refillsRemaining,
    required this.isPrescriptionActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['record_type'] = Variable<String>(recordType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    map['medication_name'] = Variable<String>(medicationName);
    map['dosage'] = Variable<String>(dosage);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    if (!nullToAbsent || prescribingDoctor != null) {
      map['prescribing_doctor'] = Variable<String>(prescribingDoctor);
    }
    if (!nullToAbsent || pharmacy != null) {
      map['pharmacy'] = Variable<String>(pharmacy);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || refillsRemaining != null) {
      map['refills_remaining'] = Variable<int>(refillsRemaining);
    }
    map['is_prescription_active'] = Variable<bool>(isPrescriptionActive);
    return map;
  }

  PrescriptionsCompanion toCompanion(bool nullToAbsent) {
    return PrescriptionsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      recordType: Value(recordType),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      medicationName: Value(medicationName),
      dosage: Value(dosage),
      frequency: Value(frequency),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
      prescribingDoctor: prescribingDoctor == null && nullToAbsent
          ? const Value.absent()
          : Value(prescribingDoctor),
      pharmacy: pharmacy == null && nullToAbsent
          ? const Value.absent()
          : Value(pharmacy),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      refillsRemaining: refillsRemaining == null && nullToAbsent
          ? const Value.absent()
          : Value(refillsRemaining),
      isPrescriptionActive: Value(isPrescriptionActive),
    );
  }

  factory Prescription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Prescription(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      dosage: serializer.fromJson<String>(json['dosage']),
      frequency: serializer.fromJson<String>(json['frequency']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      prescribingDoctor: serializer.fromJson<String?>(
        json['prescribingDoctor'],
      ),
      pharmacy: serializer.fromJson<String?>(json['pharmacy']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      refillsRemaining: serializer.fromJson<int?>(json['refillsRemaining']),
      isPrescriptionActive: serializer.fromJson<bool>(
        json['isPrescriptionActive'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'recordType': serializer.toJson<String>(recordType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'medicationName': serializer.toJson<String>(medicationName),
      'dosage': serializer.toJson<String>(dosage),
      'frequency': serializer.toJson<String>(frequency),
      'instructions': serializer.toJson<String?>(instructions),
      'prescribingDoctor': serializer.toJson<String?>(prescribingDoctor),
      'pharmacy': serializer.toJson<String?>(pharmacy),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'refillsRemaining': serializer.toJson<int?>(refillsRemaining),
      'isPrescriptionActive': serializer.toJson<bool>(isPrescriptionActive),
    };
  }

  Prescription copyWith({
    String? id,
    String? profileId,
    String? recordType,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? medicationName,
    String? dosage,
    String? frequency,
    Value<String?> instructions = const Value.absent(),
    Value<String?> prescribingDoctor = const Value.absent(),
    Value<String?> pharmacy = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    Value<int?> refillsRemaining = const Value.absent(),
    bool? isPrescriptionActive,
  }) => Prescription(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    recordType: recordType ?? this.recordType,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    recordDate: recordDate ?? this.recordDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    medicationName: medicationName ?? this.medicationName,
    dosage: dosage ?? this.dosage,
    frequency: frequency ?? this.frequency,
    instructions: instructions.present ? instructions.value : this.instructions,
    prescribingDoctor: prescribingDoctor.present
        ? prescribingDoctor.value
        : this.prescribingDoctor,
    pharmacy: pharmacy.present ? pharmacy.value : this.pharmacy,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    refillsRemaining: refillsRemaining.present
        ? refillsRemaining.value
        : this.refillsRemaining,
    isPrescriptionActive: isPrescriptionActive ?? this.isPrescriptionActive,
  );
  Prescription copyWithCompanion(PrescriptionsCompanion data) {
    return Prescription(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      prescribingDoctor: data.prescribingDoctor.present
          ? data.prescribingDoctor.value
          : this.prescribingDoctor,
      pharmacy: data.pharmacy.present ? data.pharmacy.value : this.pharmacy,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      refillsRemaining: data.refillsRemaining.present
          ? data.refillsRemaining.value
          : this.refillsRemaining,
      isPrescriptionActive: data.isPrescriptionActive.present
          ? data.isPrescriptionActive.value
          : this.isPrescriptionActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Prescription(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('medicationName: $medicationName, ')
          ..write('dosage: $dosage, ')
          ..write('frequency: $frequency, ')
          ..write('instructions: $instructions, ')
          ..write('prescribingDoctor: $prescribingDoctor, ')
          ..write('pharmacy: $pharmacy, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('refillsRemaining: $refillsRemaining, ')
          ..write('isPrescriptionActive: $isPrescriptionActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    medicationName,
    dosage,
    frequency,
    instructions,
    prescribingDoctor,
    pharmacy,
    startDate,
    endDate,
    refillsRemaining,
    isPrescriptionActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Prescription &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.recordType == this.recordType &&
          other.title == this.title &&
          other.description == this.description &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive &&
          other.medicationName == this.medicationName &&
          other.dosage == this.dosage &&
          other.frequency == this.frequency &&
          other.instructions == this.instructions &&
          other.prescribingDoctor == this.prescribingDoctor &&
          other.pharmacy == this.pharmacy &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.refillsRemaining == this.refillsRemaining &&
          other.isPrescriptionActive == this.isPrescriptionActive);
}

class PrescriptionsCompanion extends UpdateCompanion<Prescription> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> recordType;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  final Value<String> medicationName;
  final Value<String> dosage;
  final Value<String> frequency;
  final Value<String?> instructions;
  final Value<String?> prescribingDoctor;
  final Value<String?> pharmacy;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<int?> refillsRemaining;
  final Value<bool> isPrescriptionActive;
  final Value<int> rowid;
  const PrescriptionsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.dosage = const Value.absent(),
    this.frequency = const Value.absent(),
    this.instructions = const Value.absent(),
    this.prescribingDoctor = const Value.absent(),
    this.pharmacy = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.refillsRemaining = const Value.absent(),
    this.isPrescriptionActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrescriptionsCompanion.insert({
    required String id,
    required String profileId,
    this.recordType = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime recordDate,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    required String medicationName,
    required String dosage,
    required String frequency,
    this.instructions = const Value.absent(),
    this.prescribingDoctor = const Value.absent(),
    this.pharmacy = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.refillsRemaining = const Value.absent(),
    this.isPrescriptionActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       title = Value(title),
       recordDate = Value(recordDate),
       medicationName = Value(medicationName),
       dosage = Value(dosage),
       frequency = Value(frequency);
  static Insertable<Prescription> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? recordType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
    Expression<String>? medicationName,
    Expression<String>? dosage,
    Expression<String>? frequency,
    Expression<String>? instructions,
    Expression<String>? prescribingDoctor,
    Expression<String>? pharmacy,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? refillsRemaining,
    Expression<bool>? isPrescriptionActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (recordType != null) 'record_type': recordType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (medicationName != null) 'medication_name': medicationName,
      if (dosage != null) 'dosage': dosage,
      if (frequency != null) 'frequency': frequency,
      if (instructions != null) 'instructions': instructions,
      if (prescribingDoctor != null) 'prescribing_doctor': prescribingDoctor,
      if (pharmacy != null) 'pharmacy': pharmacy,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (refillsRemaining != null) 'refills_remaining': refillsRemaining,
      if (isPrescriptionActive != null)
        'is_prescription_active': isPrescriptionActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrescriptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? recordType,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? recordDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isActive,
    Value<String>? medicationName,
    Value<String>? dosage,
    Value<String>? frequency,
    Value<String?>? instructions,
    Value<String?>? prescribingDoctor,
    Value<String?>? pharmacy,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<int?>? refillsRemaining,
    Value<bool>? isPrescriptionActive,
    Value<int>? rowid,
  }) {
    return PrescriptionsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      instructions: instructions ?? this.instructions,
      prescribingDoctor: prescribingDoctor ?? this.prescribingDoctor,
      pharmacy: pharmacy ?? this.pharmacy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      refillsRemaining: refillsRemaining ?? this.refillsRemaining,
      isPrescriptionActive: isPrescriptionActive ?? this.isPrescriptionActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (prescribingDoctor.present) {
      map['prescribing_doctor'] = Variable<String>(prescribingDoctor.value);
    }
    if (pharmacy.present) {
      map['pharmacy'] = Variable<String>(pharmacy.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (refillsRemaining.present) {
      map['refills_remaining'] = Variable<int>(refillsRemaining.value);
    }
    if (isPrescriptionActive.present) {
      map['is_prescription_active'] = Variable<bool>(
        isPrescriptionActive.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrescriptionsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('medicationName: $medicationName, ')
          ..write('dosage: $dosage, ')
          ..write('frequency: $frequency, ')
          ..write('instructions: $instructions, ')
          ..write('prescribingDoctor: $prescribingDoctor, ')
          ..write('pharmacy: $pharmacy, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('refillsRemaining: $refillsRemaining, ')
          ..write('isPrescriptionActive: $isPrescriptionActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LabReportsTable extends LabReports
    with TableInfo<$LabReportsTable, LabReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('lab_report'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _testNameMeta = const VerificationMeta(
    'testName',
  );
  @override
  late final GeneratedColumn<String> testName = GeneratedColumn<String>(
    'test_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _testResultsMeta = const VerificationMeta(
    'testResults',
  );
  @override
  late final GeneratedColumn<String> testResults = GeneratedColumn<String>(
    'test_results',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceRangeMeta = const VerificationMeta(
    'referenceRange',
  );
  @override
  late final GeneratedColumn<String> referenceRange = GeneratedColumn<String>(
    'reference_range',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderingPhysicianMeta = const VerificationMeta(
    'orderingPhysician',
  );
  @override
  late final GeneratedColumn<String> orderingPhysician =
      GeneratedColumn<String>(
        'ordering_physician',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _labFacilityMeta = const VerificationMeta(
    'labFacility',
  );
  @override
  late final GeneratedColumn<String> labFacility = GeneratedColumn<String>(
    'lab_facility',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _testStatusMeta = const VerificationMeta(
    'testStatus',
  );
  @override
  late final GeneratedColumn<String> testStatus = GeneratedColumn<String>(
    'test_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionDateMeta = const VerificationMeta(
    'collectionDate',
  );
  @override
  late final GeneratedColumn<DateTime> collectionDate =
      GeneratedColumn<DateTime>(
        'collection_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isCriticalMeta = const VerificationMeta(
    'isCritical',
  );
  @override
  late final GeneratedColumn<bool> isCritical = GeneratedColumn<bool>(
    'is_critical',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_critical" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    testName,
    testResults,
    referenceRange,
    orderingPhysician,
    labFacility,
    testStatus,
    collectionDate,
    isCritical,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lab_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<LabReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('test_name')) {
      context.handle(
        _testNameMeta,
        testName.isAcceptableOrUnknown(data['test_name']!, _testNameMeta),
      );
    } else if (isInserting) {
      context.missing(_testNameMeta);
    }
    if (data.containsKey('test_results')) {
      context.handle(
        _testResultsMeta,
        testResults.isAcceptableOrUnknown(
          data['test_results']!,
          _testResultsMeta,
        ),
      );
    }
    if (data.containsKey('reference_range')) {
      context.handle(
        _referenceRangeMeta,
        referenceRange.isAcceptableOrUnknown(
          data['reference_range']!,
          _referenceRangeMeta,
        ),
      );
    }
    if (data.containsKey('ordering_physician')) {
      context.handle(
        _orderingPhysicianMeta,
        orderingPhysician.isAcceptableOrUnknown(
          data['ordering_physician']!,
          _orderingPhysicianMeta,
        ),
      );
    }
    if (data.containsKey('lab_facility')) {
      context.handle(
        _labFacilityMeta,
        labFacility.isAcceptableOrUnknown(
          data['lab_facility']!,
          _labFacilityMeta,
        ),
      );
    }
    if (data.containsKey('test_status')) {
      context.handle(
        _testStatusMeta,
        testStatus.isAcceptableOrUnknown(data['test_status']!, _testStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_testStatusMeta);
    }
    if (data.containsKey('collection_date')) {
      context.handle(
        _collectionDateMeta,
        collectionDate.isAcceptableOrUnknown(
          data['collection_date']!,
          _collectionDateMeta,
        ),
      );
    }
    if (data.containsKey('is_critical')) {
      context.handle(
        _isCriticalMeta,
        isCritical.isAcceptableOrUnknown(data['is_critical']!, _isCriticalMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LabReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LabReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      testName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}test_name'],
      )!,
      testResults: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}test_results'],
      ),
      referenceRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_range'],
      ),
      orderingPhysician: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ordering_physician'],
      ),
      labFacility: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lab_facility'],
      ),
      testStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}test_status'],
      )!,
      collectionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}collection_date'],
      ),
      isCritical: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_critical'],
      )!,
    );
  }

  @override
  $LabReportsTable createAlias(String alias) {
    return $LabReportsTable(attachedDatabase, alias);
  }
}

class LabReport extends DataClass implements Insertable<LabReport> {
  final String id;
  final String profileId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String testName;
  final String? testResults;
  final String? referenceRange;
  final String? orderingPhysician;
  final String? labFacility;
  final String testStatus;
  final DateTime? collectionDate;
  final bool isCritical;
  const LabReport({
    required this.id,
    required this.profileId,
    required this.recordType,
    required this.title,
    this.description,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.testName,
    this.testResults,
    this.referenceRange,
    this.orderingPhysician,
    this.labFacility,
    required this.testStatus,
    this.collectionDate,
    required this.isCritical,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['record_type'] = Variable<String>(recordType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    map['test_name'] = Variable<String>(testName);
    if (!nullToAbsent || testResults != null) {
      map['test_results'] = Variable<String>(testResults);
    }
    if (!nullToAbsent || referenceRange != null) {
      map['reference_range'] = Variable<String>(referenceRange);
    }
    if (!nullToAbsent || orderingPhysician != null) {
      map['ordering_physician'] = Variable<String>(orderingPhysician);
    }
    if (!nullToAbsent || labFacility != null) {
      map['lab_facility'] = Variable<String>(labFacility);
    }
    map['test_status'] = Variable<String>(testStatus);
    if (!nullToAbsent || collectionDate != null) {
      map['collection_date'] = Variable<DateTime>(collectionDate);
    }
    map['is_critical'] = Variable<bool>(isCritical);
    return map;
  }

  LabReportsCompanion toCompanion(bool nullToAbsent) {
    return LabReportsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      recordType: Value(recordType),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      testName: Value(testName),
      testResults: testResults == null && nullToAbsent
          ? const Value.absent()
          : Value(testResults),
      referenceRange: referenceRange == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceRange),
      orderingPhysician: orderingPhysician == null && nullToAbsent
          ? const Value.absent()
          : Value(orderingPhysician),
      labFacility: labFacility == null && nullToAbsent
          ? const Value.absent()
          : Value(labFacility),
      testStatus: Value(testStatus),
      collectionDate: collectionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(collectionDate),
      isCritical: Value(isCritical),
    );
  }

  factory LabReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LabReport(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      testName: serializer.fromJson<String>(json['testName']),
      testResults: serializer.fromJson<String?>(json['testResults']),
      referenceRange: serializer.fromJson<String?>(json['referenceRange']),
      orderingPhysician: serializer.fromJson<String?>(
        json['orderingPhysician'],
      ),
      labFacility: serializer.fromJson<String?>(json['labFacility']),
      testStatus: serializer.fromJson<String>(json['testStatus']),
      collectionDate: serializer.fromJson<DateTime?>(json['collectionDate']),
      isCritical: serializer.fromJson<bool>(json['isCritical']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'recordType': serializer.toJson<String>(recordType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'testName': serializer.toJson<String>(testName),
      'testResults': serializer.toJson<String?>(testResults),
      'referenceRange': serializer.toJson<String?>(referenceRange),
      'orderingPhysician': serializer.toJson<String?>(orderingPhysician),
      'labFacility': serializer.toJson<String?>(labFacility),
      'testStatus': serializer.toJson<String>(testStatus),
      'collectionDate': serializer.toJson<DateTime?>(collectionDate),
      'isCritical': serializer.toJson<bool>(isCritical),
    };
  }

  LabReport copyWith({
    String? id,
    String? profileId,
    String? recordType,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? testName,
    Value<String?> testResults = const Value.absent(),
    Value<String?> referenceRange = const Value.absent(),
    Value<String?> orderingPhysician = const Value.absent(),
    Value<String?> labFacility = const Value.absent(),
    String? testStatus,
    Value<DateTime?> collectionDate = const Value.absent(),
    bool? isCritical,
  }) => LabReport(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    recordType: recordType ?? this.recordType,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    recordDate: recordDate ?? this.recordDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    testName: testName ?? this.testName,
    testResults: testResults.present ? testResults.value : this.testResults,
    referenceRange: referenceRange.present
        ? referenceRange.value
        : this.referenceRange,
    orderingPhysician: orderingPhysician.present
        ? orderingPhysician.value
        : this.orderingPhysician,
    labFacility: labFacility.present ? labFacility.value : this.labFacility,
    testStatus: testStatus ?? this.testStatus,
    collectionDate: collectionDate.present
        ? collectionDate.value
        : this.collectionDate,
    isCritical: isCritical ?? this.isCritical,
  );
  LabReport copyWithCompanion(LabReportsCompanion data) {
    return LabReport(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      testName: data.testName.present ? data.testName.value : this.testName,
      testResults: data.testResults.present
          ? data.testResults.value
          : this.testResults,
      referenceRange: data.referenceRange.present
          ? data.referenceRange.value
          : this.referenceRange,
      orderingPhysician: data.orderingPhysician.present
          ? data.orderingPhysician.value
          : this.orderingPhysician,
      labFacility: data.labFacility.present
          ? data.labFacility.value
          : this.labFacility,
      testStatus: data.testStatus.present
          ? data.testStatus.value
          : this.testStatus,
      collectionDate: data.collectionDate.present
          ? data.collectionDate.value
          : this.collectionDate,
      isCritical: data.isCritical.present
          ? data.isCritical.value
          : this.isCritical,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LabReport(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('testName: $testName, ')
          ..write('testResults: $testResults, ')
          ..write('referenceRange: $referenceRange, ')
          ..write('orderingPhysician: $orderingPhysician, ')
          ..write('labFacility: $labFacility, ')
          ..write('testStatus: $testStatus, ')
          ..write('collectionDate: $collectionDate, ')
          ..write('isCritical: $isCritical')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    testName,
    testResults,
    referenceRange,
    orderingPhysician,
    labFacility,
    testStatus,
    collectionDate,
    isCritical,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LabReport &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.recordType == this.recordType &&
          other.title == this.title &&
          other.description == this.description &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive &&
          other.testName == this.testName &&
          other.testResults == this.testResults &&
          other.referenceRange == this.referenceRange &&
          other.orderingPhysician == this.orderingPhysician &&
          other.labFacility == this.labFacility &&
          other.testStatus == this.testStatus &&
          other.collectionDate == this.collectionDate &&
          other.isCritical == this.isCritical);
}

class LabReportsCompanion extends UpdateCompanion<LabReport> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> recordType;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  final Value<String> testName;
  final Value<String?> testResults;
  final Value<String?> referenceRange;
  final Value<String?> orderingPhysician;
  final Value<String?> labFacility;
  final Value<String> testStatus;
  final Value<DateTime?> collectionDate;
  final Value<bool> isCritical;
  final Value<int> rowid;
  const LabReportsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.testName = const Value.absent(),
    this.testResults = const Value.absent(),
    this.referenceRange = const Value.absent(),
    this.orderingPhysician = const Value.absent(),
    this.labFacility = const Value.absent(),
    this.testStatus = const Value.absent(),
    this.collectionDate = const Value.absent(),
    this.isCritical = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LabReportsCompanion.insert({
    required String id,
    required String profileId,
    this.recordType = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime recordDate,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    required String testName,
    this.testResults = const Value.absent(),
    this.referenceRange = const Value.absent(),
    this.orderingPhysician = const Value.absent(),
    this.labFacility = const Value.absent(),
    required String testStatus,
    this.collectionDate = const Value.absent(),
    this.isCritical = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       title = Value(title),
       recordDate = Value(recordDate),
       testName = Value(testName),
       testStatus = Value(testStatus);
  static Insertable<LabReport> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? recordType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
    Expression<String>? testName,
    Expression<String>? testResults,
    Expression<String>? referenceRange,
    Expression<String>? orderingPhysician,
    Expression<String>? labFacility,
    Expression<String>? testStatus,
    Expression<DateTime>? collectionDate,
    Expression<bool>? isCritical,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (recordType != null) 'record_type': recordType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (testName != null) 'test_name': testName,
      if (testResults != null) 'test_results': testResults,
      if (referenceRange != null) 'reference_range': referenceRange,
      if (orderingPhysician != null) 'ordering_physician': orderingPhysician,
      if (labFacility != null) 'lab_facility': labFacility,
      if (testStatus != null) 'test_status': testStatus,
      if (collectionDate != null) 'collection_date': collectionDate,
      if (isCritical != null) 'is_critical': isCritical,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LabReportsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? recordType,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? recordDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isActive,
    Value<String>? testName,
    Value<String?>? testResults,
    Value<String?>? referenceRange,
    Value<String?>? orderingPhysician,
    Value<String?>? labFacility,
    Value<String>? testStatus,
    Value<DateTime?>? collectionDate,
    Value<bool>? isCritical,
    Value<int>? rowid,
  }) {
    return LabReportsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      testName: testName ?? this.testName,
      testResults: testResults ?? this.testResults,
      referenceRange: referenceRange ?? this.referenceRange,
      orderingPhysician: orderingPhysician ?? this.orderingPhysician,
      labFacility: labFacility ?? this.labFacility,
      testStatus: testStatus ?? this.testStatus,
      collectionDate: collectionDate ?? this.collectionDate,
      isCritical: isCritical ?? this.isCritical,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (testName.present) {
      map['test_name'] = Variable<String>(testName.value);
    }
    if (testResults.present) {
      map['test_results'] = Variable<String>(testResults.value);
    }
    if (referenceRange.present) {
      map['reference_range'] = Variable<String>(referenceRange.value);
    }
    if (orderingPhysician.present) {
      map['ordering_physician'] = Variable<String>(orderingPhysician.value);
    }
    if (labFacility.present) {
      map['lab_facility'] = Variable<String>(labFacility.value);
    }
    if (testStatus.present) {
      map['test_status'] = Variable<String>(testStatus.value);
    }
    if (collectionDate.present) {
      map['collection_date'] = Variable<DateTime>(collectionDate.value);
    }
    if (isCritical.present) {
      map['is_critical'] = Variable<bool>(isCritical.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabReportsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('testName: $testName, ')
          ..write('testResults: $testResults, ')
          ..write('referenceRange: $referenceRange, ')
          ..write('orderingPhysician: $orderingPhysician, ')
          ..write('labFacility: $labFacility, ')
          ..write('testStatus: $testStatus, ')
          ..write('collectionDate: $collectionDate, ')
          ..write('isCritical: $isCritical, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications
    with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('medication'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _medicationNameMeta = const VerificationMeta(
    'medicationName',
  );
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
    'medication_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduleMeta = const VerificationMeta(
    'schedule',
  );
  @override
  late final GeneratedColumn<String> schedule = GeneratedColumn<String>(
    'schedule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _pillCountMeta = const VerificationMeta(
    'pillCount',
  );
  @override
  late final GeneratedColumn<int> pillCount = GeneratedColumn<int>(
    'pill_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    medicationName,
    dosage,
    frequency,
    schedule,
    startDate,
    endDate,
    instructions,
    reminderEnabled,
    pillCount,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('medication_name')) {
      context.handle(
        _medicationNameMeta,
        medicationName.isAcceptableOrUnknown(
          data['medication_name']!,
          _medicationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationNameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('schedule')) {
      context.handle(
        _scheduleMeta,
        schedule.isAcceptableOrUnknown(data['schedule']!, _scheduleMeta),
      );
    } else if (isInserting) {
      context.missing(_scheduleMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('pill_count')) {
      context.handle(
        _pillCountMeta,
        pillCount.isAcceptableOrUnknown(data['pill_count']!, _pillCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      medicationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_name'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      schedule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      pillCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pill_count'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final String id;
  final String profileId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String schedule;
  final DateTime startDate;
  final DateTime? endDate;
  final String? instructions;
  final bool reminderEnabled;
  final int? pillCount;
  final String status;
  const Medication({
    required this.id,
    required this.profileId,
    required this.recordType,
    required this.title,
    this.description,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.schedule,
    required this.startDate,
    this.endDate,
    this.instructions,
    required this.reminderEnabled,
    this.pillCount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['record_type'] = Variable<String>(recordType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    map['medication_name'] = Variable<String>(medicationName);
    map['dosage'] = Variable<String>(dosage);
    map['frequency'] = Variable<String>(frequency);
    map['schedule'] = Variable<String>(schedule);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || instructions != null) {
      map['instructions'] = Variable<String>(instructions);
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    if (!nullToAbsent || pillCount != null) {
      map['pill_count'] = Variable<int>(pillCount);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      recordType: Value(recordType),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      medicationName: Value(medicationName),
      dosage: Value(dosage),
      frequency: Value(frequency),
      schedule: Value(schedule),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      instructions: instructions == null && nullToAbsent
          ? const Value.absent()
          : Value(instructions),
      reminderEnabled: Value(reminderEnabled),
      pillCount: pillCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pillCount),
      status: Value(status),
    );
  }

  factory Medication.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      dosage: serializer.fromJson<String>(json['dosage']),
      frequency: serializer.fromJson<String>(json['frequency']),
      schedule: serializer.fromJson<String>(json['schedule']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      instructions: serializer.fromJson<String?>(json['instructions']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
      pillCount: serializer.fromJson<int?>(json['pillCount']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'recordType': serializer.toJson<String>(recordType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'medicationName': serializer.toJson<String>(medicationName),
      'dosage': serializer.toJson<String>(dosage),
      'frequency': serializer.toJson<String>(frequency),
      'schedule': serializer.toJson<String>(schedule),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'instructions': serializer.toJson<String?>(instructions),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
      'pillCount': serializer.toJson<int?>(pillCount),
      'status': serializer.toJson<String>(status),
    };
  }

  Medication copyWith({
    String? id,
    String? profileId,
    String? recordType,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? medicationName,
    String? dosage,
    String? frequency,
    String? schedule,
    DateTime? startDate,
    Value<DateTime?> endDate = const Value.absent(),
    Value<String?> instructions = const Value.absent(),
    bool? reminderEnabled,
    Value<int?> pillCount = const Value.absent(),
    String? status,
  }) => Medication(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    recordType: recordType ?? this.recordType,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    recordDate: recordDate ?? this.recordDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    medicationName: medicationName ?? this.medicationName,
    dosage: dosage ?? this.dosage,
    frequency: frequency ?? this.frequency,
    schedule: schedule ?? this.schedule,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    instructions: instructions.present ? instructions.value : this.instructions,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    pillCount: pillCount.present ? pillCount.value : this.pillCount,
    status: status ?? this.status,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      schedule: data.schedule.present ? data.schedule.value : this.schedule,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      pillCount: data.pillCount.present ? data.pillCount.value : this.pillCount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('medicationName: $medicationName, ')
          ..write('dosage: $dosage, ')
          ..write('frequency: $frequency, ')
          ..write('schedule: $schedule, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('instructions: $instructions, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('pillCount: $pillCount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    medicationName,
    dosage,
    frequency,
    schedule,
    startDate,
    endDate,
    instructions,
    reminderEnabled,
    pillCount,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.recordType == this.recordType &&
          other.title == this.title &&
          other.description == this.description &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive &&
          other.medicationName == this.medicationName &&
          other.dosage == this.dosage &&
          other.frequency == this.frequency &&
          other.schedule == this.schedule &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.instructions == this.instructions &&
          other.reminderEnabled == this.reminderEnabled &&
          other.pillCount == this.pillCount &&
          other.status == this.status);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> recordType;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  final Value<String> medicationName;
  final Value<String> dosage;
  final Value<String> frequency;
  final Value<String> schedule;
  final Value<DateTime> startDate;
  final Value<DateTime?> endDate;
  final Value<String?> instructions;
  final Value<bool> reminderEnabled;
  final Value<int?> pillCount;
  final Value<String> status;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.dosage = const Value.absent(),
    this.frequency = const Value.absent(),
    this.schedule = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.instructions = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.pillCount = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    required String id,
    required String profileId,
    this.recordType = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime recordDate,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    required String medicationName,
    required String dosage,
    required String frequency,
    required String schedule,
    required DateTime startDate,
    this.endDate = const Value.absent(),
    this.instructions = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.pillCount = const Value.absent(),
    required String status,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       title = Value(title),
       recordDate = Value(recordDate),
       medicationName = Value(medicationName),
       dosage = Value(dosage),
       frequency = Value(frequency),
       schedule = Value(schedule),
       startDate = Value(startDate),
       status = Value(status);
  static Insertable<Medication> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? recordType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
    Expression<String>? medicationName,
    Expression<String>? dosage,
    Expression<String>? frequency,
    Expression<String>? schedule,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? instructions,
    Expression<bool>? reminderEnabled,
    Expression<int>? pillCount,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (recordType != null) 'record_type': recordType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (medicationName != null) 'medication_name': medicationName,
      if (dosage != null) 'dosage': dosage,
      if (frequency != null) 'frequency': frequency,
      if (schedule != null) 'schedule': schedule,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (instructions != null) 'instructions': instructions,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (pillCount != null) 'pill_count': pillCount,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? recordType,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? recordDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isActive,
    Value<String>? medicationName,
    Value<String>? dosage,
    Value<String>? frequency,
    Value<String>? schedule,
    Value<DateTime>? startDate,
    Value<DateTime?>? endDate,
    Value<String?>? instructions,
    Value<bool>? reminderEnabled,
    Value<int?>? pillCount,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      schedule: schedule ?? this.schedule,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      instructions: instructions ?? this.instructions,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      pillCount: pillCount ?? this.pillCount,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (schedule.present) {
      map['schedule'] = Variable<String>(schedule.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (pillCount.present) {
      map['pill_count'] = Variable<int>(pillCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('medicationName: $medicationName, ')
          ..write('dosage: $dosage, ')
          ..write('frequency: $frequency, ')
          ..write('schedule: $schedule, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('instructions: $instructions, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('pillCount: $pillCount, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VaccinationsTable extends Vaccinations
    with TableInfo<$VaccinationsTable, Vaccination> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaccinationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('vaccination'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _vaccineNameMeta = const VerificationMeta(
    'vaccineName',
  );
  @override
  late final GeneratedColumn<String> vaccineName = GeneratedColumn<String>(
    'vaccine_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _administrationDateMeta =
      const VerificationMeta('administrationDate');
  @override
  late final GeneratedColumn<DateTime> administrationDate =
      GeneratedColumn<DateTime>(
        'administration_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _administeredByMeta = const VerificationMeta(
    'administeredBy',
  );
  @override
  late final GeneratedColumn<String> administeredBy = GeneratedColumn<String>(
    'administered_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteMeta = const VerificationMeta('site');
  @override
  late final GeneratedColumn<String> site = GeneratedColumn<String>(
    'site',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doseNumberMeta = const VerificationMeta(
    'doseNumber',
  );
  @override
  late final GeneratedColumn<int> doseNumber = GeneratedColumn<int>(
    'dose_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    vaccineName,
    manufacturer,
    batchNumber,
    administrationDate,
    administeredBy,
    site,
    nextDueDate,
    doseNumber,
    isComplete,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vaccinations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vaccination> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('vaccine_name')) {
      context.handle(
        _vaccineNameMeta,
        vaccineName.isAcceptableOrUnknown(
          data['vaccine_name']!,
          _vaccineNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaccineNameMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    }
    if (data.containsKey('administration_date')) {
      context.handle(
        _administrationDateMeta,
        administrationDate.isAcceptableOrUnknown(
          data['administration_date']!,
          _administrationDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_administrationDateMeta);
    }
    if (data.containsKey('administered_by')) {
      context.handle(
        _administeredByMeta,
        administeredBy.isAcceptableOrUnknown(
          data['administered_by']!,
          _administeredByMeta,
        ),
      );
    }
    if (data.containsKey('site')) {
      context.handle(
        _siteMeta,
        site.isAcceptableOrUnknown(data['site']!, _siteMeta),
      );
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    }
    if (data.containsKey('dose_number')) {
      context.handle(
        _doseNumberMeta,
        doseNumber.isAcceptableOrUnknown(data['dose_number']!, _doseNumberMeta),
      );
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vaccination map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vaccination(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      vaccineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vaccine_name'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      ),
      administrationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}administration_date'],
      )!,
      administeredBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}administered_by'],
      ),
      site: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site'],
      ),
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_date'],
      ),
      doseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dose_number'],
      ),
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
    );
  }

  @override
  $VaccinationsTable createAlias(String alias) {
    return $VaccinationsTable(attachedDatabase, alias);
  }
}

class Vaccination extends DataClass implements Insertable<Vaccination> {
  final String id;
  final String profileId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String vaccineName;
  final String? manufacturer;
  final String? batchNumber;
  final DateTime administrationDate;
  final String? administeredBy;
  final String? site;
  final DateTime? nextDueDate;
  final int? doseNumber;
  final bool isComplete;
  const Vaccination({
    required this.id,
    required this.profileId,
    required this.recordType,
    required this.title,
    this.description,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.vaccineName,
    this.manufacturer,
    this.batchNumber,
    required this.administrationDate,
    this.administeredBy,
    this.site,
    this.nextDueDate,
    this.doseNumber,
    required this.isComplete,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['record_type'] = Variable<String>(recordType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    map['vaccine_name'] = Variable<String>(vaccineName);
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || batchNumber != null) {
      map['batch_number'] = Variable<String>(batchNumber);
    }
    map['administration_date'] = Variable<DateTime>(administrationDate);
    if (!nullToAbsent || administeredBy != null) {
      map['administered_by'] = Variable<String>(administeredBy);
    }
    if (!nullToAbsent || site != null) {
      map['site'] = Variable<String>(site);
    }
    if (!nullToAbsent || nextDueDate != null) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate);
    }
    if (!nullToAbsent || doseNumber != null) {
      map['dose_number'] = Variable<int>(doseNumber);
    }
    map['is_complete'] = Variable<bool>(isComplete);
    return map;
  }

  VaccinationsCompanion toCompanion(bool nullToAbsent) {
    return VaccinationsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      recordType: Value(recordType),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      vaccineName: Value(vaccineName),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      batchNumber: batchNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(batchNumber),
      administrationDate: Value(administrationDate),
      administeredBy: administeredBy == null && nullToAbsent
          ? const Value.absent()
          : Value(administeredBy),
      site: site == null && nullToAbsent ? const Value.absent() : Value(site),
      nextDueDate: nextDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueDate),
      doseNumber: doseNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(doseNumber),
      isComplete: Value(isComplete),
    );
  }

  factory Vaccination.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vaccination(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      vaccineName: serializer.fromJson<String>(json['vaccineName']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      batchNumber: serializer.fromJson<String?>(json['batchNumber']),
      administrationDate: serializer.fromJson<DateTime>(
        json['administrationDate'],
      ),
      administeredBy: serializer.fromJson<String?>(json['administeredBy']),
      site: serializer.fromJson<String?>(json['site']),
      nextDueDate: serializer.fromJson<DateTime?>(json['nextDueDate']),
      doseNumber: serializer.fromJson<int?>(json['doseNumber']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'recordType': serializer.toJson<String>(recordType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'vaccineName': serializer.toJson<String>(vaccineName),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'batchNumber': serializer.toJson<String?>(batchNumber),
      'administrationDate': serializer.toJson<DateTime>(administrationDate),
      'administeredBy': serializer.toJson<String?>(administeredBy),
      'site': serializer.toJson<String?>(site),
      'nextDueDate': serializer.toJson<DateTime?>(nextDueDate),
      'doseNumber': serializer.toJson<int?>(doseNumber),
      'isComplete': serializer.toJson<bool>(isComplete),
    };
  }

  Vaccination copyWith({
    String? id,
    String? profileId,
    String? recordType,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? vaccineName,
    Value<String?> manufacturer = const Value.absent(),
    Value<String?> batchNumber = const Value.absent(),
    DateTime? administrationDate,
    Value<String?> administeredBy = const Value.absent(),
    Value<String?> site = const Value.absent(),
    Value<DateTime?> nextDueDate = const Value.absent(),
    Value<int?> doseNumber = const Value.absent(),
    bool? isComplete,
  }) => Vaccination(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    recordType: recordType ?? this.recordType,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    recordDate: recordDate ?? this.recordDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    vaccineName: vaccineName ?? this.vaccineName,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    batchNumber: batchNumber.present ? batchNumber.value : this.batchNumber,
    administrationDate: administrationDate ?? this.administrationDate,
    administeredBy: administeredBy.present
        ? administeredBy.value
        : this.administeredBy,
    site: site.present ? site.value : this.site,
    nextDueDate: nextDueDate.present ? nextDueDate.value : this.nextDueDate,
    doseNumber: doseNumber.present ? doseNumber.value : this.doseNumber,
    isComplete: isComplete ?? this.isComplete,
  );
  Vaccination copyWithCompanion(VaccinationsCompanion data) {
    return Vaccination(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      vaccineName: data.vaccineName.present
          ? data.vaccineName.value
          : this.vaccineName,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      administrationDate: data.administrationDate.present
          ? data.administrationDate.value
          : this.administrationDate,
      administeredBy: data.administeredBy.present
          ? data.administeredBy.value
          : this.administeredBy,
      site: data.site.present ? data.site.value : this.site,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      doseNumber: data.doseNumber.present
          ? data.doseNumber.value
          : this.doseNumber,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vaccination(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('administrationDate: $administrationDate, ')
          ..write('administeredBy: $administeredBy, ')
          ..write('site: $site, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('isComplete: $isComplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    vaccineName,
    manufacturer,
    batchNumber,
    administrationDate,
    administeredBy,
    site,
    nextDueDate,
    doseNumber,
    isComplete,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vaccination &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.recordType == this.recordType &&
          other.title == this.title &&
          other.description == this.description &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive &&
          other.vaccineName == this.vaccineName &&
          other.manufacturer == this.manufacturer &&
          other.batchNumber == this.batchNumber &&
          other.administrationDate == this.administrationDate &&
          other.administeredBy == this.administeredBy &&
          other.site == this.site &&
          other.nextDueDate == this.nextDueDate &&
          other.doseNumber == this.doseNumber &&
          other.isComplete == this.isComplete);
}

class VaccinationsCompanion extends UpdateCompanion<Vaccination> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> recordType;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  final Value<String> vaccineName;
  final Value<String?> manufacturer;
  final Value<String?> batchNumber;
  final Value<DateTime> administrationDate;
  final Value<String?> administeredBy;
  final Value<String?> site;
  final Value<DateTime?> nextDueDate;
  final Value<int?> doseNumber;
  final Value<bool> isComplete;
  final Value<int> rowid;
  const VaccinationsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.vaccineName = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.administrationDate = const Value.absent(),
    this.administeredBy = const Value.absent(),
    this.site = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.doseNumber = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaccinationsCompanion.insert({
    required String id,
    required String profileId,
    this.recordType = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime recordDate,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    required String vaccineName,
    this.manufacturer = const Value.absent(),
    this.batchNumber = const Value.absent(),
    required DateTime administrationDate,
    this.administeredBy = const Value.absent(),
    this.site = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.doseNumber = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       title = Value(title),
       recordDate = Value(recordDate),
       vaccineName = Value(vaccineName),
       administrationDate = Value(administrationDate);
  static Insertable<Vaccination> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? recordType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
    Expression<String>? vaccineName,
    Expression<String>? manufacturer,
    Expression<String>? batchNumber,
    Expression<DateTime>? administrationDate,
    Expression<String>? administeredBy,
    Expression<String>? site,
    Expression<DateTime>? nextDueDate,
    Expression<int>? doseNumber,
    Expression<bool>? isComplete,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (recordType != null) 'record_type': recordType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (vaccineName != null) 'vaccine_name': vaccineName,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (administrationDate != null) 'administration_date': administrationDate,
      if (administeredBy != null) 'administered_by': administeredBy,
      if (site != null) 'site': site,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (doseNumber != null) 'dose_number': doseNumber,
      if (isComplete != null) 'is_complete': isComplete,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaccinationsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? recordType,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? recordDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isActive,
    Value<String>? vaccineName,
    Value<String?>? manufacturer,
    Value<String?>? batchNumber,
    Value<DateTime>? administrationDate,
    Value<String?>? administeredBy,
    Value<String?>? site,
    Value<DateTime?>? nextDueDate,
    Value<int?>? doseNumber,
    Value<bool>? isComplete,
    Value<int>? rowid,
  }) {
    return VaccinationsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      vaccineName: vaccineName ?? this.vaccineName,
      manufacturer: manufacturer ?? this.manufacturer,
      batchNumber: batchNumber ?? this.batchNumber,
      administrationDate: administrationDate ?? this.administrationDate,
      administeredBy: administeredBy ?? this.administeredBy,
      site: site ?? this.site,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      doseNumber: doseNumber ?? this.doseNumber,
      isComplete: isComplete ?? this.isComplete,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (vaccineName.present) {
      map['vaccine_name'] = Variable<String>(vaccineName.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (administrationDate.present) {
      map['administration_date'] = Variable<DateTime>(administrationDate.value);
    }
    if (administeredBy.present) {
      map['administered_by'] = Variable<String>(administeredBy.value);
    }
    if (site.present) {
      map['site'] = Variable<String>(site.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (doseNumber.present) {
      map['dose_number'] = Variable<int>(doseNumber.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VaccinationsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('vaccineName: $vaccineName, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('administrationDate: $administrationDate, ')
          ..write('administeredBy: $administeredBy, ')
          ..write('site: $site, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('doseNumber: $doseNumber, ')
          ..write('isComplete: $isComplete, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AllergiesTable extends Allergies
    with TableInfo<$AllergiesTable, Allergy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllergiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('allergy'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _allergenMeta = const VerificationMeta(
    'allergen',
  );
  @override
  late final GeneratedColumn<String> allergen = GeneratedColumn<String>(
    'allergen',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _treatmentMeta = const VerificationMeta(
    'treatment',
  );
  @override
  late final GeneratedColumn<String> treatment = GeneratedColumn<String>(
    'treatment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAllergyActiveMeta = const VerificationMeta(
    'isAllergyActive',
  );
  @override
  late final GeneratedColumn<bool> isAllergyActive = GeneratedColumn<bool>(
    'is_allergy_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_allergy_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _firstReactionMeta = const VerificationMeta(
    'firstReaction',
  );
  @override
  late final GeneratedColumn<DateTime> firstReaction =
      GeneratedColumn<DateTime>(
        'first_reaction',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastReactionMeta = const VerificationMeta(
    'lastReaction',
  );
  @override
  late final GeneratedColumn<DateTime> lastReaction = GeneratedColumn<DateTime>(
    'last_reaction',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    allergen,
    severity,
    symptoms,
    treatment,
    notes,
    isAllergyActive,
    firstReaction,
    lastReaction,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allergies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Allergy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('allergen')) {
      context.handle(
        _allergenMeta,
        allergen.isAcceptableOrUnknown(data['allergen']!, _allergenMeta),
      );
    } else if (isInserting) {
      context.missing(_allergenMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    } else if (isInserting) {
      context.missing(_symptomsMeta);
    }
    if (data.containsKey('treatment')) {
      context.handle(
        _treatmentMeta,
        treatment.isAcceptableOrUnknown(data['treatment']!, _treatmentMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_allergy_active')) {
      context.handle(
        _isAllergyActiveMeta,
        isAllergyActive.isAcceptableOrUnknown(
          data['is_allergy_active']!,
          _isAllergyActiveMeta,
        ),
      );
    }
    if (data.containsKey('first_reaction')) {
      context.handle(
        _firstReactionMeta,
        firstReaction.isAcceptableOrUnknown(
          data['first_reaction']!,
          _firstReactionMeta,
        ),
      );
    }
    if (data.containsKey('last_reaction')) {
      context.handle(
        _lastReactionMeta,
        lastReaction.isAcceptableOrUnknown(
          data['last_reaction']!,
          _lastReactionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Allergy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Allergy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      allergen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergen'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      )!,
      treatment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isAllergyActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_allergy_active'],
      )!,
      firstReaction: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_reaction'],
      ),
      lastReaction: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_reaction'],
      ),
    );
  }

  @override
  $AllergiesTable createAlias(String alias) {
    return $AllergiesTable(attachedDatabase, alias);
  }
}

class Allergy extends DataClass implements Insertable<Allergy> {
  final String id;
  final String profileId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String allergen;
  final String severity;
  final String symptoms;
  final String? treatment;
  final String? notes;
  final bool isAllergyActive;
  final DateTime? firstReaction;
  final DateTime? lastReaction;
  const Allergy({
    required this.id,
    required this.profileId,
    required this.recordType,
    required this.title,
    this.description,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.allergen,
    required this.severity,
    required this.symptoms,
    this.treatment,
    this.notes,
    required this.isAllergyActive,
    this.firstReaction,
    this.lastReaction,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['record_type'] = Variable<String>(recordType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    map['allergen'] = Variable<String>(allergen);
    map['severity'] = Variable<String>(severity);
    map['symptoms'] = Variable<String>(symptoms);
    if (!nullToAbsent || treatment != null) {
      map['treatment'] = Variable<String>(treatment);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_allergy_active'] = Variable<bool>(isAllergyActive);
    if (!nullToAbsent || firstReaction != null) {
      map['first_reaction'] = Variable<DateTime>(firstReaction);
    }
    if (!nullToAbsent || lastReaction != null) {
      map['last_reaction'] = Variable<DateTime>(lastReaction);
    }
    return map;
  }

  AllergiesCompanion toCompanion(bool nullToAbsent) {
    return AllergiesCompanion(
      id: Value(id),
      profileId: Value(profileId),
      recordType: Value(recordType),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      allergen: Value(allergen),
      severity: Value(severity),
      symptoms: Value(symptoms),
      treatment: treatment == null && nullToAbsent
          ? const Value.absent()
          : Value(treatment),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isAllergyActive: Value(isAllergyActive),
      firstReaction: firstReaction == null && nullToAbsent
          ? const Value.absent()
          : Value(firstReaction),
      lastReaction: lastReaction == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReaction),
    );
  }

  factory Allergy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Allergy(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      allergen: serializer.fromJson<String>(json['allergen']),
      severity: serializer.fromJson<String>(json['severity']),
      symptoms: serializer.fromJson<String>(json['symptoms']),
      treatment: serializer.fromJson<String?>(json['treatment']),
      notes: serializer.fromJson<String?>(json['notes']),
      isAllergyActive: serializer.fromJson<bool>(json['isAllergyActive']),
      firstReaction: serializer.fromJson<DateTime?>(json['firstReaction']),
      lastReaction: serializer.fromJson<DateTime?>(json['lastReaction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'recordType': serializer.toJson<String>(recordType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'allergen': serializer.toJson<String>(allergen),
      'severity': serializer.toJson<String>(severity),
      'symptoms': serializer.toJson<String>(symptoms),
      'treatment': serializer.toJson<String?>(treatment),
      'notes': serializer.toJson<String?>(notes),
      'isAllergyActive': serializer.toJson<bool>(isAllergyActive),
      'firstReaction': serializer.toJson<DateTime?>(firstReaction),
      'lastReaction': serializer.toJson<DateTime?>(lastReaction),
    };
  }

  Allergy copyWith({
    String? id,
    String? profileId,
    String? recordType,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? allergen,
    String? severity,
    String? symptoms,
    Value<String?> treatment = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isAllergyActive,
    Value<DateTime?> firstReaction = const Value.absent(),
    Value<DateTime?> lastReaction = const Value.absent(),
  }) => Allergy(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    recordType: recordType ?? this.recordType,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    recordDate: recordDate ?? this.recordDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    allergen: allergen ?? this.allergen,
    severity: severity ?? this.severity,
    symptoms: symptoms ?? this.symptoms,
    treatment: treatment.present ? treatment.value : this.treatment,
    notes: notes.present ? notes.value : this.notes,
    isAllergyActive: isAllergyActive ?? this.isAllergyActive,
    firstReaction: firstReaction.present
        ? firstReaction.value
        : this.firstReaction,
    lastReaction: lastReaction.present ? lastReaction.value : this.lastReaction,
  );
  Allergy copyWithCompanion(AllergiesCompanion data) {
    return Allergy(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      allergen: data.allergen.present ? data.allergen.value : this.allergen,
      severity: data.severity.present ? data.severity.value : this.severity,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      treatment: data.treatment.present ? data.treatment.value : this.treatment,
      notes: data.notes.present ? data.notes.value : this.notes,
      isAllergyActive: data.isAllergyActive.present
          ? data.isAllergyActive.value
          : this.isAllergyActive,
      firstReaction: data.firstReaction.present
          ? data.firstReaction.value
          : this.firstReaction,
      lastReaction: data.lastReaction.present
          ? data.lastReaction.value
          : this.lastReaction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Allergy(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('allergen: $allergen, ')
          ..write('severity: $severity, ')
          ..write('symptoms: $symptoms, ')
          ..write('treatment: $treatment, ')
          ..write('notes: $notes, ')
          ..write('isAllergyActive: $isAllergyActive, ')
          ..write('firstReaction: $firstReaction, ')
          ..write('lastReaction: $lastReaction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    allergen,
    severity,
    symptoms,
    treatment,
    notes,
    isAllergyActive,
    firstReaction,
    lastReaction,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Allergy &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.recordType == this.recordType &&
          other.title == this.title &&
          other.description == this.description &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive &&
          other.allergen == this.allergen &&
          other.severity == this.severity &&
          other.symptoms == this.symptoms &&
          other.treatment == this.treatment &&
          other.notes == this.notes &&
          other.isAllergyActive == this.isAllergyActive &&
          other.firstReaction == this.firstReaction &&
          other.lastReaction == this.lastReaction);
}

class AllergiesCompanion extends UpdateCompanion<Allergy> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> recordType;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  final Value<String> allergen;
  final Value<String> severity;
  final Value<String> symptoms;
  final Value<String?> treatment;
  final Value<String?> notes;
  final Value<bool> isAllergyActive;
  final Value<DateTime?> firstReaction;
  final Value<DateTime?> lastReaction;
  final Value<int> rowid;
  const AllergiesCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.allergen = const Value.absent(),
    this.severity = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.treatment = const Value.absent(),
    this.notes = const Value.absent(),
    this.isAllergyActive = const Value.absent(),
    this.firstReaction = const Value.absent(),
    this.lastReaction = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AllergiesCompanion.insert({
    required String id,
    required String profileId,
    this.recordType = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime recordDate,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    required String allergen,
    required String severity,
    required String symptoms,
    this.treatment = const Value.absent(),
    this.notes = const Value.absent(),
    this.isAllergyActive = const Value.absent(),
    this.firstReaction = const Value.absent(),
    this.lastReaction = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       title = Value(title),
       recordDate = Value(recordDate),
       allergen = Value(allergen),
       severity = Value(severity),
       symptoms = Value(symptoms);
  static Insertable<Allergy> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? recordType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
    Expression<String>? allergen,
    Expression<String>? severity,
    Expression<String>? symptoms,
    Expression<String>? treatment,
    Expression<String>? notes,
    Expression<bool>? isAllergyActive,
    Expression<DateTime>? firstReaction,
    Expression<DateTime>? lastReaction,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (recordType != null) 'record_type': recordType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (allergen != null) 'allergen': allergen,
      if (severity != null) 'severity': severity,
      if (symptoms != null) 'symptoms': symptoms,
      if (treatment != null) 'treatment': treatment,
      if (notes != null) 'notes': notes,
      if (isAllergyActive != null) 'is_allergy_active': isAllergyActive,
      if (firstReaction != null) 'first_reaction': firstReaction,
      if (lastReaction != null) 'last_reaction': lastReaction,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AllergiesCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? recordType,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? recordDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isActive,
    Value<String>? allergen,
    Value<String>? severity,
    Value<String>? symptoms,
    Value<String?>? treatment,
    Value<String?>? notes,
    Value<bool>? isAllergyActive,
    Value<DateTime?>? firstReaction,
    Value<DateTime?>? lastReaction,
    Value<int>? rowid,
  }) {
    return AllergiesCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      allergen: allergen ?? this.allergen,
      severity: severity ?? this.severity,
      symptoms: symptoms ?? this.symptoms,
      treatment: treatment ?? this.treatment,
      notes: notes ?? this.notes,
      isAllergyActive: isAllergyActive ?? this.isAllergyActive,
      firstReaction: firstReaction ?? this.firstReaction,
      lastReaction: lastReaction ?? this.lastReaction,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (allergen.present) {
      map['allergen'] = Variable<String>(allergen.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (treatment.present) {
      map['treatment'] = Variable<String>(treatment.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isAllergyActive.present) {
      map['is_allergy_active'] = Variable<bool>(isAllergyActive.value);
    }
    if (firstReaction.present) {
      map['first_reaction'] = Variable<DateTime>(firstReaction.value);
    }
    if (lastReaction.present) {
      map['last_reaction'] = Variable<DateTime>(lastReaction.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllergiesCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('allergen: $allergen, ')
          ..write('severity: $severity, ')
          ..write('symptoms: $symptoms, ')
          ..write('treatment: $treatment, ')
          ..write('notes: $notes, ')
          ..write('isAllergyActive: $isAllergyActive, ')
          ..write('firstReaction: $firstReaction, ')
          ..write('lastReaction: $lastReaction, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChronicConditionsTable extends ChronicConditions
    with TableInfo<$ChronicConditionsTable, ChronicCondition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChronicConditionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordTypeMeta = const VerificationMeta(
    'recordType',
  );
  @override
  late final GeneratedColumn<String> recordType = GeneratedColumn<String>(
    'record_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('chronic_condition'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordDateMeta = const VerificationMeta(
    'recordDate',
  );
  @override
  late final GeneratedColumn<DateTime> recordDate = GeneratedColumn<DateTime>(
    'record_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _conditionNameMeta = const VerificationMeta(
    'conditionName',
  );
  @override
  late final GeneratedColumn<String> conditionName = GeneratedColumn<String>(
    'condition_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diagnosisDateMeta = const VerificationMeta(
    'diagnosisDate',
  );
  @override
  late final GeneratedColumn<DateTime> diagnosisDate =
      GeneratedColumn<DateTime>(
        'diagnosis_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _diagnosingProviderMeta =
      const VerificationMeta('diagnosingProvider');
  @override
  late final GeneratedColumn<String> diagnosingProvider =
      GeneratedColumn<String>(
        'diagnosing_provider',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _treatmentMeta = const VerificationMeta(
    'treatment',
  );
  @override
  late final GeneratedColumn<String> treatment = GeneratedColumn<String>(
    'treatment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _managementPlanMeta = const VerificationMeta(
    'managementPlan',
  );
  @override
  late final GeneratedColumn<String> managementPlan = GeneratedColumn<String>(
    'management_plan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatedMedicationsMeta =
      const VerificationMeta('relatedMedications');
  @override
  late final GeneratedColumn<String> relatedMedications =
      GeneratedColumn<String>(
        'related_medications',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    conditionName,
    diagnosisDate,
    diagnosingProvider,
    severity,
    status,
    treatment,
    managementPlan,
    relatedMedications,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chronic_conditions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChronicCondition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('record_type')) {
      context.handle(
        _recordTypeMeta,
        recordType.isAcceptableOrUnknown(data['record_type']!, _recordTypeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('record_date')) {
      context.handle(
        _recordDateMeta,
        recordDate.isAcceptableOrUnknown(data['record_date']!, _recordDateMeta),
      );
    } else if (isInserting) {
      context.missing(_recordDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('condition_name')) {
      context.handle(
        _conditionNameMeta,
        conditionName.isAcceptableOrUnknown(
          data['condition_name']!,
          _conditionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conditionNameMeta);
    }
    if (data.containsKey('diagnosis_date')) {
      context.handle(
        _diagnosisDateMeta,
        diagnosisDate.isAcceptableOrUnknown(
          data['diagnosis_date']!,
          _diagnosisDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diagnosisDateMeta);
    }
    if (data.containsKey('diagnosing_provider')) {
      context.handle(
        _diagnosingProviderMeta,
        diagnosingProvider.isAcceptableOrUnknown(
          data['diagnosing_provider']!,
          _diagnosingProviderMeta,
        ),
      );
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('treatment')) {
      context.handle(
        _treatmentMeta,
        treatment.isAcceptableOrUnknown(data['treatment']!, _treatmentMeta),
      );
    }
    if (data.containsKey('management_plan')) {
      context.handle(
        _managementPlanMeta,
        managementPlan.isAcceptableOrUnknown(
          data['management_plan']!,
          _managementPlanMeta,
        ),
      );
    }
    if (data.containsKey('related_medications')) {
      context.handle(
        _relatedMedicationsMeta,
        relatedMedications.isAcceptableOrUnknown(
          data['related_medications']!,
          _relatedMedicationsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChronicCondition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChronicCondition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      recordType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      recordDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}record_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      conditionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_name'],
      )!,
      diagnosisDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}diagnosis_date'],
      )!,
      diagnosingProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagnosing_provider'],
      ),
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      treatment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment'],
      ),
      managementPlan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}management_plan'],
      ),
      relatedMedications: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_medications'],
      ),
    );
  }

  @override
  $ChronicConditionsTable createAlias(String alias) {
    return $ChronicConditionsTable(attachedDatabase, alias);
  }
}

class ChronicCondition extends DataClass
    implements Insertable<ChronicCondition> {
  final String id;
  final String profileId;
  final String recordType;
  final String title;
  final String? description;
  final DateTime recordDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String conditionName;
  final DateTime diagnosisDate;
  final String? diagnosingProvider;
  final String severity;
  final String status;
  final String? treatment;
  final String? managementPlan;
  final String? relatedMedications;
  const ChronicCondition({
    required this.id,
    required this.profileId,
    required this.recordType,
    required this.title,
    this.description,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.conditionName,
    required this.diagnosisDate,
    this.diagnosingProvider,
    required this.severity,
    required this.status,
    this.treatment,
    this.managementPlan,
    this.relatedMedications,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['record_type'] = Variable<String>(recordType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['record_date'] = Variable<DateTime>(recordDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_active'] = Variable<bool>(isActive);
    map['condition_name'] = Variable<String>(conditionName);
    map['diagnosis_date'] = Variable<DateTime>(diagnosisDate);
    if (!nullToAbsent || diagnosingProvider != null) {
      map['diagnosing_provider'] = Variable<String>(diagnosingProvider);
    }
    map['severity'] = Variable<String>(severity);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || treatment != null) {
      map['treatment'] = Variable<String>(treatment);
    }
    if (!nullToAbsent || managementPlan != null) {
      map['management_plan'] = Variable<String>(managementPlan);
    }
    if (!nullToAbsent || relatedMedications != null) {
      map['related_medications'] = Variable<String>(relatedMedications);
    }
    return map;
  }

  ChronicConditionsCompanion toCompanion(bool nullToAbsent) {
    return ChronicConditionsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      recordType: Value(recordType),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      recordDate: Value(recordDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isActive: Value(isActive),
      conditionName: Value(conditionName),
      diagnosisDate: Value(diagnosisDate),
      diagnosingProvider: diagnosingProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosingProvider),
      severity: Value(severity),
      status: Value(status),
      treatment: treatment == null && nullToAbsent
          ? const Value.absent()
          : Value(treatment),
      managementPlan: managementPlan == null && nullToAbsent
          ? const Value.absent()
          : Value(managementPlan),
      relatedMedications: relatedMedications == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedMedications),
    );
  }

  factory ChronicCondition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChronicCondition(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      recordType: serializer.fromJson<String>(json['recordType']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      recordDate: serializer.fromJson<DateTime>(json['recordDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      conditionName: serializer.fromJson<String>(json['conditionName']),
      diagnosisDate: serializer.fromJson<DateTime>(json['diagnosisDate']),
      diagnosingProvider: serializer.fromJson<String?>(
        json['diagnosingProvider'],
      ),
      severity: serializer.fromJson<String>(json['severity']),
      status: serializer.fromJson<String>(json['status']),
      treatment: serializer.fromJson<String?>(json['treatment']),
      managementPlan: serializer.fromJson<String?>(json['managementPlan']),
      relatedMedications: serializer.fromJson<String?>(
        json['relatedMedications'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'recordType': serializer.toJson<String>(recordType),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'recordDate': serializer.toJson<DateTime>(recordDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActive': serializer.toJson<bool>(isActive),
      'conditionName': serializer.toJson<String>(conditionName),
      'diagnosisDate': serializer.toJson<DateTime>(diagnosisDate),
      'diagnosingProvider': serializer.toJson<String?>(diagnosingProvider),
      'severity': serializer.toJson<String>(severity),
      'status': serializer.toJson<String>(status),
      'treatment': serializer.toJson<String?>(treatment),
      'managementPlan': serializer.toJson<String?>(managementPlan),
      'relatedMedications': serializer.toJson<String?>(relatedMedications),
    };
  }

  ChronicCondition copyWith({
    String? id,
    String? profileId,
    String? recordType,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? recordDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? conditionName,
    DateTime? diagnosisDate,
    Value<String?> diagnosingProvider = const Value.absent(),
    String? severity,
    String? status,
    Value<String?> treatment = const Value.absent(),
    Value<String?> managementPlan = const Value.absent(),
    Value<String?> relatedMedications = const Value.absent(),
  }) => ChronicCondition(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    recordType: recordType ?? this.recordType,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    recordDate: recordDate ?? this.recordDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isActive: isActive ?? this.isActive,
    conditionName: conditionName ?? this.conditionName,
    diagnosisDate: diagnosisDate ?? this.diagnosisDate,
    diagnosingProvider: diagnosingProvider.present
        ? diagnosingProvider.value
        : this.diagnosingProvider,
    severity: severity ?? this.severity,
    status: status ?? this.status,
    treatment: treatment.present ? treatment.value : this.treatment,
    managementPlan: managementPlan.present
        ? managementPlan.value
        : this.managementPlan,
    relatedMedications: relatedMedications.present
        ? relatedMedications.value
        : this.relatedMedications,
  );
  ChronicCondition copyWithCompanion(ChronicConditionsCompanion data) {
    return ChronicCondition(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      recordType: data.recordType.present
          ? data.recordType.value
          : this.recordType,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      recordDate: data.recordDate.present
          ? data.recordDate.value
          : this.recordDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      conditionName: data.conditionName.present
          ? data.conditionName.value
          : this.conditionName,
      diagnosisDate: data.diagnosisDate.present
          ? data.diagnosisDate.value
          : this.diagnosisDate,
      diagnosingProvider: data.diagnosingProvider.present
          ? data.diagnosingProvider.value
          : this.diagnosingProvider,
      severity: data.severity.present ? data.severity.value : this.severity,
      status: data.status.present ? data.status.value : this.status,
      treatment: data.treatment.present ? data.treatment.value : this.treatment,
      managementPlan: data.managementPlan.present
          ? data.managementPlan.value
          : this.managementPlan,
      relatedMedications: data.relatedMedications.present
          ? data.relatedMedications.value
          : this.relatedMedications,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChronicCondition(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('conditionName: $conditionName, ')
          ..write('diagnosisDate: $diagnosisDate, ')
          ..write('diagnosingProvider: $diagnosingProvider, ')
          ..write('severity: $severity, ')
          ..write('status: $status, ')
          ..write('treatment: $treatment, ')
          ..write('managementPlan: $managementPlan, ')
          ..write('relatedMedications: $relatedMedications')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    recordType,
    title,
    description,
    recordDate,
    createdAt,
    updatedAt,
    isActive,
    conditionName,
    diagnosisDate,
    diagnosingProvider,
    severity,
    status,
    treatment,
    managementPlan,
    relatedMedications,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChronicCondition &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.recordType == this.recordType &&
          other.title == this.title &&
          other.description == this.description &&
          other.recordDate == this.recordDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isActive == this.isActive &&
          other.conditionName == this.conditionName &&
          other.diagnosisDate == this.diagnosisDate &&
          other.diagnosingProvider == this.diagnosingProvider &&
          other.severity == this.severity &&
          other.status == this.status &&
          other.treatment == this.treatment &&
          other.managementPlan == this.managementPlan &&
          other.relatedMedications == this.relatedMedications);
}

class ChronicConditionsCompanion extends UpdateCompanion<ChronicCondition> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> recordType;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> recordDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isActive;
  final Value<String> conditionName;
  final Value<DateTime> diagnosisDate;
  final Value<String?> diagnosingProvider;
  final Value<String> severity;
  final Value<String> status;
  final Value<String?> treatment;
  final Value<String?> managementPlan;
  final Value<String?> relatedMedications;
  final Value<int> rowid;
  const ChronicConditionsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.recordType = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.recordDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.conditionName = const Value.absent(),
    this.diagnosisDate = const Value.absent(),
    this.diagnosingProvider = const Value.absent(),
    this.severity = const Value.absent(),
    this.status = const Value.absent(),
    this.treatment = const Value.absent(),
    this.managementPlan = const Value.absent(),
    this.relatedMedications = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChronicConditionsCompanion.insert({
    required String id,
    required String profileId,
    this.recordType = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime recordDate,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActive = const Value.absent(),
    required String conditionName,
    required DateTime diagnosisDate,
    this.diagnosingProvider = const Value.absent(),
    required String severity,
    required String status,
    this.treatment = const Value.absent(),
    this.managementPlan = const Value.absent(),
    this.relatedMedications = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       title = Value(title),
       recordDate = Value(recordDate),
       conditionName = Value(conditionName),
       diagnosisDate = Value(diagnosisDate),
       severity = Value(severity),
       status = Value(status);
  static Insertable<ChronicCondition> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? recordType,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? recordDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActive,
    Expression<String>? conditionName,
    Expression<DateTime>? diagnosisDate,
    Expression<String>? diagnosingProvider,
    Expression<String>? severity,
    Expression<String>? status,
    Expression<String>? treatment,
    Expression<String>? managementPlan,
    Expression<String>? relatedMedications,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (recordType != null) 'record_type': recordType,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (recordDate != null) 'record_date': recordDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActive != null) 'is_active': isActive,
      if (conditionName != null) 'condition_name': conditionName,
      if (diagnosisDate != null) 'diagnosis_date': diagnosisDate,
      if (diagnosingProvider != null) 'diagnosing_provider': diagnosingProvider,
      if (severity != null) 'severity': severity,
      if (status != null) 'status': status,
      if (treatment != null) 'treatment': treatment,
      if (managementPlan != null) 'management_plan': managementPlan,
      if (relatedMedications != null) 'related_medications': relatedMedications,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChronicConditionsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? recordType,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? recordDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isActive,
    Value<String>? conditionName,
    Value<DateTime>? diagnosisDate,
    Value<String?>? diagnosingProvider,
    Value<String>? severity,
    Value<String>? status,
    Value<String?>? treatment,
    Value<String?>? managementPlan,
    Value<String?>? relatedMedications,
    Value<int>? rowid,
  }) {
    return ChronicConditionsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      recordType: recordType ?? this.recordType,
      title: title ?? this.title,
      description: description ?? this.description,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      conditionName: conditionName ?? this.conditionName,
      diagnosisDate: diagnosisDate ?? this.diagnosisDate,
      diagnosingProvider: diagnosingProvider ?? this.diagnosingProvider,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      treatment: treatment ?? this.treatment,
      managementPlan: managementPlan ?? this.managementPlan,
      relatedMedications: relatedMedications ?? this.relatedMedications,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (recordType.present) {
      map['record_type'] = Variable<String>(recordType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (recordDate.present) {
      map['record_date'] = Variable<DateTime>(recordDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (conditionName.present) {
      map['condition_name'] = Variable<String>(conditionName.value);
    }
    if (diagnosisDate.present) {
      map['diagnosis_date'] = Variable<DateTime>(diagnosisDate.value);
    }
    if (diagnosingProvider.present) {
      map['diagnosing_provider'] = Variable<String>(diagnosingProvider.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (treatment.present) {
      map['treatment'] = Variable<String>(treatment.value);
    }
    if (managementPlan.present) {
      map['management_plan'] = Variable<String>(managementPlan.value);
    }
    if (relatedMedications.present) {
      map['related_medications'] = Variable<String>(relatedMedications.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChronicConditionsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('recordType: $recordType, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('recordDate: $recordDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActive: $isActive, ')
          ..write('conditionName: $conditionName, ')
          ..write('diagnosisDate: $diagnosisDate, ')
          ..write('diagnosingProvider: $diagnosingProvider, ')
          ..write('severity: $severity, ')
          ..write('status: $status, ')
          ..write('treatment: $treatment, ')
          ..write('managementPlan: $managementPlan, ')
          ..write('relatedMedications: $relatedMedications, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    description,
    createdAt,
    usageCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final String color;
  final String? description;
  final DateTime createdAt;
  final int usageCount;
  const Tag({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    required this.createdAt,
    required this.usageCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['usage_count'] = Variable<int>(usageCount);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      usageCount: Value(usageCount),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'usageCount': serializer.toJson<int>(usageCount),
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    String? color,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    int? usageCount,
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    usageCount: usageCount ?? this.usageCount,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('usageCount: $usageCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, color, description, createdAt, usageCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.usageCount == this.usageCount);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> color;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<int> usageCount;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required String color,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       color = Value(color);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<int>? usageCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (usageCount != null) 'usage_count': usageCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? color,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<int>? usageCount,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      usageCount: usageCount ?? this.usageCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('usageCount: $usageCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, Attachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileTypeMeta = const VerificationMeta(
    'fileType',
  );
  @override
  late final GeneratedColumn<String> fileType = GeneratedColumn<String>(
    'file_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    recordId,
    fileName,
    filePath,
    fileType,
    fileSize,
    description,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('file_type')) {
      context.handle(
        _fileTypeMeta,
        fileType.isAcceptableOrUnknown(data['file_type']!, _fileTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileTypeMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attachment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      fileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_type'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class Attachment extends DataClass implements Insertable<Attachment> {
  final String id;
  final String recordId;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String? description;
  final DateTime createdAt;
  final bool isSynced;
  const Attachment({
    required this.id,
    required this.recordId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    this.description,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['record_id'] = Variable<String>(recordId);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    map['file_type'] = Variable<String>(fileType);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      recordId: Value(recordId),
      fileName: Value(fileName),
      filePath: Value(filePath),
      fileType: Value(fileType),
      fileSize: Value(fileSize),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory Attachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attachment(
      id: serializer.fromJson<String>(json['id']),
      recordId: serializer.fromJson<String>(json['recordId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      fileType: serializer.fromJson<String>(json['fileType']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'recordId': serializer.toJson<String>(recordId),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'fileType': serializer.toJson<String>(fileType),
      'fileSize': serializer.toJson<int>(fileSize),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Attachment copyWith({
    String? id,
    String? recordId,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSize,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    bool? isSynced,
  }) => Attachment(
    id: id ?? this.id,
    recordId: recordId ?? this.recordId,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    fileType: fileType ?? this.fileType,
    fileSize: fileSize ?? this.fileSize,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Attachment copyWithCompanion(AttachmentsCompanion data) {
    return Attachment(
      id: data.id.present ? data.id.value : this.id,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      fileType: data.fileType.present ? data.fileType.value : this.fileType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attachment(')
          ..write('id: $id, ')
          ..write('recordId: $recordId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('fileType: $fileType, ')
          ..write('fileSize: $fileSize, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    recordId,
    fileName,
    filePath,
    fileType,
    fileSize,
    description,
    createdAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attachment &&
          other.id == this.id &&
          other.recordId == this.recordId &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.fileType == this.fileType &&
          other.fileSize == this.fileSize &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class AttachmentsCompanion extends UpdateCompanion<Attachment> {
  final Value<String> id;
  final Value<String> recordId;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<String> fileType;
  final Value<int> fileSize;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.recordId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.fileType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String recordId,
    required String fileName,
    required String filePath,
    required String fileType,
    required int fileSize,
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recordId = Value(recordId),
       fileName = Value(fileName),
       filePath = Value(filePath),
       fileType = Value(fileType),
       fileSize = Value(fileSize);
  static Insertable<Attachment> custom({
    Expression<String>? id,
    Expression<String>? recordId,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<String>? fileType,
    Expression<int>? fileSize,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (recordId != null) 'record_id': recordId,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (fileType != null) 'file_type': fileType,
      if (fileSize != null) 'file_size': fileSize,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? recordId,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<String>? fileType,
    Value<int>? fileSize,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      recordId: recordId ?? this.recordId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (fileType.present) {
      map['file_type'] = Variable<String>(fileType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('recordId: $recordId, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('fileType: $fileType, ')
          ..write('fileSize: $fileSize, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledTime =
      GeneratedColumn<DateTime>(
        'scheduled_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysOfWeekMeta = const VerificationMeta(
    'daysOfWeek',
  );
  @override
  late final GeneratedColumn<String> daysOfWeek = GeneratedColumn<String>(
    'days_of_week',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeSlotsMeta = const VerificationMeta(
    'timeSlots',
  );
  @override
  late final GeneratedColumn<String> timeSlots = GeneratedColumn<String>(
    'time_slots',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSentMeta = const VerificationMeta(
    'lastSent',
  );
  @override
  late final GeneratedColumn<DateTime> lastSent = GeneratedColumn<DateTime>(
    'last_sent',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextScheduledMeta = const VerificationMeta(
    'nextScheduled',
  );
  @override
  late final GeneratedColumn<DateTime> nextScheduled =
      GeneratedColumn<DateTime>(
        'next_scheduled',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _snoozeMinutesMeta = const VerificationMeta(
    'snoozeMinutes',
  );
  @override
  late final GeneratedColumn<int> snoozeMinutes = GeneratedColumn<int>(
    'snooze_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicationId,
    title,
    description,
    scheduledTime,
    frequency,
    daysOfWeek,
    timeSlots,
    isActive,
    lastSent,
    nextScheduled,
    snoozeMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('days_of_week')) {
      context.handle(
        _daysOfWeekMeta,
        daysOfWeek.isAcceptableOrUnknown(
          data['days_of_week']!,
          _daysOfWeekMeta,
        ),
      );
    }
    if (data.containsKey('time_slots')) {
      context.handle(
        _timeSlotsMeta,
        timeSlots.isAcceptableOrUnknown(data['time_slots']!, _timeSlotsMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_sent')) {
      context.handle(
        _lastSentMeta,
        lastSent.isAcceptableOrUnknown(data['last_sent']!, _lastSentMeta),
      );
    }
    if (data.containsKey('next_scheduled')) {
      context.handle(
        _nextScheduledMeta,
        nextScheduled.isAcceptableOrUnknown(
          data['next_scheduled']!,
          _nextScheduledMeta,
        ),
      );
    }
    if (data.containsKey('snooze_minutes')) {
      context.handle(
        _snoozeMinutesMeta,
        snoozeMinutes.isAcceptableOrUnknown(
          data['snooze_minutes']!,
          _snoozeMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_time'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      daysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}days_of_week'],
      ),
      timeSlots: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_slots'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastSent: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sent'],
      ),
      nextScheduled: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_scheduled'],
      ),
      snoozeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_minutes'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final String? medicationId;
  final String title;
  final String? description;
  final DateTime scheduledTime;
  final String frequency;
  final String? daysOfWeek;
  final String? timeSlots;
  final bool isActive;
  final DateTime? lastSent;
  final DateTime? nextScheduled;
  final int snoozeMinutes;
  const Reminder({
    required this.id,
    this.medicationId,
    required this.title,
    this.description,
    required this.scheduledTime,
    required this.frequency,
    this.daysOfWeek,
    this.timeSlots,
    required this.isActive,
    this.lastSent,
    this.nextScheduled,
    required this.snoozeMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || medicationId != null) {
      map['medication_id'] = Variable<String>(medicationId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['scheduled_time'] = Variable<DateTime>(scheduledTime);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || daysOfWeek != null) {
      map['days_of_week'] = Variable<String>(daysOfWeek);
    }
    if (!nullToAbsent || timeSlots != null) {
      map['time_slots'] = Variable<String>(timeSlots);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastSent != null) {
      map['last_sent'] = Variable<DateTime>(lastSent);
    }
    if (!nullToAbsent || nextScheduled != null) {
      map['next_scheduled'] = Variable<DateTime>(nextScheduled);
    }
    map['snooze_minutes'] = Variable<int>(snoozeMinutes);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      medicationId: medicationId == null && nullToAbsent
          ? const Value.absent()
          : Value(medicationId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      scheduledTime: Value(scheduledTime),
      frequency: Value(frequency),
      daysOfWeek: daysOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(daysOfWeek),
      timeSlots: timeSlots == null && nullToAbsent
          ? const Value.absent()
          : Value(timeSlots),
      isActive: Value(isActive),
      lastSent: lastSent == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSent),
      nextScheduled: nextScheduled == null && nullToAbsent
          ? const Value.absent()
          : Value(nextScheduled),
      snoozeMinutes: Value(snoozeMinutes),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      medicationId: serializer.fromJson<String?>(json['medicationId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      scheduledTime: serializer.fromJson<DateTime>(json['scheduledTime']),
      frequency: serializer.fromJson<String>(json['frequency']),
      daysOfWeek: serializer.fromJson<String?>(json['daysOfWeek']),
      timeSlots: serializer.fromJson<String?>(json['timeSlots']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastSent: serializer.fromJson<DateTime?>(json['lastSent']),
      nextScheduled: serializer.fromJson<DateTime?>(json['nextScheduled']),
      snoozeMinutes: serializer.fromJson<int>(json['snoozeMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'medicationId': serializer.toJson<String?>(medicationId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'scheduledTime': serializer.toJson<DateTime>(scheduledTime),
      'frequency': serializer.toJson<String>(frequency),
      'daysOfWeek': serializer.toJson<String?>(daysOfWeek),
      'timeSlots': serializer.toJson<String?>(timeSlots),
      'isActive': serializer.toJson<bool>(isActive),
      'lastSent': serializer.toJson<DateTime?>(lastSent),
      'nextScheduled': serializer.toJson<DateTime?>(nextScheduled),
      'snoozeMinutes': serializer.toJson<int>(snoozeMinutes),
    };
  }

  Reminder copyWith({
    String? id,
    Value<String?> medicationId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? scheduledTime,
    String? frequency,
    Value<String?> daysOfWeek = const Value.absent(),
    Value<String?> timeSlots = const Value.absent(),
    bool? isActive,
    Value<DateTime?> lastSent = const Value.absent(),
    Value<DateTime?> nextScheduled = const Value.absent(),
    int? snoozeMinutes,
  }) => Reminder(
    id: id ?? this.id,
    medicationId: medicationId.present ? medicationId.value : this.medicationId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    frequency: frequency ?? this.frequency,
    daysOfWeek: daysOfWeek.present ? daysOfWeek.value : this.daysOfWeek,
    timeSlots: timeSlots.present ? timeSlots.value : this.timeSlots,
    isActive: isActive ?? this.isActive,
    lastSent: lastSent.present ? lastSent.value : this.lastSent,
    nextScheduled: nextScheduled.present
        ? nextScheduled.value
        : this.nextScheduled,
    snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      daysOfWeek: data.daysOfWeek.present
          ? data.daysOfWeek.value
          : this.daysOfWeek,
      timeSlots: data.timeSlots.present ? data.timeSlots.value : this.timeSlots,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastSent: data.lastSent.present ? data.lastSent.value : this.lastSent,
      nextScheduled: data.nextScheduled.present
          ? data.nextScheduled.value
          : this.nextScheduled,
      snoozeMinutes: data.snoozeMinutes.present
          ? data.snoozeMinutes.value
          : this.snoozeMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('frequency: $frequency, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('timeSlots: $timeSlots, ')
          ..write('isActive: $isActive, ')
          ..write('lastSent: $lastSent, ')
          ..write('nextScheduled: $nextScheduled, ')
          ..write('snoozeMinutes: $snoozeMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicationId,
    title,
    description,
    scheduledTime,
    frequency,
    daysOfWeek,
    timeSlots,
    isActive,
    lastSent,
    nextScheduled,
    snoozeMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.medicationId == this.medicationId &&
          other.title == this.title &&
          other.description == this.description &&
          other.scheduledTime == this.scheduledTime &&
          other.frequency == this.frequency &&
          other.daysOfWeek == this.daysOfWeek &&
          other.timeSlots == this.timeSlots &&
          other.isActive == this.isActive &&
          other.lastSent == this.lastSent &&
          other.nextScheduled == this.nextScheduled &&
          other.snoozeMinutes == this.snoozeMinutes);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<String?> medicationId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> scheduledTime;
  final Value<String> frequency;
  final Value<String?> daysOfWeek;
  final Value<String?> timeSlots;
  final Value<bool> isActive;
  final Value<DateTime?> lastSent;
  final Value<DateTime?> nextScheduled;
  final Value<int> snoozeMinutes;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.frequency = const Value.absent(),
    this.daysOfWeek = const Value.absent(),
    this.timeSlots = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSent = const Value.absent(),
    this.nextScheduled = const Value.absent(),
    this.snoozeMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    this.medicationId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime scheduledTime,
    required String frequency,
    this.daysOfWeek = const Value.absent(),
    this.timeSlots = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSent = const Value.absent(),
    this.nextScheduled = const Value.absent(),
    this.snoozeMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       scheduledTime = Value(scheduledTime),
       frequency = Value(frequency);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<String>? medicationId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? scheduledTime,
    Expression<String>? frequency,
    Expression<String>? daysOfWeek,
    Expression<String>? timeSlots,
    Expression<bool>? isActive,
    Expression<DateTime>? lastSent,
    Expression<DateTime>? nextScheduled,
    Expression<int>? snoozeMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicationId != null) 'medication_id': medicationId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (frequency != null) 'frequency': frequency,
      if (daysOfWeek != null) 'days_of_week': daysOfWeek,
      if (timeSlots != null) 'time_slots': timeSlots,
      if (isActive != null) 'is_active': isActive,
      if (lastSent != null) 'last_sent': lastSent,
      if (nextScheduled != null) 'next_scheduled': nextScheduled,
      if (snoozeMinutes != null) 'snooze_minutes': snoozeMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? id,
    Value<String?>? medicationId,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? scheduledTime,
    Value<String>? frequency,
    Value<String?>? daysOfWeek,
    Value<String?>? timeSlots,
    Value<bool>? isActive,
    Value<DateTime?>? lastSent,
    Value<DateTime?>? nextScheduled,
    Value<int>? snoozeMinutes,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      frequency: frequency ?? this.frequency,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      timeSlots: timeSlots ?? this.timeSlots,
      isActive: isActive ?? this.isActive,
      lastSent: lastSent ?? this.lastSent,
      nextScheduled: nextScheduled ?? this.nextScheduled,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (daysOfWeek.present) {
      map['days_of_week'] = Variable<String>(daysOfWeek.value);
    }
    if (timeSlots.present) {
      map['time_slots'] = Variable<String>(timeSlots.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastSent.present) {
      map['last_sent'] = Variable<DateTime>(lastSent.value);
    }
    if (nextScheduled.present) {
      map['next_scheduled'] = Variable<DateTime>(nextScheduled.value);
    }
    if (snoozeMinutes.present) {
      map['snooze_minutes'] = Variable<int>(snoozeMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('medicationId: $medicationId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('frequency: $frequency, ')
          ..write('daysOfWeek: $daysOfWeek, ')
          ..write('timeSlots: $timeSlots, ')
          ..write('isActive: $isActive, ')
          ..write('lastSent: $lastSent, ')
          ..write('nextScheduled: $nextScheduled, ')
          ..write('snoozeMinutes: $snoozeMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmergencyCardsTable extends EmergencyCards
    with TableInfo<$EmergencyCardsTable, EmergencyCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmergencyCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criticalAllergiesMeta = const VerificationMeta(
    'criticalAllergies',
  );
  @override
  late final GeneratedColumn<String> criticalAllergies =
      GeneratedColumn<String>(
        'critical_allergies',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _currentMedicationsMeta =
      const VerificationMeta('currentMedications');
  @override
  late final GeneratedColumn<String> currentMedications =
      GeneratedColumn<String>(
        'current_medications',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _medicalConditionsMeta = const VerificationMeta(
    'medicalConditions',
  );
  @override
  late final GeneratedColumn<String> medicalConditions =
      GeneratedColumn<String>(
        'medical_conditions',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _emergencyContactMeta = const VerificationMeta(
    'emergencyContact',
  );
  @override
  late final GeneratedColumn<String> emergencyContact = GeneratedColumn<String>(
    'emergency_contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondaryContactMeta = const VerificationMeta(
    'secondaryContact',
  );
  @override
  late final GeneratedColumn<String> secondaryContact = GeneratedColumn<String>(
    'secondary_contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _insuranceInfoMeta = const VerificationMeta(
    'insuranceInfo',
  );
  @override
  late final GeneratedColumn<String> insuranceInfo = GeneratedColumn<String>(
    'insurance_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _additionalNotesMeta = const VerificationMeta(
    'additionalNotes',
  );
  @override
  late final GeneratedColumn<String> additionalNotes = GeneratedColumn<String>(
    'additional_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    profileId,
    criticalAllergies,
    currentMedications,
    medicalConditions,
    emergencyContact,
    secondaryContact,
    insuranceInfo,
    additionalNotes,
    lastUpdated,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emergency_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmergencyCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('critical_allergies')) {
      context.handle(
        _criticalAllergiesMeta,
        criticalAllergies.isAcceptableOrUnknown(
          data['critical_allergies']!,
          _criticalAllergiesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_criticalAllergiesMeta);
    }
    if (data.containsKey('current_medications')) {
      context.handle(
        _currentMedicationsMeta,
        currentMedications.isAcceptableOrUnknown(
          data['current_medications']!,
          _currentMedicationsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentMedicationsMeta);
    }
    if (data.containsKey('medical_conditions')) {
      context.handle(
        _medicalConditionsMeta,
        medicalConditions.isAcceptableOrUnknown(
          data['medical_conditions']!,
          _medicalConditionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicalConditionsMeta);
    }
    if (data.containsKey('emergency_contact')) {
      context.handle(
        _emergencyContactMeta,
        emergencyContact.isAcceptableOrUnknown(
          data['emergency_contact']!,
          _emergencyContactMeta,
        ),
      );
    }
    if (data.containsKey('secondary_contact')) {
      context.handle(
        _secondaryContactMeta,
        secondaryContact.isAcceptableOrUnknown(
          data['secondary_contact']!,
          _secondaryContactMeta,
        ),
      );
    }
    if (data.containsKey('insurance_info')) {
      context.handle(
        _insuranceInfoMeta,
        insuranceInfo.isAcceptableOrUnknown(
          data['insurance_info']!,
          _insuranceInfoMeta,
        ),
      );
    }
    if (data.containsKey('additional_notes')) {
      context.handle(
        _additionalNotesMeta,
        additionalNotes.isAcceptableOrUnknown(
          data['additional_notes']!,
          _additionalNotesMeta,
        ),
      );
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmergencyCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmergencyCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      criticalAllergies: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}critical_allergies'],
      )!,
      currentMedications: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_medications'],
      )!,
      medicalConditions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medical_conditions'],
      )!,
      emergencyContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emergency_contact'],
      ),
      secondaryContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_contact'],
      ),
      insuranceInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insurance_info'],
      ),
      additionalNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}additional_notes'],
      ),
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $EmergencyCardsTable createAlias(String alias) {
    return $EmergencyCardsTable(attachedDatabase, alias);
  }
}

class EmergencyCard extends DataClass implements Insertable<EmergencyCard> {
  final String id;
  final String profileId;
  final String criticalAllergies;
  final String currentMedications;
  final String medicalConditions;
  final String? emergencyContact;
  final String? secondaryContact;
  final String? insuranceInfo;
  final String? additionalNotes;
  final DateTime lastUpdated;
  final bool isActive;
  const EmergencyCard({
    required this.id,
    required this.profileId,
    required this.criticalAllergies,
    required this.currentMedications,
    required this.medicalConditions,
    this.emergencyContact,
    this.secondaryContact,
    this.insuranceInfo,
    this.additionalNotes,
    required this.lastUpdated,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['profile_id'] = Variable<String>(profileId);
    map['critical_allergies'] = Variable<String>(criticalAllergies);
    map['current_medications'] = Variable<String>(currentMedications);
    map['medical_conditions'] = Variable<String>(medicalConditions);
    if (!nullToAbsent || emergencyContact != null) {
      map['emergency_contact'] = Variable<String>(emergencyContact);
    }
    if (!nullToAbsent || secondaryContact != null) {
      map['secondary_contact'] = Variable<String>(secondaryContact);
    }
    if (!nullToAbsent || insuranceInfo != null) {
      map['insurance_info'] = Variable<String>(insuranceInfo);
    }
    if (!nullToAbsent || additionalNotes != null) {
      map['additional_notes'] = Variable<String>(additionalNotes);
    }
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  EmergencyCardsCompanion toCompanion(bool nullToAbsent) {
    return EmergencyCardsCompanion(
      id: Value(id),
      profileId: Value(profileId),
      criticalAllergies: Value(criticalAllergies),
      currentMedications: Value(currentMedications),
      medicalConditions: Value(medicalConditions),
      emergencyContact: emergencyContact == null && nullToAbsent
          ? const Value.absent()
          : Value(emergencyContact),
      secondaryContact: secondaryContact == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryContact),
      insuranceInfo: insuranceInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(insuranceInfo),
      additionalNotes: additionalNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(additionalNotes),
      lastUpdated: Value(lastUpdated),
      isActive: Value(isActive),
    );
  }

  factory EmergencyCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmergencyCard(
      id: serializer.fromJson<String>(json['id']),
      profileId: serializer.fromJson<String>(json['profileId']),
      criticalAllergies: serializer.fromJson<String>(json['criticalAllergies']),
      currentMedications: serializer.fromJson<String>(
        json['currentMedications'],
      ),
      medicalConditions: serializer.fromJson<String>(json['medicalConditions']),
      emergencyContact: serializer.fromJson<String?>(json['emergencyContact']),
      secondaryContact: serializer.fromJson<String?>(json['secondaryContact']),
      insuranceInfo: serializer.fromJson<String?>(json['insuranceInfo']),
      additionalNotes: serializer.fromJson<String?>(json['additionalNotes']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'profileId': serializer.toJson<String>(profileId),
      'criticalAllergies': serializer.toJson<String>(criticalAllergies),
      'currentMedications': serializer.toJson<String>(currentMedications),
      'medicalConditions': serializer.toJson<String>(medicalConditions),
      'emergencyContact': serializer.toJson<String?>(emergencyContact),
      'secondaryContact': serializer.toJson<String?>(secondaryContact),
      'insuranceInfo': serializer.toJson<String?>(insuranceInfo),
      'additionalNotes': serializer.toJson<String?>(additionalNotes),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  EmergencyCard copyWith({
    String? id,
    String? profileId,
    String? criticalAllergies,
    String? currentMedications,
    String? medicalConditions,
    Value<String?> emergencyContact = const Value.absent(),
    Value<String?> secondaryContact = const Value.absent(),
    Value<String?> insuranceInfo = const Value.absent(),
    Value<String?> additionalNotes = const Value.absent(),
    DateTime? lastUpdated,
    bool? isActive,
  }) => EmergencyCard(
    id: id ?? this.id,
    profileId: profileId ?? this.profileId,
    criticalAllergies: criticalAllergies ?? this.criticalAllergies,
    currentMedications: currentMedications ?? this.currentMedications,
    medicalConditions: medicalConditions ?? this.medicalConditions,
    emergencyContact: emergencyContact.present
        ? emergencyContact.value
        : this.emergencyContact,
    secondaryContact: secondaryContact.present
        ? secondaryContact.value
        : this.secondaryContact,
    insuranceInfo: insuranceInfo.present
        ? insuranceInfo.value
        : this.insuranceInfo,
    additionalNotes: additionalNotes.present
        ? additionalNotes.value
        : this.additionalNotes,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    isActive: isActive ?? this.isActive,
  );
  EmergencyCard copyWithCompanion(EmergencyCardsCompanion data) {
    return EmergencyCard(
      id: data.id.present ? data.id.value : this.id,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      criticalAllergies: data.criticalAllergies.present
          ? data.criticalAllergies.value
          : this.criticalAllergies,
      currentMedications: data.currentMedications.present
          ? data.currentMedications.value
          : this.currentMedications,
      medicalConditions: data.medicalConditions.present
          ? data.medicalConditions.value
          : this.medicalConditions,
      emergencyContact: data.emergencyContact.present
          ? data.emergencyContact.value
          : this.emergencyContact,
      secondaryContact: data.secondaryContact.present
          ? data.secondaryContact.value
          : this.secondaryContact,
      insuranceInfo: data.insuranceInfo.present
          ? data.insuranceInfo.value
          : this.insuranceInfo,
      additionalNotes: data.additionalNotes.present
          ? data.additionalNotes.value
          : this.additionalNotes,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmergencyCard(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('criticalAllergies: $criticalAllergies, ')
          ..write('currentMedications: $currentMedications, ')
          ..write('medicalConditions: $medicalConditions, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('secondaryContact: $secondaryContact, ')
          ..write('insuranceInfo: $insuranceInfo, ')
          ..write('additionalNotes: $additionalNotes, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    profileId,
    criticalAllergies,
    currentMedications,
    medicalConditions,
    emergencyContact,
    secondaryContact,
    insuranceInfo,
    additionalNotes,
    lastUpdated,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmergencyCard &&
          other.id == this.id &&
          other.profileId == this.profileId &&
          other.criticalAllergies == this.criticalAllergies &&
          other.currentMedications == this.currentMedications &&
          other.medicalConditions == this.medicalConditions &&
          other.emergencyContact == this.emergencyContact &&
          other.secondaryContact == this.secondaryContact &&
          other.insuranceInfo == this.insuranceInfo &&
          other.additionalNotes == this.additionalNotes &&
          other.lastUpdated == this.lastUpdated &&
          other.isActive == this.isActive);
}

class EmergencyCardsCompanion extends UpdateCompanion<EmergencyCard> {
  final Value<String> id;
  final Value<String> profileId;
  final Value<String> criticalAllergies;
  final Value<String> currentMedications;
  final Value<String> medicalConditions;
  final Value<String?> emergencyContact;
  final Value<String?> secondaryContact;
  final Value<String?> insuranceInfo;
  final Value<String?> additionalNotes;
  final Value<DateTime> lastUpdated;
  final Value<bool> isActive;
  final Value<int> rowid;
  const EmergencyCardsCompanion({
    this.id = const Value.absent(),
    this.profileId = const Value.absent(),
    this.criticalAllergies = const Value.absent(),
    this.currentMedications = const Value.absent(),
    this.medicalConditions = const Value.absent(),
    this.emergencyContact = const Value.absent(),
    this.secondaryContact = const Value.absent(),
    this.insuranceInfo = const Value.absent(),
    this.additionalNotes = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmergencyCardsCompanion.insert({
    required String id,
    required String profileId,
    required String criticalAllergies,
    required String currentMedications,
    required String medicalConditions,
    this.emergencyContact = const Value.absent(),
    this.secondaryContact = const Value.absent(),
    this.insuranceInfo = const Value.absent(),
    this.additionalNotes = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       profileId = Value(profileId),
       criticalAllergies = Value(criticalAllergies),
       currentMedications = Value(currentMedications),
       medicalConditions = Value(medicalConditions);
  static Insertable<EmergencyCard> custom({
    Expression<String>? id,
    Expression<String>? profileId,
    Expression<String>? criticalAllergies,
    Expression<String>? currentMedications,
    Expression<String>? medicalConditions,
    Expression<String>? emergencyContact,
    Expression<String>? secondaryContact,
    Expression<String>? insuranceInfo,
    Expression<String>? additionalNotes,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (profileId != null) 'profile_id': profileId,
      if (criticalAllergies != null) 'critical_allergies': criticalAllergies,
      if (currentMedications != null) 'current_medications': currentMedications,
      if (medicalConditions != null) 'medical_conditions': medicalConditions,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
      if (secondaryContact != null) 'secondary_contact': secondaryContact,
      if (insuranceInfo != null) 'insurance_info': insuranceInfo,
      if (additionalNotes != null) 'additional_notes': additionalNotes,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmergencyCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? profileId,
    Value<String>? criticalAllergies,
    Value<String>? currentMedications,
    Value<String>? medicalConditions,
    Value<String?>? emergencyContact,
    Value<String?>? secondaryContact,
    Value<String?>? insuranceInfo,
    Value<String?>? additionalNotes,
    Value<DateTime>? lastUpdated,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return EmergencyCardsCompanion(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      criticalAllergies: criticalAllergies ?? this.criticalAllergies,
      currentMedications: currentMedications ?? this.currentMedications,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      secondaryContact: secondaryContact ?? this.secondaryContact,
      insuranceInfo: insuranceInfo ?? this.insuranceInfo,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (criticalAllergies.present) {
      map['critical_allergies'] = Variable<String>(criticalAllergies.value);
    }
    if (currentMedications.present) {
      map['current_medications'] = Variable<String>(currentMedications.value);
    }
    if (medicalConditions.present) {
      map['medical_conditions'] = Variable<String>(medicalConditions.value);
    }
    if (emergencyContact.present) {
      map['emergency_contact'] = Variable<String>(emergencyContact.value);
    }
    if (secondaryContact.present) {
      map['secondary_contact'] = Variable<String>(secondaryContact.value);
    }
    if (insuranceInfo.present) {
      map['insurance_info'] = Variable<String>(insuranceInfo.value);
    }
    if (additionalNotes.present) {
      map['additional_notes'] = Variable<String>(additionalNotes.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmergencyCardsCompanion(')
          ..write('id: $id, ')
          ..write('profileId: $profileId, ')
          ..write('criticalAllergies: $criticalAllergies, ')
          ..write('currentMedications: $currentMedications, ')
          ..write('medicalConditions: $medicalConditions, ')
          ..write('emergencyContact: $emergencyContact, ')
          ..write('secondaryContact: $secondaryContact, ')
          ..write('insuranceInfo: $insuranceInfo, ')
          ..write('additionalNotes: $additionalNotes, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FamilyMemberProfilesTable familyMemberProfiles =
      $FamilyMemberProfilesTable(this);
  late final $MedicalRecordsTable medicalRecords = $MedicalRecordsTable(this);
  late final $PrescriptionsTable prescriptions = $PrescriptionsTable(this);
  late final $LabReportsTable labReports = $LabReportsTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $VaccinationsTable vaccinations = $VaccinationsTable(this);
  late final $AllergiesTable allergies = $AllergiesTable(this);
  late final $ChronicConditionsTable chronicConditions =
      $ChronicConditionsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $EmergencyCardsTable emergencyCards = $EmergencyCardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    familyMemberProfiles,
    medicalRecords,
    prescriptions,
    labReports,
    medications,
    vaccinations,
    allergies,
    chronicConditions,
    tags,
    attachments,
    reminders,
    emergencyCards,
  ];
}

typedef $$FamilyMemberProfilesTableCreateCompanionBuilder =
    FamilyMemberProfilesCompanion Function({
      required String id,
      required String firstName,
      required String lastName,
      Value<String?> middleName,
      required DateTime dateOfBirth,
      required String gender,
      Value<String?> bloodType,
      Value<double?> height,
      Value<double?> weight,
      Value<String?> emergencyContact,
      Value<String?> insuranceInfo,
      Value<String?> profileImagePath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$FamilyMemberProfilesTableUpdateCompanionBuilder =
    FamilyMemberProfilesCompanion Function({
      Value<String> id,
      Value<String> firstName,
      Value<String> lastName,
      Value<String?> middleName,
      Value<DateTime> dateOfBirth,
      Value<String> gender,
      Value<String?> bloodType,
      Value<double?> height,
      Value<double?> weight,
      Value<String?> emergencyContact,
      Value<String?> insuranceInfo,
      Value<String?> profileImagePath,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$FamilyMemberProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyMemberProfilesTable> {
  $$FamilyMemberProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bloodType => $composableBuilder(
    column: $table.bloodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insuranceInfo => $composableBuilder(
    column: $table.insuranceInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileImagePath => $composableBuilder(
    column: $table.profileImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyMemberProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyMemberProfilesTable> {
  $$FamilyMemberProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bloodType => $composableBuilder(
    column: $table.bloodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insuranceInfo => $composableBuilder(
    column: $table.insuranceInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileImagePath => $composableBuilder(
    column: $table.profileImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyMemberProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyMemberProfilesTable> {
  $$FamilyMemberProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get middleName => $composableBuilder(
    column: $table.middleName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
    column: $table.dateOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get bloodType =>
      $composableBuilder(column: $table.bloodType, builder: (column) => column);

  GeneratedColumn<double> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insuranceInfo => $composableBuilder(
    column: $table.insuranceInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get profileImagePath => $composableBuilder(
    column: $table.profileImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$FamilyMemberProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FamilyMemberProfilesTable,
          FamilyMemberProfile,
          $$FamilyMemberProfilesTableFilterComposer,
          $$FamilyMemberProfilesTableOrderingComposer,
          $$FamilyMemberProfilesTableAnnotationComposer,
          $$FamilyMemberProfilesTableCreateCompanionBuilder,
          $$FamilyMemberProfilesTableUpdateCompanionBuilder,
          (
            FamilyMemberProfile,
            BaseReferences<
              _$AppDatabase,
              $FamilyMemberProfilesTable,
              FamilyMemberProfile
            >,
          ),
          FamilyMemberProfile,
          PrefetchHooks Function()
        > {
  $$FamilyMemberProfilesTableTableManager(
    _$AppDatabase db,
    $FamilyMemberProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyMemberProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyMemberProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FamilyMemberProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String?> middleName = const Value.absent(),
                Value<DateTime> dateOfBirth = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String?> bloodType = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<String?> emergencyContact = const Value.absent(),
                Value<String?> insuranceInfo = const Value.absent(),
                Value<String?> profileImagePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyMemberProfilesCompanion(
                id: id,
                firstName: firstName,
                lastName: lastName,
                middleName: middleName,
                dateOfBirth: dateOfBirth,
                gender: gender,
                bloodType: bloodType,
                height: height,
                weight: weight,
                emergencyContact: emergencyContact,
                insuranceInfo: insuranceInfo,
                profileImagePath: profileImagePath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String firstName,
                required String lastName,
                Value<String?> middleName = const Value.absent(),
                required DateTime dateOfBirth,
                required String gender,
                Value<String?> bloodType = const Value.absent(),
                Value<double?> height = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<String?> emergencyContact = const Value.absent(),
                Value<String?> insuranceInfo = const Value.absent(),
                Value<String?> profileImagePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyMemberProfilesCompanion.insert(
                id: id,
                firstName: firstName,
                lastName: lastName,
                middleName: middleName,
                dateOfBirth: dateOfBirth,
                gender: gender,
                bloodType: bloodType,
                height: height,
                weight: weight,
                emergencyContact: emergencyContact,
                insuranceInfo: insuranceInfo,
                profileImagePath: profileImagePath,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyMemberProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FamilyMemberProfilesTable,
      FamilyMemberProfile,
      $$FamilyMemberProfilesTableFilterComposer,
      $$FamilyMemberProfilesTableOrderingComposer,
      $$FamilyMemberProfilesTableAnnotationComposer,
      $$FamilyMemberProfilesTableCreateCompanionBuilder,
      $$FamilyMemberProfilesTableUpdateCompanionBuilder,
      (
        FamilyMemberProfile,
        BaseReferences<
          _$AppDatabase,
          $FamilyMemberProfilesTable,
          FamilyMemberProfile
        >,
      ),
      FamilyMemberProfile,
      PrefetchHooks Function()
    >;
typedef $$MedicalRecordsTableCreateCompanionBuilder =
    MedicalRecordsCompanion Function({
      required String id,
      required String profileId,
      required String recordType,
      required String title,
      Value<String?> description,
      required DateTime recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$MedicalRecordsTableUpdateCompanionBuilder =
    MedicalRecordsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> recordType,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$MedicalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicalRecordsTable> {
  $$MedicalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicalRecordsTable> {
  $$MedicalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicalRecordsTable> {
  $$MedicalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$MedicalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicalRecordsTable,
          MedicalRecord,
          $$MedicalRecordsTableFilterComposer,
          $$MedicalRecordsTableOrderingComposer,
          $$MedicalRecordsTableAnnotationComposer,
          $$MedicalRecordsTableCreateCompanionBuilder,
          $$MedicalRecordsTableUpdateCompanionBuilder,
          (
            MedicalRecord,
            BaseReferences<_$AppDatabase, $MedicalRecordsTable, MedicalRecord>,
          ),
          MedicalRecord,
          PrefetchHooks Function()
        > {
  $$MedicalRecordsTableTableManager(
    _$AppDatabase db,
    $MedicalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicalRecordsCompanion(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String recordType,
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime recordDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicalRecordsCompanion.insert(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicalRecordsTable,
      MedicalRecord,
      $$MedicalRecordsTableFilterComposer,
      $$MedicalRecordsTableOrderingComposer,
      $$MedicalRecordsTableAnnotationComposer,
      $$MedicalRecordsTableCreateCompanionBuilder,
      $$MedicalRecordsTableUpdateCompanionBuilder,
      (
        MedicalRecord,
        BaseReferences<_$AppDatabase, $MedicalRecordsTable, MedicalRecord>,
      ),
      MedicalRecord,
      PrefetchHooks Function()
    >;
typedef $$PrescriptionsTableCreateCompanionBuilder =
    PrescriptionsCompanion Function({
      required String id,
      required String profileId,
      Value<String> recordType,
      required String title,
      Value<String?> description,
      required DateTime recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      required String medicationName,
      required String dosage,
      required String frequency,
      Value<String?> instructions,
      Value<String?> prescribingDoctor,
      Value<String?> pharmacy,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<int?> refillsRemaining,
      Value<bool> isPrescriptionActive,
      Value<int> rowid,
    });
typedef $$PrescriptionsTableUpdateCompanionBuilder =
    PrescriptionsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> recordType,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      Value<String> medicationName,
      Value<String> dosage,
      Value<String> frequency,
      Value<String?> instructions,
      Value<String?> prescribingDoctor,
      Value<String?> pharmacy,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<int?> refillsRemaining,
      Value<bool> isPrescriptionActive,
      Value<int> rowid,
    });

class $$PrescriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescribingDoctor => $composableBuilder(
    column: $table.prescribingDoctor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pharmacy => $composableBuilder(
    column: $table.pharmacy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refillsRemaining => $composableBuilder(
    column: $table.refillsRemaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrescriptionActive => $composableBuilder(
    column: $table.isPrescriptionActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PrescriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescribingDoctor => $composableBuilder(
    column: $table.prescribingDoctor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pharmacy => $composableBuilder(
    column: $table.pharmacy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refillsRemaining => $composableBuilder(
    column: $table.refillsRemaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrescriptionActive => $composableBuilder(
    column: $table.isPrescriptionActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrescriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrescriptionsTable> {
  $$PrescriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prescribingDoctor => $composableBuilder(
    column: $table.prescribingDoctor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pharmacy =>
      $composableBuilder(column: $table.pharmacy, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get refillsRemaining => $composableBuilder(
    column: $table.refillsRemaining,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrescriptionActive => $composableBuilder(
    column: $table.isPrescriptionActive,
    builder: (column) => column,
  );
}

class $$PrescriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrescriptionsTable,
          Prescription,
          $$PrescriptionsTableFilterComposer,
          $$PrescriptionsTableOrderingComposer,
          $$PrescriptionsTableAnnotationComposer,
          $$PrescriptionsTableCreateCompanionBuilder,
          $$PrescriptionsTableUpdateCompanionBuilder,
          (
            Prescription,
            BaseReferences<_$AppDatabase, $PrescriptionsTable, Prescription>,
          ),
          Prescription,
          PrefetchHooks Function()
        > {
  $$PrescriptionsTableTableManager(_$AppDatabase db, $PrescriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrescriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrescriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrescriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> medicationName = const Value.absent(),
                Value<String> dosage = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<String?> prescribingDoctor = const Value.absent(),
                Value<String?> pharmacy = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> refillsRemaining = const Value.absent(),
                Value<bool> isPrescriptionActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrescriptionsCompanion(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                medicationName: medicationName,
                dosage: dosage,
                frequency: frequency,
                instructions: instructions,
                prescribingDoctor: prescribingDoctor,
                pharmacy: pharmacy,
                startDate: startDate,
                endDate: endDate,
                refillsRemaining: refillsRemaining,
                isPrescriptionActive: isPrescriptionActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                Value<String> recordType = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime recordDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required String medicationName,
                required String dosage,
                required String frequency,
                Value<String?> instructions = const Value.absent(),
                Value<String?> prescribingDoctor = const Value.absent(),
                Value<String?> pharmacy = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int?> refillsRemaining = const Value.absent(),
                Value<bool> isPrescriptionActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrescriptionsCompanion.insert(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                medicationName: medicationName,
                dosage: dosage,
                frequency: frequency,
                instructions: instructions,
                prescribingDoctor: prescribingDoctor,
                pharmacy: pharmacy,
                startDate: startDate,
                endDate: endDate,
                refillsRemaining: refillsRemaining,
                isPrescriptionActive: isPrescriptionActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PrescriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrescriptionsTable,
      Prescription,
      $$PrescriptionsTableFilterComposer,
      $$PrescriptionsTableOrderingComposer,
      $$PrescriptionsTableAnnotationComposer,
      $$PrescriptionsTableCreateCompanionBuilder,
      $$PrescriptionsTableUpdateCompanionBuilder,
      (
        Prescription,
        BaseReferences<_$AppDatabase, $PrescriptionsTable, Prescription>,
      ),
      Prescription,
      PrefetchHooks Function()
    >;
typedef $$LabReportsTableCreateCompanionBuilder =
    LabReportsCompanion Function({
      required String id,
      required String profileId,
      Value<String> recordType,
      required String title,
      Value<String?> description,
      required DateTime recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      required String testName,
      Value<String?> testResults,
      Value<String?> referenceRange,
      Value<String?> orderingPhysician,
      Value<String?> labFacility,
      required String testStatus,
      Value<DateTime?> collectionDate,
      Value<bool> isCritical,
      Value<int> rowid,
    });
typedef $$LabReportsTableUpdateCompanionBuilder =
    LabReportsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> recordType,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      Value<String> testName,
      Value<String?> testResults,
      Value<String?> referenceRange,
      Value<String?> orderingPhysician,
      Value<String?> labFacility,
      Value<String> testStatus,
      Value<DateTime?> collectionDate,
      Value<bool> isCritical,
      Value<int> rowid,
    });

class $$LabReportsTableFilterComposer
    extends Composer<_$AppDatabase, $LabReportsTable> {
  $$LabReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testName => $composableBuilder(
    column: $table.testName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testResults => $composableBuilder(
    column: $table.testResults,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceRange => $composableBuilder(
    column: $table.referenceRange,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderingPhysician => $composableBuilder(
    column: $table.orderingPhysician,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labFacility => $composableBuilder(
    column: $table.labFacility,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get testStatus => $composableBuilder(
    column: $table.testStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get collectionDate => $composableBuilder(
    column: $table.collectionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCritical => $composableBuilder(
    column: $table.isCritical,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LabReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $LabReportsTable> {
  $$LabReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testName => $composableBuilder(
    column: $table.testName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testResults => $composableBuilder(
    column: $table.testResults,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceRange => $composableBuilder(
    column: $table.referenceRange,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderingPhysician => $composableBuilder(
    column: $table.orderingPhysician,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labFacility => $composableBuilder(
    column: $table.labFacility,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get testStatus => $composableBuilder(
    column: $table.testStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get collectionDate => $composableBuilder(
    column: $table.collectionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCritical => $composableBuilder(
    column: $table.isCritical,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LabReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LabReportsTable> {
  $$LabReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get testName =>
      $composableBuilder(column: $table.testName, builder: (column) => column);

  GeneratedColumn<String> get testResults => $composableBuilder(
    column: $table.testResults,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceRange => $composableBuilder(
    column: $table.referenceRange,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderingPhysician => $composableBuilder(
    column: $table.orderingPhysician,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labFacility => $composableBuilder(
    column: $table.labFacility,
    builder: (column) => column,
  );

  GeneratedColumn<String> get testStatus => $composableBuilder(
    column: $table.testStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get collectionDate => $composableBuilder(
    column: $table.collectionDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCritical => $composableBuilder(
    column: $table.isCritical,
    builder: (column) => column,
  );
}

class $$LabReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LabReportsTable,
          LabReport,
          $$LabReportsTableFilterComposer,
          $$LabReportsTableOrderingComposer,
          $$LabReportsTableAnnotationComposer,
          $$LabReportsTableCreateCompanionBuilder,
          $$LabReportsTableUpdateCompanionBuilder,
          (
            LabReport,
            BaseReferences<_$AppDatabase, $LabReportsTable, LabReport>,
          ),
          LabReport,
          PrefetchHooks Function()
        > {
  $$LabReportsTableTableManager(_$AppDatabase db, $LabReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> testName = const Value.absent(),
                Value<String?> testResults = const Value.absent(),
                Value<String?> referenceRange = const Value.absent(),
                Value<String?> orderingPhysician = const Value.absent(),
                Value<String?> labFacility = const Value.absent(),
                Value<String> testStatus = const Value.absent(),
                Value<DateTime?> collectionDate = const Value.absent(),
                Value<bool> isCritical = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LabReportsCompanion(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                testName: testName,
                testResults: testResults,
                referenceRange: referenceRange,
                orderingPhysician: orderingPhysician,
                labFacility: labFacility,
                testStatus: testStatus,
                collectionDate: collectionDate,
                isCritical: isCritical,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                Value<String> recordType = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime recordDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required String testName,
                Value<String?> testResults = const Value.absent(),
                Value<String?> referenceRange = const Value.absent(),
                Value<String?> orderingPhysician = const Value.absent(),
                Value<String?> labFacility = const Value.absent(),
                required String testStatus,
                Value<DateTime?> collectionDate = const Value.absent(),
                Value<bool> isCritical = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LabReportsCompanion.insert(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                testName: testName,
                testResults: testResults,
                referenceRange: referenceRange,
                orderingPhysician: orderingPhysician,
                labFacility: labFacility,
                testStatus: testStatus,
                collectionDate: collectionDate,
                isCritical: isCritical,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LabReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LabReportsTable,
      LabReport,
      $$LabReportsTableFilterComposer,
      $$LabReportsTableOrderingComposer,
      $$LabReportsTableAnnotationComposer,
      $$LabReportsTableCreateCompanionBuilder,
      $$LabReportsTableUpdateCompanionBuilder,
      (LabReport, BaseReferences<_$AppDatabase, $LabReportsTable, LabReport>),
      LabReport,
      PrefetchHooks Function()
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      required String id,
      required String profileId,
      Value<String> recordType,
      required String title,
      Value<String?> description,
      required DateTime recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      required String medicationName,
      required String dosage,
      required String frequency,
      required String schedule,
      required DateTime startDate,
      Value<DateTime?> endDate,
      Value<String?> instructions,
      Value<bool> reminderEnabled,
      Value<int?> pillCount,
      required String status,
      Value<int> rowid,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> recordType,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      Value<String> medicationName,
      Value<String> dosage,
      Value<String> frequency,
      Value<String> schedule,
      Value<DateTime> startDate,
      Value<DateTime?> endDate,
      Value<String?> instructions,
      Value<bool> reminderEnabled,
      Value<int?> pillCount,
      Value<String> status,
      Value<int> rowid,
    });

class $$MedicationsTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schedule => $composableBuilder(
    column: $table.schedule,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pillCount => $composableBuilder(
    column: $table.pillCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationsTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schedule => $composableBuilder(
    column: $table.schedule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pillCount => $composableBuilder(
    column: $table.pillCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get schedule =>
      $composableBuilder(column: $table.schedule, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pillCount =>
      $composableBuilder(column: $table.pillCount, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (
            Medication,
            BaseReferences<_$AppDatabase, $MedicationsTable, Medication>,
          ),
          Medication,
          PrefetchHooks Function()
        > {
  $$MedicationsTableTableManager(_$AppDatabase db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> medicationName = const Value.absent(),
                Value<String> dosage = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String> schedule = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int?> pillCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                medicationName: medicationName,
                dosage: dosage,
                frequency: frequency,
                schedule: schedule,
                startDate: startDate,
                endDate: endDate,
                instructions: instructions,
                reminderEnabled: reminderEnabled,
                pillCount: pillCount,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                Value<String> recordType = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime recordDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required String medicationName,
                required String dosage,
                required String frequency,
                required String schedule,
                required DateTime startDate,
                Value<DateTime?> endDate = const Value.absent(),
                Value<String?> instructions = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int?> pillCount = const Value.absent(),
                required String status,
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                medicationName: medicationName,
                dosage: dosage,
                frequency: frequency,
                schedule: schedule,
                startDate: startDate,
                endDate: endDate,
                instructions: instructions,
                reminderEnabled: reminderEnabled,
                pillCount: pillCount,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (
        Medication,
        BaseReferences<_$AppDatabase, $MedicationsTable, Medication>,
      ),
      Medication,
      PrefetchHooks Function()
    >;
typedef $$VaccinationsTableCreateCompanionBuilder =
    VaccinationsCompanion Function({
      required String id,
      required String profileId,
      Value<String> recordType,
      required String title,
      Value<String?> description,
      required DateTime recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      required String vaccineName,
      Value<String?> manufacturer,
      Value<String?> batchNumber,
      required DateTime administrationDate,
      Value<String?> administeredBy,
      Value<String?> site,
      Value<DateTime?> nextDueDate,
      Value<int?> doseNumber,
      Value<bool> isComplete,
      Value<int> rowid,
    });
typedef $$VaccinationsTableUpdateCompanionBuilder =
    VaccinationsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> recordType,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      Value<String> vaccineName,
      Value<String?> manufacturer,
      Value<String?> batchNumber,
      Value<DateTime> administrationDate,
      Value<String?> administeredBy,
      Value<String?> site,
      Value<DateTime?> nextDueDate,
      Value<int?> doseNumber,
      Value<bool> isComplete,
      Value<int> rowid,
    });

class $$VaccinationsTableFilterComposer
    extends Composer<_$AppDatabase, $VaccinationsTable> {
  $$VaccinationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get administrationDate => $composableBuilder(
    column: $table.administrationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get administeredBy => $composableBuilder(
    column: $table.administeredBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get site => $composableBuilder(
    column: $table.site,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get doseNumber => $composableBuilder(
    column: $table.doseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VaccinationsTableOrderingComposer
    extends Composer<_$AppDatabase, $VaccinationsTable> {
  $$VaccinationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get administrationDate => $composableBuilder(
    column: $table.administrationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get administeredBy => $composableBuilder(
    column: $table.administeredBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get site => $composableBuilder(
    column: $table.site,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get doseNumber => $composableBuilder(
    column: $table.doseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VaccinationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaccinationsTable> {
  $$VaccinationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get vaccineName => $composableBuilder(
    column: $table.vaccineName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get administrationDate => $composableBuilder(
    column: $table.administrationDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get administeredBy => $composableBuilder(
    column: $table.administeredBy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get site =>
      $composableBuilder(column: $table.site, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get doseNumber => $composableBuilder(
    column: $table.doseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => column,
  );
}

class $$VaccinationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaccinationsTable,
          Vaccination,
          $$VaccinationsTableFilterComposer,
          $$VaccinationsTableOrderingComposer,
          $$VaccinationsTableAnnotationComposer,
          $$VaccinationsTableCreateCompanionBuilder,
          $$VaccinationsTableUpdateCompanionBuilder,
          (
            Vaccination,
            BaseReferences<_$AppDatabase, $VaccinationsTable, Vaccination>,
          ),
          Vaccination,
          PrefetchHooks Function()
        > {
  $$VaccinationsTableTableManager(_$AppDatabase db, $VaccinationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaccinationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaccinationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaccinationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> vaccineName = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> batchNumber = const Value.absent(),
                Value<DateTime> administrationDate = const Value.absent(),
                Value<String?> administeredBy = const Value.absent(),
                Value<String?> site = const Value.absent(),
                Value<DateTime?> nextDueDate = const Value.absent(),
                Value<int?> doseNumber = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaccinationsCompanion(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                vaccineName: vaccineName,
                manufacturer: manufacturer,
                batchNumber: batchNumber,
                administrationDate: administrationDate,
                administeredBy: administeredBy,
                site: site,
                nextDueDate: nextDueDate,
                doseNumber: doseNumber,
                isComplete: isComplete,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                Value<String> recordType = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime recordDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required String vaccineName,
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> batchNumber = const Value.absent(),
                required DateTime administrationDate,
                Value<String?> administeredBy = const Value.absent(),
                Value<String?> site = const Value.absent(),
                Value<DateTime?> nextDueDate = const Value.absent(),
                Value<int?> doseNumber = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaccinationsCompanion.insert(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                vaccineName: vaccineName,
                manufacturer: manufacturer,
                batchNumber: batchNumber,
                administrationDate: administrationDate,
                administeredBy: administeredBy,
                site: site,
                nextDueDate: nextDueDate,
                doseNumber: doseNumber,
                isComplete: isComplete,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VaccinationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaccinationsTable,
      Vaccination,
      $$VaccinationsTableFilterComposer,
      $$VaccinationsTableOrderingComposer,
      $$VaccinationsTableAnnotationComposer,
      $$VaccinationsTableCreateCompanionBuilder,
      $$VaccinationsTableUpdateCompanionBuilder,
      (
        Vaccination,
        BaseReferences<_$AppDatabase, $VaccinationsTable, Vaccination>,
      ),
      Vaccination,
      PrefetchHooks Function()
    >;
typedef $$AllergiesTableCreateCompanionBuilder =
    AllergiesCompanion Function({
      required String id,
      required String profileId,
      Value<String> recordType,
      required String title,
      Value<String?> description,
      required DateTime recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      required String allergen,
      required String severity,
      required String symptoms,
      Value<String?> treatment,
      Value<String?> notes,
      Value<bool> isAllergyActive,
      Value<DateTime?> firstReaction,
      Value<DateTime?> lastReaction,
      Value<int> rowid,
    });
typedef $$AllergiesTableUpdateCompanionBuilder =
    AllergiesCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> recordType,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      Value<String> allergen,
      Value<String> severity,
      Value<String> symptoms,
      Value<String?> treatment,
      Value<String?> notes,
      Value<bool> isAllergyActive,
      Value<DateTime?> firstReaction,
      Value<DateTime?> lastReaction,
      Value<int> rowid,
    });

class $$AllergiesTableFilterComposer
    extends Composer<_$AppDatabase, $AllergiesTable> {
  $$AllergiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get allergen => $composableBuilder(
    column: $table.allergen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treatment => $composableBuilder(
    column: $table.treatment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllergyActive => $composableBuilder(
    column: $table.isAllergyActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstReaction => $composableBuilder(
    column: $table.firstReaction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReaction => $composableBuilder(
    column: $table.lastReaction,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AllergiesTableOrderingComposer
    extends Composer<_$AppDatabase, $AllergiesTable> {
  $$AllergiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get allergen => $composableBuilder(
    column: $table.allergen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treatment => $composableBuilder(
    column: $table.treatment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllergyActive => $composableBuilder(
    column: $table.isAllergyActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstReaction => $composableBuilder(
    column: $table.firstReaction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReaction => $composableBuilder(
    column: $table.lastReaction,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AllergiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AllergiesTable> {
  $$AllergiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get allergen =>
      $composableBuilder(column: $table.allergen, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<String> get treatment =>
      $composableBuilder(column: $table.treatment, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isAllergyActive => $composableBuilder(
    column: $table.isAllergyActive,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get firstReaction => $composableBuilder(
    column: $table.firstReaction,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReaction => $composableBuilder(
    column: $table.lastReaction,
    builder: (column) => column,
  );
}

class $$AllergiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AllergiesTable,
          Allergy,
          $$AllergiesTableFilterComposer,
          $$AllergiesTableOrderingComposer,
          $$AllergiesTableAnnotationComposer,
          $$AllergiesTableCreateCompanionBuilder,
          $$AllergiesTableUpdateCompanionBuilder,
          (Allergy, BaseReferences<_$AppDatabase, $AllergiesTable, Allergy>),
          Allergy,
          PrefetchHooks Function()
        > {
  $$AllergiesTableTableManager(_$AppDatabase db, $AllergiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AllergiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AllergiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AllergiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> allergen = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<String?> treatment = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isAllergyActive = const Value.absent(),
                Value<DateTime?> firstReaction = const Value.absent(),
                Value<DateTime?> lastReaction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllergiesCompanion(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                allergen: allergen,
                severity: severity,
                symptoms: symptoms,
                treatment: treatment,
                notes: notes,
                isAllergyActive: isAllergyActive,
                firstReaction: firstReaction,
                lastReaction: lastReaction,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                Value<String> recordType = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime recordDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required String allergen,
                required String severity,
                required String symptoms,
                Value<String?> treatment = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isAllergyActive = const Value.absent(),
                Value<DateTime?> firstReaction = const Value.absent(),
                Value<DateTime?> lastReaction = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllergiesCompanion.insert(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                allergen: allergen,
                severity: severity,
                symptoms: symptoms,
                treatment: treatment,
                notes: notes,
                isAllergyActive: isAllergyActive,
                firstReaction: firstReaction,
                lastReaction: lastReaction,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AllergiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AllergiesTable,
      Allergy,
      $$AllergiesTableFilterComposer,
      $$AllergiesTableOrderingComposer,
      $$AllergiesTableAnnotationComposer,
      $$AllergiesTableCreateCompanionBuilder,
      $$AllergiesTableUpdateCompanionBuilder,
      (Allergy, BaseReferences<_$AppDatabase, $AllergiesTable, Allergy>),
      Allergy,
      PrefetchHooks Function()
    >;
typedef $$ChronicConditionsTableCreateCompanionBuilder =
    ChronicConditionsCompanion Function({
      required String id,
      required String profileId,
      Value<String> recordType,
      required String title,
      Value<String?> description,
      required DateTime recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      required String conditionName,
      required DateTime diagnosisDate,
      Value<String?> diagnosingProvider,
      required String severity,
      required String status,
      Value<String?> treatment,
      Value<String?> managementPlan,
      Value<String?> relatedMedications,
      Value<int> rowid,
    });
typedef $$ChronicConditionsTableUpdateCompanionBuilder =
    ChronicConditionsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> recordType,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> recordDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isActive,
      Value<String> conditionName,
      Value<DateTime> diagnosisDate,
      Value<String?> diagnosingProvider,
      Value<String> severity,
      Value<String> status,
      Value<String?> treatment,
      Value<String?> managementPlan,
      Value<String?> relatedMedications,
      Value<int> rowid,
    });

class $$ChronicConditionsTableFilterComposer
    extends Composer<_$AppDatabase, $ChronicConditionsTable> {
  $$ChronicConditionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionName => $composableBuilder(
    column: $table.conditionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get diagnosisDate => $composableBuilder(
    column: $table.diagnosisDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diagnosingProvider => $composableBuilder(
    column: $table.diagnosingProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get treatment => $composableBuilder(
    column: $table.treatment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get managementPlan => $composableBuilder(
    column: $table.managementPlan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedMedications => $composableBuilder(
    column: $table.relatedMedications,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChronicConditionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChronicConditionsTable> {
  $$ChronicConditionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionName => $composableBuilder(
    column: $table.conditionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get diagnosisDate => $composableBuilder(
    column: $table.diagnosisDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagnosingProvider => $composableBuilder(
    column: $table.diagnosingProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get treatment => $composableBuilder(
    column: $table.treatment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get managementPlan => $composableBuilder(
    column: $table.managementPlan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedMedications => $composableBuilder(
    column: $table.relatedMedications,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChronicConditionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChronicConditionsTable> {
  $$ChronicConditionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get recordType => $composableBuilder(
    column: $table.recordType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordDate => $composableBuilder(
    column: $table.recordDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get conditionName => $composableBuilder(
    column: $table.conditionName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get diagnosisDate => $composableBuilder(
    column: $table.diagnosisDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get diagnosingProvider => $composableBuilder(
    column: $table.diagnosingProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get treatment =>
      $composableBuilder(column: $table.treatment, builder: (column) => column);

  GeneratedColumn<String> get managementPlan => $composableBuilder(
    column: $table.managementPlan,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relatedMedications => $composableBuilder(
    column: $table.relatedMedications,
    builder: (column) => column,
  );
}

class $$ChronicConditionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChronicConditionsTable,
          ChronicCondition,
          $$ChronicConditionsTableFilterComposer,
          $$ChronicConditionsTableOrderingComposer,
          $$ChronicConditionsTableAnnotationComposer,
          $$ChronicConditionsTableCreateCompanionBuilder,
          $$ChronicConditionsTableUpdateCompanionBuilder,
          (
            ChronicCondition,
            BaseReferences<
              _$AppDatabase,
              $ChronicConditionsTable,
              ChronicCondition
            >,
          ),
          ChronicCondition,
          PrefetchHooks Function()
        > {
  $$ChronicConditionsTableTableManager(
    _$AppDatabase db,
    $ChronicConditionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChronicConditionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChronicConditionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChronicConditionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> recordType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> recordDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> conditionName = const Value.absent(),
                Value<DateTime> diagnosisDate = const Value.absent(),
                Value<String?> diagnosingProvider = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> treatment = const Value.absent(),
                Value<String?> managementPlan = const Value.absent(),
                Value<String?> relatedMedications = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChronicConditionsCompanion(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                conditionName: conditionName,
                diagnosisDate: diagnosisDate,
                diagnosingProvider: diagnosingProvider,
                severity: severity,
                status: status,
                treatment: treatment,
                managementPlan: managementPlan,
                relatedMedications: relatedMedications,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                Value<String> recordType = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime recordDate,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required String conditionName,
                required DateTime diagnosisDate,
                Value<String?> diagnosingProvider = const Value.absent(),
                required String severity,
                required String status,
                Value<String?> treatment = const Value.absent(),
                Value<String?> managementPlan = const Value.absent(),
                Value<String?> relatedMedications = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChronicConditionsCompanion.insert(
                id: id,
                profileId: profileId,
                recordType: recordType,
                title: title,
                description: description,
                recordDate: recordDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isActive: isActive,
                conditionName: conditionName,
                diagnosisDate: diagnosisDate,
                diagnosingProvider: diagnosingProvider,
                severity: severity,
                status: status,
                treatment: treatment,
                managementPlan: managementPlan,
                relatedMedications: relatedMedications,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChronicConditionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChronicConditionsTable,
      ChronicCondition,
      $$ChronicConditionsTableFilterComposer,
      $$ChronicConditionsTableOrderingComposer,
      $$ChronicConditionsTableAnnotationComposer,
      $$ChronicConditionsTableCreateCompanionBuilder,
      $$ChronicConditionsTableUpdateCompanionBuilder,
      (
        ChronicCondition,
        BaseReferences<
          _$AppDatabase,
          $ChronicConditionsTable,
          ChronicCondition
        >,
      ),
      ChronicCondition,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      required String color,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<int> usageCount,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> color,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<int> usageCount,
      Value<int> rowid,
    });

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
          Tag,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                color: color,
                description: description,
                createdAt: createdAt,
                usageCount: usageCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String color,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                color: color,
                description: description,
                createdAt: createdAt,
                usageCount: usageCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
      Tag,
      PrefetchHooks Function()
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String recordId,
      required String fileName,
      required String filePath,
      required String fileType,
      required int fileSize,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> recordId,
      Value<String> fileName,
      Value<String> filePath,
      Value<String> fileType,
      Value<int> fileSize,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileType => $composableBuilder(
    column: $table.fileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get fileType =>
      $composableBuilder(column: $table.fileType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          Attachment,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            Attachment,
            BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
          ),
          Attachment,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> fileType = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                recordId: recordId,
                fileName: fileName,
                filePath: filePath,
                fileType: fileType,
                fileSize: fileSize,
                description: description,
                createdAt: createdAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String recordId,
                required String fileName,
                required String filePath,
                required String fileType,
                required int fileSize,
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                recordId: recordId,
                fileName: fileName,
                filePath: filePath,
                fileType: fileType,
                fileSize: fileSize,
                description: description,
                createdAt: createdAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      Attachment,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        Attachment,
        BaseReferences<_$AppDatabase, $AttachmentsTable, Attachment>,
      ),
      Attachment,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder =
    RemindersCompanion Function({
      required String id,
      Value<String?> medicationId,
      required String title,
      Value<String?> description,
      required DateTime scheduledTime,
      required String frequency,
      Value<String?> daysOfWeek,
      Value<String?> timeSlots,
      Value<bool> isActive,
      Value<DateTime?> lastSent,
      Value<DateTime?> nextScheduled,
      Value<int> snoozeMinutes,
      Value<int> rowid,
    });
typedef $$RemindersTableUpdateCompanionBuilder =
    RemindersCompanion Function({
      Value<String> id,
      Value<String?> medicationId,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> scheduledTime,
      Value<String> frequency,
      Value<String?> daysOfWeek,
      Value<String?> timeSlots,
      Value<bool> isActive,
      Value<DateTime?> lastSent,
      Value<DateTime?> nextScheduled,
      Value<int> snoozeMinutes,
      Value<int> rowid,
    });

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeSlots => $composableBuilder(
    column: $table.timeSlots,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSent => $composableBuilder(
    column: $table.lastSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextScheduled => $composableBuilder(
    column: $table.nextScheduled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeSlots => $composableBuilder(
    column: $table.timeSlots,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSent => $composableBuilder(
    column: $table.lastSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextScheduled => $composableBuilder(
    column: $table.nextScheduled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get medicationId => $composableBuilder(
    column: $table.medicationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get daysOfWeek => $composableBuilder(
    column: $table.daysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeSlots =>
      $composableBuilder(column: $table.timeSlots, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSent =>
      $composableBuilder(column: $table.lastSent, builder: (column) => column);

  GeneratedColumn<DateTime> get nextScheduled => $composableBuilder(
    column: $table.nextScheduled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozeMinutes => $composableBuilder(
    column: $table.snoozeMinutes,
    builder: (column) => column,
  );
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
          Reminder,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> medicationId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> scheduledTime = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String?> daysOfWeek = const Value.absent(),
                Value<String?> timeSlots = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastSent = const Value.absent(),
                Value<DateTime?> nextScheduled = const Value.absent(),
                Value<int> snoozeMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                id: id,
                medicationId: medicationId,
                title: title,
                description: description,
                scheduledTime: scheduledTime,
                frequency: frequency,
                daysOfWeek: daysOfWeek,
                timeSlots: timeSlots,
                isActive: isActive,
                lastSent: lastSent,
                nextScheduled: nextScheduled,
                snoozeMinutes: snoozeMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> medicationId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime scheduledTime,
                required String frequency,
                Value<String?> daysOfWeek = const Value.absent(),
                Value<String?> timeSlots = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastSent = const Value.absent(),
                Value<DateTime?> nextScheduled = const Value.absent(),
                Value<int> snoozeMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                id: id,
                medicationId: medicationId,
                title: title,
                description: description,
                scheduledTime: scheduledTime,
                frequency: frequency,
                daysOfWeek: daysOfWeek,
                timeSlots: timeSlots,
                isActive: isActive,
                lastSent: lastSent,
                nextScheduled: nextScheduled,
                snoozeMinutes: snoozeMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
      Reminder,
      PrefetchHooks Function()
    >;
typedef $$EmergencyCardsTableCreateCompanionBuilder =
    EmergencyCardsCompanion Function({
      required String id,
      required String profileId,
      required String criticalAllergies,
      required String currentMedications,
      required String medicalConditions,
      Value<String?> emergencyContact,
      Value<String?> secondaryContact,
      Value<String?> insuranceInfo,
      Value<String?> additionalNotes,
      Value<DateTime> lastUpdated,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$EmergencyCardsTableUpdateCompanionBuilder =
    EmergencyCardsCompanion Function({
      Value<String> id,
      Value<String> profileId,
      Value<String> criticalAllergies,
      Value<String> currentMedications,
      Value<String> medicalConditions,
      Value<String?> emergencyContact,
      Value<String?> secondaryContact,
      Value<String?> insuranceInfo,
      Value<String?> additionalNotes,
      Value<DateTime> lastUpdated,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$EmergencyCardsTableFilterComposer
    extends Composer<_$AppDatabase, $EmergencyCardsTable> {
  $$EmergencyCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criticalAllergies => $composableBuilder(
    column: $table.criticalAllergies,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentMedications => $composableBuilder(
    column: $table.currentMedications,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicalConditions => $composableBuilder(
    column: $table.medicalConditions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryContact => $composableBuilder(
    column: $table.secondaryContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insuranceInfo => $composableBuilder(
    column: $table.insuranceInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get additionalNotes => $composableBuilder(
    column: $table.additionalNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmergencyCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmergencyCardsTable> {
  $$EmergencyCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criticalAllergies => $composableBuilder(
    column: $table.criticalAllergies,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentMedications => $composableBuilder(
    column: $table.currentMedications,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicalConditions => $composableBuilder(
    column: $table.medicalConditions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryContact => $composableBuilder(
    column: $table.secondaryContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insuranceInfo => $composableBuilder(
    column: $table.insuranceInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get additionalNotes => $composableBuilder(
    column: $table.additionalNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmergencyCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmergencyCardsTable> {
  $$EmergencyCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get criticalAllergies => $composableBuilder(
    column: $table.criticalAllergies,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentMedications => $composableBuilder(
    column: $table.currentMedications,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicalConditions => $composableBuilder(
    column: $table.medicalConditions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emergencyContact => $composableBuilder(
    column: $table.emergencyContact,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondaryContact => $composableBuilder(
    column: $table.secondaryContact,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insuranceInfo => $composableBuilder(
    column: $table.insuranceInfo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get additionalNotes => $composableBuilder(
    column: $table.additionalNotes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$EmergencyCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmergencyCardsTable,
          EmergencyCard,
          $$EmergencyCardsTableFilterComposer,
          $$EmergencyCardsTableOrderingComposer,
          $$EmergencyCardsTableAnnotationComposer,
          $$EmergencyCardsTableCreateCompanionBuilder,
          $$EmergencyCardsTableUpdateCompanionBuilder,
          (
            EmergencyCard,
            BaseReferences<_$AppDatabase, $EmergencyCardsTable, EmergencyCard>,
          ),
          EmergencyCard,
          PrefetchHooks Function()
        > {
  $$EmergencyCardsTableTableManager(
    _$AppDatabase db,
    $EmergencyCardsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmergencyCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmergencyCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmergencyCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String> criticalAllergies = const Value.absent(),
                Value<String> currentMedications = const Value.absent(),
                Value<String> medicalConditions = const Value.absent(),
                Value<String?> emergencyContact = const Value.absent(),
                Value<String?> secondaryContact = const Value.absent(),
                Value<String?> insuranceInfo = const Value.absent(),
                Value<String?> additionalNotes = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmergencyCardsCompanion(
                id: id,
                profileId: profileId,
                criticalAllergies: criticalAllergies,
                currentMedications: currentMedications,
                medicalConditions: medicalConditions,
                emergencyContact: emergencyContact,
                secondaryContact: secondaryContact,
                insuranceInfo: insuranceInfo,
                additionalNotes: additionalNotes,
                lastUpdated: lastUpdated,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String profileId,
                required String criticalAllergies,
                required String currentMedications,
                required String medicalConditions,
                Value<String?> emergencyContact = const Value.absent(),
                Value<String?> secondaryContact = const Value.absent(),
                Value<String?> insuranceInfo = const Value.absent(),
                Value<String?> additionalNotes = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmergencyCardsCompanion.insert(
                id: id,
                profileId: profileId,
                criticalAllergies: criticalAllergies,
                currentMedications: currentMedications,
                medicalConditions: medicalConditions,
                emergencyContact: emergencyContact,
                secondaryContact: secondaryContact,
                insuranceInfo: insuranceInfo,
                additionalNotes: additionalNotes,
                lastUpdated: lastUpdated,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EmergencyCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmergencyCardsTable,
      EmergencyCard,
      $$EmergencyCardsTableFilterComposer,
      $$EmergencyCardsTableOrderingComposer,
      $$EmergencyCardsTableAnnotationComposer,
      $$EmergencyCardsTableCreateCompanionBuilder,
      $$EmergencyCardsTableUpdateCompanionBuilder,
      (
        EmergencyCard,
        BaseReferences<_$AppDatabase, $EmergencyCardsTable, EmergencyCard>,
      ),
      EmergencyCard,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FamilyMemberProfilesTableTableManager get familyMemberProfiles =>
      $$FamilyMemberProfilesTableTableManager(_db, _db.familyMemberProfiles);
  $$MedicalRecordsTableTableManager get medicalRecords =>
      $$MedicalRecordsTableTableManager(_db, _db.medicalRecords);
  $$PrescriptionsTableTableManager get prescriptions =>
      $$PrescriptionsTableTableManager(_db, _db.prescriptions);
  $$LabReportsTableTableManager get labReports =>
      $$LabReportsTableTableManager(_db, _db.labReports);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$VaccinationsTableTableManager get vaccinations =>
      $$VaccinationsTableTableManager(_db, _db.vaccinations);
  $$AllergiesTableTableManager get allergies =>
      $$AllergiesTableTableManager(_db, _db.allergies);
  $$ChronicConditionsTableTableManager get chronicConditions =>
      $$ChronicConditionsTableTableManager(_db, _db.chronicConditions);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$EmergencyCardsTableTableManager get emergencyCards =>
      $$EmergencyCardsTableTableManager(_db, _db.emergencyCards);
}
