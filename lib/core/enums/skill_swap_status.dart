/// Represents the possible statuses of a [SkillSwap] session agreement.
///
/// Tracks the lifecycle of a confirmed skill exchange between two users.
enum SkillSwapStatus {
  /// The swap is ongoing — sessions are being scheduled or conducted.
  active,

  /// All sessions have been completed and the swap is fully done.
  completed,

  /// The swap was cancelled after being accepted.
  cancelled,
}
