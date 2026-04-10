class AppUserModel {
  AppUserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl = '',
    this.provider = 'email',
    required this.createdAt,
    this.disabled = false,
  });

  /// Firebase Auth–style user id; also used as the Firestore document id.
  final String uid;

  /// Same as [uid] — kept for call sites that use `user.id`.
  String get id => uid;

  final String displayName;
  final String email;
  final String photoUrl;
  final String provider;
  final DateTime createdAt;

  /// Admin panel only; stored in Firestore as `disabled` when present.
  final bool disabled;

  AppUserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoUrl,
    String? provider,
    DateTime? createdAt,
    bool? disabled,
  }) {
    return AppUserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
      disabled: disabled ?? this.disabled,
    );
  }
}
