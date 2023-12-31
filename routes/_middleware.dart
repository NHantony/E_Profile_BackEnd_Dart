import 'package:dart_frog/dart_frog.dart';
import 'package:quiz_backend/Services/MongoDBService.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

// final mongoDBService = MongoDBService();

Handler middleware(Handler handler) {
  return handler
      .use(
        fromShelfMiddleware(corsHeaders()),
      )
      .use(requestLogger());
  // .use(provider<MongoDBService>((context) => mongoDBService));
}
