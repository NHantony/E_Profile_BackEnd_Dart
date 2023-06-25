import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:email_validator/email_validator.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:quiz_backend/Core/Utils.dart';
import 'package:quiz_backend/Services/MongoDBService.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  switch (method) {
    case HttpMethod.post:
      return _onPostRequest(context);
    default:
      return Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: 'Method not allowed',
      );
  }
}

Future<Response> _onPostRequest(RequestContext context) async {
  final json = await context.request.json();

  final name = pick(json, 'name').asStringOrNull();
  final email = pick(json, 'email').asStringOrNull();
  final password = pick(json, 'password').asStringOrNull();
  final role = pick(json, 'role').asIntOrNull();

  if (name == null) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Thiếu tên',
    );
  }

  if (email == null) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Thiếu email',
    );
  }

  if (password == null) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Thiếu mật khẩu',
    );
  }

  if (role == null) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Thiếu role',
    );
  }

  if (!EmailValidator.validate(email)) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Email không hợp lệ',
    );
  }

  if (password.length < 8) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Mật khẩu phải dài ít nhất 8 ký tự',
    );
  }

  final db = await context.read<MongoDBService>().database;
  final collection = db.collection('Account');

  final user = await collection.findOne(where.eq('email', email));

  if (user != null) {
    return Response(
      statusCode: HttpStatus.forbidden,
      body: 'Người dùng đã tồn tại',
    );
  }

  final salt = generateSalt();
  final hashedPassword = hashPassword(password, salt);

  final writeResult = await collection.insertOne(<String, dynamic>{
    'email': email,
    'password': hashedPassword,
    'salt': salt,
    'role': role,
  });

  await db.collection(role == 1 ? 'Student' : 'Company').insertOne({
    'name': name,
    'account': writeResult.document?['_id'],
  });

  return Response(statusCode: HttpStatus.created);
}
