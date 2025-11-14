import 'package:evenloc/database/database.dart'; 

class Event {
  final String? id; 
  final String title;
  final String description; 
  final String date;
  final String location;
  final String type;
  
  final double? latitude;
  final double? longitude;

  Event({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.type,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnId: id != null ? int.parse(id!) : null, 
      DatabaseHelper.columnNome: title,
      DatabaseHelper.columnData: date,
      DatabaseHelper.columnDescricao: description,
      DatabaseHelper.columnLocal: location, 
      DatabaseHelper.columnTipo: type, 
      DatabaseHelper.columnLatitude: latitude,
      DatabaseHelper.columnLongitude: longitude,
    };
  }

  // 2. Converte Map em Event (Para LER do banco)
  factory Event.fromMap(Map<String, dynamic> map) {
    // Lógica para lidar com a conversão de INTEGER para DOUBLE para Lat/Lng do SQFlite
    final double? parsedLatitude = map[DatabaseHelper.columnLatitude] is int
        ? (map[DatabaseHelper.columnLatitude] as int?)?.toDouble()
        : map[DatabaseHelper.columnLatitude] as double?;

    final double? parsedLongitude = map[DatabaseHelper.columnLongitude] is int
        ? (map[DatabaseHelper.columnLongitude] as int?)?.toDouble()
        : map[DatabaseHelper.columnLongitude] as double?;

    return Event(
      // Converte o ID INTEGER do banco para String
      id: map[DatabaseHelper.columnId]?.toString(), 
      title: map[DatabaseHelper.columnNome] as String,
      date: map[DatabaseHelper.columnData] as String,
      
      // Mapeamento Direto. Assume que estas colunas existem no Map.
      // O '??' garante um valor default caso o campo não exista ou seja nulo (para evitar crash).
      description: map[DatabaseHelper.columnDescricao] as String? ?? 'Sem descrição',
      location: map[DatabaseHelper.columnLocal] as String? ?? 'Local não informado', 
      type: map[DatabaseHelper.columnTipo] as String? ?? 'Outro',
      
      latitude: parsedLatitude,
      longitude: parsedLongitude,
    );
  }
}

extension EventCopyWith on Event {
  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? location,
    String? type,
    double? latitude,
    double? longitude,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}