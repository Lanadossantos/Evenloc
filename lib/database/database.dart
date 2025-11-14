import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Evento {
int? id;
  String nome;
  String data;
  String descricao;
  String local; 
  String tipo; 
  double? latitude;
  double? longitude;

  Evento({
    this.id,
    required this.nome,
    required this.data,
    required this.descricao,
    required this.local, 
    required this.tipo, 
    this.latitude,
    this.longitude,
  });

  // Converte um Evento em um Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'data': data,
      'descricao': descricao,
      'local': local, 
      'tipo': tipo, 
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Converte um Map em um Evento (para ler do banco)
  factory Evento.fromMap(Map<String, dynamic> map) {
    return Evento(
      id: map[DatabaseHelper.columnId],
      nome: map[DatabaseHelper.columnNome],
      data: map[DatabaseHelper.columnData],
      descricao: map[DatabaseHelper.columnDescricao],
      local: map[DatabaseHelper.columnLocal] ?? 'Local não informado', 
      tipo: map[DatabaseHelper.columnTipo] ?? 'Outro',
      latitude: map[DatabaseHelper.columnLatitude],
      longitude: map[DatabaseHelper.columnLongitude],
    );
  }
}

class DatabaseHelper {
  static const _databaseName = "Eventos.db";
  static const _databaseVersion = 2; 

  static const table = 'eventos_table';

  //colunas
  static const columnId = 'id';
  static const columnNome = 'nome';
  static const columnData = 'data';
  static const columnDescricao = 'descricao';
  static const columnLocal = 'local'; 
  static const columnTipo = 'tipo'; 
  static const columnLatitude = 'latitude';
  static const columnLongitude = 'longitude';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
  if (_database != null) return _database!;
    _database = await _initDatabase();
  return _database!;
  }

  _initDatabase() async {
   String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table ( 
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnNome TEXT NOT NULL,
        $columnData TEXT NOT NULL,
        $columnDescricao TEXT NOT NULL,
        $columnLocal TEXT,
        $columnTipo TEXT, 
        $columnLatitude REAL,
        $columnLongitude REAL
      )
  ''');
 }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE $table ADD COLUMN $columnLocal TEXT");
      await db.execute("ALTER TABLE $table ADD COLUMN $columnTipo TEXT");
    }
  }

  Future<int> inserir(Evento evento) async {
    Database db = await instance.database;
    return await db.insert(table, evento.toMap());
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> atualizar(Evento evento) async {
    Database db = await instance.database;
    int id = evento.id!;
    return await db.update(table, evento.toMap(), where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deletar(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}