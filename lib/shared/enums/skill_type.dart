/// Represents whether a skill is offered (can teach) or wanted (wants to learn).
enum SkillType {
  offered,
  wanted;

  /// Serializes [SkillType] to a Firestore-compatible string value.
  String toJson() => name; // 'offered' | 'wanted'

  /// Deserializes a string stored in Firestore back into a [SkillType].
  ///
  /// Falls back to [SkillType.offered] for any unknown or null value so that
  /// missing / corrupt data never causes a runtime exception.
  static SkillType fromJson(String? value) {
    return SkillType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SkillType.offered,
    );
  }
}

