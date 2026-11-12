/// Represents the meeting mode of a [Session].
///
/// Determines whether the session takes place physically,
/// remotely, or a combination of both.
enum SessionMode {
  /// The session takes place remotely via a meeting link (e.g. Zoom, Meet).
  online,

  /// The session takes place at a physical location.
  inPerson,

  /// The session combines a physical location and an online meeting link.
  hybrid;

  String toJson() => name;

  static SessionMode fromJson(String? value) {
    return SessionMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SessionMode.online,
    );
  }
}
