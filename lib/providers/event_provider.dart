import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart'; 
import '../models/event_model.dart';
import 'package:evenloc/database/database.dart'; 
import 'dart:developer';

class EventProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Event> _events = [];

  List<Event> get events {
    return [..._events];
  }


  Future<List<Location>?> _getCoordinatesFromAddress(String address) async {
    final trimmedAddress = address.trim(); 
    
    if (trimmedAddress.isEmpty) return null;
    
    try {

      final locations = await locationFromAddress(trimmedAddress);
      
      return locations;
    } catch (e) {
      log("Erro ao obter coordenadas para '$trimmedAddress': $e", name: 'Geocoding'); 
      return null;
    }
  }

  Future<Event> _processEventWithCoordinates(Event event) async {
    if (event.location.trim().isEmpty) return event;
    if (event.latitude != null && event.longitude != null) {
      return event;
    }

    final locations = await _getCoordinatesFromAddress(event.location);

    if (locations != null && locations.isNotEmpty) {
      final lat = locations.first.latitude;
      final lng = locations.first.longitude;

      return event.copyWith(
        latitude: lat,
        longitude: lng,
      );
    }
    return event; 
  }



  //CRUD pegando as informações carregadas do banco
  Future<void> carregarEventos() async {
    final todasLinhas = await _dbHelper.queryAllRows();
    _events = todasLinhas.map((map) {
      final eventoDB = Evento.fromMap(map);
      
      return Event(
        id: eventoDB.id.toString(),
        title: eventoDB.nome,
        date: eventoDB.data,
        description: eventoDB.descricao,
        location: eventoDB.local,
        type: eventoDB.tipo,
        latitude: eventoDB.latitude,
        longitude: eventoDB.longitude,
      );
    }).toList();
    notifyListeners();
  }

  Future<void> addEvent(Event event) async {
    Event eventWithCoords = await _processEventWithCoordinates(event);

    //Converto para o modelo do banco
    final eventoDB = Evento(
      nome: eventWithCoords.title,
      data: eventWithCoords.date,
      descricao: eventWithCoords.description,
      local: eventWithCoords.location,
      tipo: eventWithCoords.type,
      latitude: eventWithCoords.latitude,
      longitude: eventWithCoords.longitude,
    );

    final id = await _dbHelper.inserir(eventoDB);
    final newEventWithId = eventWithCoords.copyWith(id: id.toString());
    _events.add(newEventWithId);

    notifyListeners();
  }

  Future<void> updateEvent(Event event) async {
    if (event.id == null) return; 

    Event eventWithCoords = await _processEventWithCoordinates(event);
 
    final eventoDB = Evento(
      id: int.parse(eventWithCoords.id!),
      nome: eventWithCoords.title,
      data: eventWithCoords.date,
      descricao: eventWithCoords.description,
      local: eventWithCoords.location, 
      tipo: eventWithCoords.type,      
      latitude: eventWithCoords.latitude,
      longitude: eventWithCoords.longitude,
    );

    await _dbHelper.atualizar(eventoDB);

    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = eventWithCoords;
      notifyListeners();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    await _dbHelper.deletar(int.parse(eventId));
    _events.removeWhere((event) => event.id == eventId);
    notifyListeners();
  }
}