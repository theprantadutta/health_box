import 'package:drift/drift.dart';

class MedicationBatches extends Table {
  TextColumn get id => text().named('id')();
  TextColumn get name => text().withLength(min: 1, max: 100).named('name')();
  TextColumn get timingType => text().named('timing_type')();
  TextColumn get timingDetails => text().nullable().named('timing_details')(); // JSON
  TextColumn get description => text().nullable().named('description')();
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true)).named('is_active')();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime).named('created_at')();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime).named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    // Name constraint (non-empty)
    'CHECK (LENGTH(TRIM(name)) > 0)',

    // Timing type constraint
    'CHECK (timing_type IN (\'after_meal\', \'before_meal\', \'fixed_time\', \'interval\', \'as_needed\'))',

    // Description constraint (if not null, non-empty)
    'CHECK (description IS NULL OR LENGTH(TRIM(description)) > 0)',
  ];
}

// Timing type constants for type safety
class MedicationBatchTimingType {
  static const String afterMeal = 'after_meal';
  static const String beforeMeal = 'before_meal';
  static const String fixedTime = 'fixed_time';
  static const String interval = 'interval';
  static const String asNeeded = 'as_needed';

  static const List<String> allTypes = [
    afterMeal,
    beforeMeal,
    fixedTime,
    interval,
    asNeeded,
  ];

  static bool isValidType(String type) {
    return allTypes.contains(type);
  }

  static String getDisplayName(String type) {
    switch (type) {
      case afterMeal:
        return 'After Meal';
      case beforeMeal:
        return 'Before Meal';
      case fixedTime:
        return 'Fixed Time';
      case interval:
        return 'Every X Hours';
      case asNeeded:
        return 'As Needed';
      default:
        return type;
    }
  }
}

// Timing details data classes for different timing types
class MealTimingDetails {
  final String mealType; // breakfast, lunch, dinner
  final int minutesAfterBefore; // minutes after/before meal

  const MealTimingDetails({
    required this.mealType,
    required this.minutesAfterBefore,
  });

  Map<String, dynamic> toJson() => {
    'meal_type': mealType,
    'minutes_after_before': minutesAfterBefore,
  };

  factory MealTimingDetails.fromJson(Map<String, dynamic> json) {
    return MealTimingDetails(
      mealType: json['meal_type'] as String,
      minutesAfterBefore: json['minutes_after_before'] as int,
    );
  }
}

class FixedTimeDetails {
  final List<String> times; // List of times in "HH:mm" format

  const FixedTimeDetails({
    required this.times,
  });

  Map<String, dynamic> toJson() => {
    'times': times,
  };

  factory FixedTimeDetails.fromJson(Map<String, dynamic> json) {
    return FixedTimeDetails(
      times: List<String>.from(json['times']),
    );
  }
}

class IntervalTimingDetails {
  final int intervalHours;
  final String? startTime; // Optional start time in "HH:mm" format
  final String? endTime; // Optional end time in "HH:mm" format

  const IntervalTimingDetails({
    required this.intervalHours,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() => {
    'interval_hours': intervalHours,
    'start_time': startTime,
    'end_time': endTime,
  };

  factory IntervalTimingDetails.fromJson(Map<String, dynamic> json) {
    return IntervalTimingDetails(
      intervalHours: json['interval_hours'] as int,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );
  }
}

// Meal type constants
class MealType {
  static const String breakfast = 'breakfast';
  static const String lunch = 'lunch';
  static const String dinner = 'dinner';
  static const String snack = 'snack';

  static const List<String> allMeals = [
    breakfast,
    lunch,
    dinner,
    snack,
  ];

  static String getDisplayName(String mealType) {
    switch (mealType) {
      case breakfast:
        return 'Breakfast';
      case lunch:
        return 'Lunch';
      case dinner:
        return 'Dinner';
      case snack:
        return 'Snack';
      default:
        return mealType;
    }
  }
}