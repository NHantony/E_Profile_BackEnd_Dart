// import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
// import 'package:mongo_dart/mongo_dart.dart';
// import 'package:quiz_backend/Core/Utils.dart';
// import 'package:quiz_backend/Models/UserModel.dart';
// import 'package:quiz_backend/Services/MongoDBService.dart';

Handler middleware(Handler handler) {
  return handler;
}

// Middleware handleAuth() {
//   return (Handler handler) {
//     return (RequestContext context) async {
//       // final headers = context.request.headers;
//       // final authHeader = headers['authorization'];

//       // if (authHeader == null || authHeader.length < 8) {
//       //   return Response(
//       //     statusCode: HttpStatus.unauthorized,
//       //     body: 'Unauthorized',
//       //   );
//       // }
//       // final token = authHeader.substring(7);

//       // final jwt = verityToken(token);

//       // if (jwt == null) {
//       //   return Response(
//       //     statusCode: HttpStatus.unauthorized,
//       //     body: 'Unauthorized',
//       //   );
//       // }

//       // final id = jwt.subject as String;
//       // final db = await context.read<MongoDBService>().database;
//       // final collection = db.collection('User');

//       // final user = await collection.findOne(where.eq('_id', ObjectId.fromHexString(id)));

//       // final userModel = UserModel.fromMap(user as Map<String, dynamic>);

//       // return handler(context.provide<UserModel>(() => userModel));
//     };
//   };
// }
