/// A sequence of "words" describing some activity.
///
/// [SessionEnd] and [Session] both use an activity to indicate what was done
/// during the period of time they represent.
class Activity {
  /// The sequence of words that define this activity.
  ///
  /// Each element of `words` is a string with no whitespace characters
  /// (as defined by [RegExp]'s interpretation of `\s`).
  final List<String> words;

  /// The full name that defines this activity.
  ///
  /// Its value is the result of joining [words] over single space characters
  /// as separators.
  String get name => words.join(' ');

  /// Constructs an activity from a string by breaking it into [words].
  Activity(String name) : words = name.trim().split(RegExp(r'\s+'));

  @override
  bool operator ==(Object other) =>
      other is Activity &&
      other.runtimeType == runtimeType &&
      other.name == name;

  @override
  int get hashCode => name.hashCode;
}
