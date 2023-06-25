import 'package:mongo_dart/mongo_dart.dart';

import '../Constraints.dart';

class MongoDBService {
  factory MongoDBService() => _instance;

  MongoDBService._internal() : _database = Db(mongoDBUrl);

  static final MongoDBService _instance = MongoDBService._internal();

  final Db _database;

  Future<Db> get database => _openConnection();

  Future<Db> _openConnection() async {
    if (_database.isConnected) return _database;
    await _database.open();

    return _database;
  }
}
