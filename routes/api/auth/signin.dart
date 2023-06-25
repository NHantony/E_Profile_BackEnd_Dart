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

  final email = pick(json, 'email').asStringOrNull();
  final password = pick(json, 'password').asStringOrNull();

  if (email == null) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Thiếu email',
    );
  }

  if (password == null) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Thiếu password',
    );
  }

  if (!EmailValidator.validate(email)) {
    return Response(
      statusCode: HttpStatus.badRequest,
      body: 'Email không hợp lệ',
    );
  }

  final db = await context.read<MongoDBService>().database;
  final collection = db.collection('Account');

  final user = await collection.findOne(where.eq('email', email));

  if (user == null) {
    return Response(
      statusCode: HttpStatus.forbidden,
      body: 'Tài khoản không tồn tại',
    );
  }

  final id = (user['_id'] as ObjectId).$oid;
  final salt = pick(user, 'salt').asStringOrNull() ?? '';
  final userPassword = pick(user, 'password').asStringOrNull() ?? '';

  final hashedPassword = hashPassword(password, salt);

  if (userPassword != hashedPassword) {
    return Response(
      statusCode: HttpStatus.forbidden,
      body: 'Mật khẩu không đúng',
    );
  }

  final token = generateToken(id);

  return Response(body: token);
}
