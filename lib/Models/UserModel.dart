// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.isAdmin,
  });

  final ObjectId id;
  final String email;
  final String username;
  final bool isAdmin;

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] as ObjectId,
      email: map['email'] as String,
      username: map['username'] as String,
      isAdmin: map['isAdmin'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': id.$oid,
      'email': email,
      'username': username,
      'isAdmin': isAdmin,
    };
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) {
    return UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
  }
}
