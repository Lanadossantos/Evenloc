import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../models/event_model.dart';
import 'add_event_screen.dart';
import 'event_details_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
        Provider.of<EventProvider>(context, listen: false).carregarEventos());
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final allEvents = eventProvider.events;

    final filteredEvents = allEvents
        .where(
          (e) => e.title.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: const Color.fromARGB(255, 246, 239, 239),
      floatingActionButton: _buildFloatingButton(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 10),
            _buildEventList(filteredEvents),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('EvenLoc', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      elevation: 4,
      centerTitle: true,
      backgroundColor: Colors.black,
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      shape: const CircleBorder(),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEventScreen()),
        );
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Buscar evento...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (value) => setState(() => searchQuery = value),
    );
  }

  Widget _buildEventList(List<Event> filteredEvents) {
    if (filteredEvents.isEmpty) {
      return const Expanded(
        child: Center(child: Text('Nenhum evento encontrado.')),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          event.title, 
          style: const TextStyle(fontWeight: FontWeight.bold),
        ), 
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '🗓️ ${event.date}',
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              '📍 ${event.location}', 
              style: const TextStyle(color: Colors.black87, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        
        trailing: Chip(
          label: Text(event.type),
          backgroundColor: Colors.black,
          labelStyle: const TextStyle(
            fontSize: 12,
            color: Colors.white, 
          ),
        ),
        
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailsScreen(event: event),
            ),
          );
        },
      ),
    );
  }
}