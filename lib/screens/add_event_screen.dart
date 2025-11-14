import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/event_model.dart';
import '../providers/event_provider.dart';

class AddEventScreen extends StatefulWidget {
  final Event? event;

  const AddEventScreen({super.key, this.event});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _dateController;
  late final TextEditingController _descriptionController;
  
  String? _eventType;

  final dateMaskFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.event?.title ?? '');
    _locationController =
        TextEditingController(text: widget.event?.location ?? '');
    _eventType = widget.event?.type;
    _dateController = 
        TextEditingController(text: widget.event?.date ?? '');
    _descriptionController = 
        TextEditingController(text: widget.event?.description ?? ''); 
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    int? maxLines = 1,
    String? helperText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        helperText: helperText,
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildEventTypeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _eventType,
      hint: const Text('Tipo de Evento'),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      items: ['Congresso', 'Simpósio', 'Palestra', 'Formatura', 'Confraternização', 'Outro']
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) => setState(() => _eventType = value),
      validator: (value) => value == null ? 'Por favor, selecione um tipo' : null,
    );
  }

  Widget _buildDateButton(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Data do Evento',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _showDatePicker(context),
        ),
      ),
      readOnly: true,
      onTap: () => _showDatePicker(context),
      inputFormatters: [dateMaskFormatter],
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final initialDate = DateTime.now();
    
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Selecionar Data Única'),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                    });
                    Navigator.pop(ctx);
                  }
                },
              ),
              ListTile(
                title: const Text('Selecionar Intervalo de Datas'),
                onTap: () async {
                  final pickedRange = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    initialDateRange: DateTimeRange(
                      start: initialDate,
                      end: initialDate.add(const Duration(days: 1)),
                    ),
                  );
                  if (pickedRange != null) {
                    final startDate = "${pickedRange.start.day.toString().padLeft(2, '0')}/${pickedRange.start.month.toString().padLeft(2, '0')}/${pickedRange.start.year}";
                    final endDate = "${pickedRange.end.day.toString().padLeft(2, '0')}/${pickedRange.end.month.toString().padLeft(2, '0')}/${pickedRange.end.year}";
                    setState(() {
                      _dateController.text = "$startDate - $endDate";
                    });
                     Navigator.pop(ctx);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          
          final eventData = Event(
            id: widget.event?.id, 
            title: _titleController.text,
            type: _eventType ?? 'Outro',
            date: _dateController.text.isEmpty 
                    ? 'Data não informada' 
                    : _dateController.text,
            location: _locationController.text,
            
            description: _descriptionController.text.isEmpty 
                    ? 'Sem descrição' 
                    : _descriptionController.text,
            
            // Passa as coordenadas existentes para o provider.
            // O provider só fará o Geocoding se location tiver mudado
            latitude: widget.event?.latitude, 
            longitude: widget.event?.longitude,
          );

          final provider = Provider.of<EventProvider>(context, listen: false);

          if (widget.event != null) {
            // Modo Edição
            provider.updateEvent(eventData);
          } else {
            // Modo Adição
            provider.addEvent(eventData);
          }

          Navigator.pop(context);
        }
      },
      child: Text(widget.event != null ? 'Salvar Alterações' : 'Salvar Evento'),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Editar Evento' : 'Novo Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Título do Evento',
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira um título' : null,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _descriptionController,
                label: 'Descrição Detalhada',
                validator: (value) =>
                    value!.isEmpty ? 'Por favor, insira uma descrição' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _locationController,
                label: 'Local',
                validator: (value) =>
                  value!.isEmpty ? 'Por favor, insira um local' : null,
                  helperText: 'Formato: Rua, Número, Cidade, Estado.',
              ),
              const SizedBox(height: 16),
              _buildEventTypeDropdown(),
              const SizedBox(height: 16),
              _buildDateButton(context),
              const SizedBox(height: 32),
              _buildSaveButton(context),
            ],
          ),
        ),
      ),
    );
  }
}