/// Coerces an app-side `LogEntry.data` map into what Google Analytics will
/// actually accept.
///
/// GA4's limits are silent: an event carrying a too-long name, a `firebase_`
/// prefix, a 26th parameter or a `bool` value is not rejected loudly - it is
/// dropped, or the offending parameter is, and the only symptom is a figure
/// that never shows up in the dashboard. So the rules are enforced here, once,
/// rather than at the 51 call sites that hand data to `Log.action`.
abstract class AnalyticsParameters {
  static const int maxEventNameLength = 40;
  static const int maxParameterNameLength = 40;
  static const int maxParameterValueLength = 100;
  static const int maxParameterCount = 25;

  // GA4 owns these prefixes and silently discards anything using them.
  static const List<String> _reservedPrefixes = ['firebase_', 'google_', 'ga_'];

  static String eventName(String name) {
    final sanitized = _sanitizeName(name, maxEventNameLength);
    return sanitized.isEmpty ? 'unnamed_event' : sanitized;
  }

  /// A screen name is a free-form label, not an identifier - `AppRoute` names
  /// are camelCase and stay that way, since they read back in the dashboard as
  /// the route the code calls them. Only the length limit applies.
  static String screenName(String name) => _truncate(name, maxParameterValueLength);

  /// Null for a parameter GA4 cannot represent, which the caller drops rather
  /// than coercing to a lie: a `DateTime` stringifies happily but a `null` value
  /// has no honest representation, and inventing 0 or "" for it would report a
  /// measurement that never happened.
  static Object? value(Object? raw) => switch (raw) {
    null => null,
    final num number => number,
    final bool flag => flag.toString(),
    final String text => _truncate(text, maxParameterValueLength),
    _ => _truncate(raw.toString(), maxParameterValueLength),
  };

  static Map<String, Object> sanitize(Map<String, Object?> data) {
    final sanitized = <String, Object>{};
    for (final entry in data.entries) {
      if (sanitized.length == maxParameterCount) {
        break;
      }
      final name = _sanitizeName(entry.key, maxParameterNameLength);
      final sanitizedValue = value(entry.value);
      if (name.isEmpty || sanitizedValue == null) {
        continue;
      }
      sanitized[name] = sanitizedValue;
    }
    return sanitized;
  }

  // GA4 accepts letters, digits and underscores, and the name must start with a
  // letter. Everything else folds to an underscore rather than being stripped,
  // so `food.log-deleted` and `food_log_deleted` stay distinguishable.
  static String _sanitizeName(String name, int maxLength) {
    var sanitized = name.toLowerCase().replaceAll(RegExp('[^a-z0-9_]'), '_');
    for (final prefix in _reservedPrefixes) {
      if (sanitized.startsWith(prefix)) {
        sanitized = sanitized.substring(prefix.length);
      }
    }
    sanitized = sanitized.replaceFirst(RegExp('^[^a-z]+'), '');
    return _truncate(sanitized, maxLength);
  }

  static String _truncate(String text, int maxLength) => text.length <= maxLength ? text : text.substring(0, maxLength);
}
