import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:quiz_backend/Services/MongoDBService.dart';

Future<HttpServer> run(Handler handler, InternetAddress ip, int port) async {
  final mongoDBService = MongoDBService();
  print('Connecting Database...');
  await mongoDBService.database;
  print('Database Connected!');

  return serve(
    handler.use(provider<MongoDBService>((_) => mongoDBService)),
    ip,
    port,
  );
}
