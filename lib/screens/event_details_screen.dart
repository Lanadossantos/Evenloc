import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';
import 'event_map_screen.dart';
import 'add_event_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  Widget _buildEventInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          event.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Chip(
          label: Text(event.type),
          backgroundColor: Colors.blueGrey[100],
          labelStyle: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'SOBRE O EVENTO',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          event.description,
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: 16),

        _buildDetailRow(
          icon: Icons.calendar_today,
          label: 'Data',
          value: event.date,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          icon: Icons.location_on,
          label: 'Local',
          value: event.location,
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.indigo, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(value, softWrap: true),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoverImage(),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildEventInfo(), const SizedBox(height: 30)],
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: const Text(
        'Detalhes do Evento',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildCoverImage() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage(
            'https://via.placeholder.com/600x200.png?text=Event+Image',
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildButton(
          context,
          label: 'Editar',
          color: Colors.grey[200],
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEventScreen(event: event)),
            );
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 12),
        _buildButton(
          context,
          label: 'Deletar',
          color: Colors.red[100],
          onTap: () {
            if (event.id != null) {
              Provider.of<EventProvider>(
                context,
                listen: false,
              ).deleteEvent(event.id!);
            }
            // Feche a tela
            Navigator.pop(context);
          },
        ),
        const SizedBox(height: 12),
        _buildButton(
          context,
          label: 'Ver no Mapa',
          color: Colors.blue[100],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventMapScreen(event: event)),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    required Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: label == 'Deletar' ? Colors.red[900] : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
