// ignore_for_file: avoid_dynamic_calls

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:deep_pick/deep_pick.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:quiz_backend/Services/MongoDBService.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;
  final json = await context.request.json();
  final collectionName = pick(json, 'collection').asStringOrThrow();
  final db = await context.read<MongoDBService>().database;
  final collection = db.collection(collectionName);

  switch (method) {
    case HttpMethod.post:
      return _onPostRequest(context, db, collection, json);
    case HttpMethod.put:
      return _onPutRequest(context, db, collection, json);
    case HttpMethod.patch:
      return _onPatchRequest(context, db, collection, json);
    case HttpMethod.delete:
      return _onDeleteRequest(context, db, collection, json);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _onPostRequest(
  RequestContext context,
  Db db,
  DbCollection collection,
  dynamic json,
) async {
  try {
    final pipeline = pick(json, 'pipeline')
        .asListOrEmpty((item) => item.asMapOrEmpty<String, Object>());

    if (pipeline.isEmpty) return Response.json(body: []);

    if ((pipeline[0]['\$match'] as Map).containsKey(":company")) {
      final matchStage = {
        r'$match': {
          ...(pipeline[0]['\$match'] as Map),
          'company': ObjectId.fromHexString(
              (pipeline[0]['\$match'] as Map)[':company'] as String)
        }
      };

      (matchStage['\$match'] as Map).remove(':company');

      pipeline[0] = matchStage;
    }
    print(pipeline);

    final aggregate = await collection.aggregateToStream(pipeline).toList();

    return Response.json(body: aggregate);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: e.toString(),
    );
  }
}

Future<Response> _onPutRequest(
  RequestContext context,
  Db db,
  DbCollection collection,
  dynamic json,
) async {
  try {
    final document = pick(json, 'document').asMapOrEmpty<String, Object>();

    if (document.isEmpty) return Response(statusCode: HttpStatus.badRequest);

    final parseDocument = document.entries.fold(
      <String, Object>{},
      (previousValue, field) => {
        ...previousValue,
        field.key: field.value is String &&
                ObjectId.tryParse(field.value as String) != null
            ? ObjectId.tryParse(field.value as String) as ObjectId
            : field.value
      },
    );

    final writeResult = await collection.insertOne(parseDocument);

    return Response.json(body: writeResult.document);
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: e.toString(),
    );
  }
}

Future<Response> _onPatchRequest(
  RequestContext context,
  Db db,
  DbCollection collection,
  dynamic json,
) async {
  try {
    final idHexString = pick(json, '_id').asStringOrNull() ?? '';
    final modifyObject = pick(json, 'modify').asMapOrEmpty<String, Object>();
    final pushObject = pick(json, 'push').asMapOrEmpty<String, Object>();
    final pullObject = pick(json, 'pull').asMapOrEmpty<String, Object>();

    final id = ObjectId.tryParse(idHexString);

    if (id == null || modifyObject.isEmpty)
      return Response(statusCode: HttpStatus.badRequest);

    final modifier = modify;

    for (final entry in modifyObject.entries) {
      modifier.set(entry.key, entry.value);
    }

    for (final entry in pushObject.entries) {
      modifier.push(entry.key, entry.value);
    }

    for (final entry in pullObject.entries) {
      modifier.pull(entry.key, entry.value);
    }

    await collection.updateOne(where.eq('_id', id), modifier);

    return Response();
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: e.toString(),
    );
  }
}

Future<Response> _onDeleteRequest(
  RequestContext context,
  Db db,
  DbCollection collection,
  dynamic json,
) async {
  try {
    final idHexString = pick(json, '_id').asStringOrThrow();
    final id = ObjectId.tryParse(idHexString);

    await collection.deleteOne(where.eq('_id', id));

    return Response();
  } catch (e) {
    return Response(
      statusCode: HttpStatus.internalServerError,
      body: e.toString(),
    );
  }
}
