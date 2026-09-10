import 'package:equatable/equatable.dart';

enum UserRole { cse, storeKeeper }

class AuthUser extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String firebaseId;
  final UserRole role;

  /// MLT context returned by cse_login_log.php.
  ///
  /// Keeping this on the authenticated user makes the context available even
  /// when the user goes straight to stock search without loading dashboard
  /// filters first.
  final String cseMltBranch;
  final List<String> cseMltLocation;

  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.firebaseId,
    required this.role,
    this.cseMltBranch = '',
    this.cseMltLocation = const [],
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final data = json['cse_detail'] ?? {};

    String toText(dynamic value) => value?.toString() ?? '';
    final userType = (data['user_type'] ?? '').toString();

    final role =
        userType == 'SAFE' ? UserRole.storeKeeper : UserRole.cse;

    final locations = data['cse_mlt_location'] is List
        ? (data['cse_mlt_location'] as List)
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];

    return AuthUser(
      id: toText(data['cse_id']),
      firstName: toText(data['cse_fname']),
      lastName: toText(data['cse_lname']),
      email: toText(data['cse_email']),
      phone: toText(data['cse_phone']),
      firebaseId: toText(data['cse_firebase_id']),
      role: role,
      cseMltBranch: toText(data['cse_mlt_branch']).trim(),
      cseMltLocation: locations,
    );
  }

  AuthUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? firebaseId,
    UserRole? role,
    String? cseMltBranch,
    List<String>? cseMltLocation,
  }) {
    return AuthUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      firebaseId: firebaseId ?? this.firebaseId,
      role: role ?? this.role,
      cseMltBranch: cseMltBranch ?? this.cseMltBranch,
      cseMltLocation:
          cseMltLocation ?? List<String>.from(this.cseMltLocation),
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        firebaseId,
        role,
        cseMltBranch,
        cseMltLocation,
      ];

  @override
  String toString() {
    return 'AuthUser(id: $id, name: $firstName $lastName, email: $email, '
        'phone: $phone, role: ${role.name}, cseMltBranch: $cseMltBranch, '
        'cseMltLocation: $cseMltLocation)';
  }
}
