/// Represents the possible statuses of a [SkillSwapRequest].
///
/// Tracks the lifecycle of a request from creation to resolution.
enum RequestStatus {
  /// The request has been sent and is awaiting a response from the receiver.
  pending,

  /// The receiver has accepted the request. A [SkillSwap] will be created.
  accepted,

  /// The receiver has rejected the request.
  rejected,

  /// The request was withdrawn by the sender before any response.
  cancelled,

  /// The exchange was finalized and both parties completed the swap.
  completed;

  String toJson() => name;

  static RequestStatus fromJson(String? value) {
    return RequestStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RequestStatus.pending,
    );
  }
}
