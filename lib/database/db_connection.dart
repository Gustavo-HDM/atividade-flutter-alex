import 'package:postgres/postgres.dart';

class DBConnection {
  static Connection? _connection;

  static Future<Connection> getConnection() async {
    if (_connection != null) return _connection!;

    _connection = await Connection.open(
      Endpoint(
        host: '10.0.2.2',
        port: 5432,
        database: 'sistema_compras',
        username: 'postgres',
        password: 'postgres',
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );

    return _connection!;
  }
}
