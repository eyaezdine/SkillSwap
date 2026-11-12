enum SkillType {
  offered,
  wanted;

  String toJson() => name;

  static SkillType fromJson(String? value) {
    return SkillType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SkillType.offered,
    );
  }
}
