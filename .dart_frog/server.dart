// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import '../main.dart' as entrypoint;
import '../routes/index.dart' as index;
import '../routes/api/v1/index.dart' as api_v1_index;
import '../routes/api/auth/signin.dart' as api_auth_signin;
import '../routes/api/auth/register.dart' as api_auth_register;
import '../routes/api/auth/credential-state.dart' as api_auth_credential_state;

import '../routes/_middleware.dart' as middleware;
import '../routes/api/v1/_middleware.dart' as api_v1_middleware;

void main() async {
  final address = InternetAddress.anyIPv6;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  hotReload(() => createServer(address, port));
}

Future<HttpServer> createServer(InternetAddress address, int port) {
  final handler = Cascade().add(buildRootHandler()).handler;
  return entrypoint.run(handler, address, port);
}

Handler buildRootHandler() {
  final pipeline = const Pipeline().addMiddleware(middleware.middleware);
  final router = Router()
    ..mount('/api/auth', (context) => buildApiAuthHandler()(context))
    ..mount('/api/v1', (context) => buildApiV1Handler()(context))
    ..mount('/', (context) => buildHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildApiAuthHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/signin', (context) => api_auth_signin.onRequest(context,))..all('/register', (context) => api_auth_register.onRequest(context,))..all('/credential-state', (context) => api_auth_credential_state.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildApiV1Handler() {
  final pipeline = const Pipeline().addMiddleware(api_v1_middleware.middleware);
  final router = Router()
    ..all('/', (context) => api_v1_index.onRequest(context,));
  return pipeline.addHandler(router);
}

Handler buildHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/', (context) => index.onRequest(context,));
  return pipeline.addHandler(router);
}
