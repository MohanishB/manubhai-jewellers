import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum UserRole { cse, storeKeeper }

class AuthUser extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String firebaseId;
  final UserRole role;

  const AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.firebaseId,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final data = json['cse_detail'] ?? {};

    String _toString(dynamic v) => v?.toString() ?? '';
    final userType = (data['user_type'] ?? '').toString();

 
    final role = userType == 'SAFE'
        ? UserRole.storeKeeper
        : UserRole.cse;

    
    return AuthUser(
      id: _toString(data['cse_id']),
      firstName: _toString(data['cse_fname']),
      lastName: _toString(data['cse_lname']),
      email: _toString(data['cse_email']),
      phone: _toString(data['cse_phone']),
      firebaseId: _toString(data['cse_firebase_id']),
      role: role,
    );
  }

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone, firebaseId, role];
   @override
  String toString() {
    return 'AuthUser(id: $id, name: $firstName $lastName, email: $email, phone: $phone, role: ${role.name})';
  }
}
