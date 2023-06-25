import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:quiz_backend/Core/Utils.dart';
import 'package:quiz_backend/Services/MongoDBService.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;

  switch (method) {
    case HttpMethod.get:
      return _onGetRequest(context);
    default:
      return Response(
        statusCode: HttpStatus.methodNotAllowed,
        body: 'Method now allowed.',
      );
  }
}

Future<Response> _onGetRequest(RequestContext context) async {
  final headers = context.request.headers;
  final authHeader = headers['authorization'];

  if (authHeader == null || authHeader.length < 8) {
    return Response(
      statusCode: HttpStatus.unauthorized,
      body: 'Unauthorized',
    );
  }
  final token = authHeader.substring(7);

  final jwt = verityToken(token);

  if (jwt == null) {
    return Response(
      statusCode: HttpStatus.unauthorized,
      body: 'Unauthorized',
    );
  }

  final id = jwt.subject as String;
  final db = await context.read<MongoDBService>().database;
  final collection = db.collection('Account');

  final aggregate = await collection.aggregateToStream([
    {
      r'$match': {'_id': ObjectId.fromHexString(id)}
    },
    {r'$limit': 1},
    {
      r'$lookup': {
        'from': 'Company',
        'let': {'id': r'$_id'},
        'pipeline': [
          {
            r'$match': {
              r'$expr': {
                r'$eq': [r'$account', r'$$id']
              }
            }
          },
          {r'$limit': 1}
        ],
        'as': 'companyLookup'
      }
    },
    {
      r'$lookup': {
        'from': 'Student',
        'let': {'id': r'$_id'},
        'pipeline': [
          {
            r'$match': {
              r'$expr': {
                r'$eq': [r'$account', r'$$id']
              }
            }
          },
          {r'$limit': 1}
        ],
        'as': 'studentLookup'
      }
    },
    {
      r'$addFields': {
        'credential': {
          r'$setUnion': [r'$companyLookup', r'$studentLookup']
        }
      }
    },
    {r'$unwind': r'$credential'},
    {
      r'$project': {'password': 0, 'salt': 0, 'companyLookup': 0, 'studentLookup': 0}
    }
  ]).toList();

  return Response.json(body: aggregate);
}
