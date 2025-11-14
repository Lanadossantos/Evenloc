import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'providers/event_provider.dart'; 
import 'screens/event_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: const AgendaEventosApp(),
    ),
  );
}

class AgendaEventosApp extends StatelessWidget {
  const AgendaEventosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvenLoc',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EventListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

