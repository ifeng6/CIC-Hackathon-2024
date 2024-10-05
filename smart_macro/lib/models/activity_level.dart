enum ActivityLevel {
  low,
  medium,
  high,
  veryHigh
}

// Optional: Convert the enum to a readable string if needed
String activityLevelToString(ActivityLevel level) {
  switch (level) {
    case ActivityLevel.low:
      return 'Low';
    case ActivityLevel.medium:
      return 'Medium';
    case ActivityLevel.high:
      return 'High';
    case ActivityLevel.veryHigh:
      return 'Very High';
  }
}

// Optional: Convert string back to enum
ActivityLevel stringToActivityLevel(String value) {
  switch (value) {
    case 'Low':
      return ActivityLevel.low;
    case 'Medium':
      return ActivityLevel.medium;
    case 'High':
      return ActivityLevel.high;
    case 'Very High':
      return ActivityLevel.veryHigh;
    default:
      return ActivityLevel.low; // Fallback
  }
}
