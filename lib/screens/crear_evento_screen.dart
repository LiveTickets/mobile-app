// crear_evento_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_app/colors.dart';
import 'dart:convert';

class CrearEventoScreen extends StatefulWidget {
  const CrearEventoScreen({super.key});

  @override
  State<CrearEventoScreen> createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _videoController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _organizerNameController = TextEditingController();

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  String _selectedCategory = 'entertainment';
  String _selectedCity = 'lima';
  bool _isFree = false;
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'value': 'entertainment', 'label': 'Entretenimiento'},
    {'value': 'music', 'label': 'Música'},
    {'value': 'sports', 'label': 'Deportes'},
    {'value': 'education', 'label': 'Educación'},
    {'value': 'business', 'label': 'Negocios'},
    {'value': 'food', 'label': 'Gastronomía'},
  ];

  final List<Map<String, String>> _cities = [
    {'value': 'lima', 'label': 'Lima'},
    {'value': 'arequipa', 'label': 'Arequipa'},
    {'value': 'cusco', 'label': 'Cusco'},
    {'value': 'trujillo', 'label': 'Trujillo'},
    {'value': 'piura', 'label': 'Piura'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _videoController.dispose();
    _imageUrlController.dispose();
    _organizerNameController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(bool esInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: appColor,
              onPrimary: Colors.white,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  Future<void> _seleccionarHora(bool esInicio) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: appColor,
              onPrimary: Colors.white,
              surface: Colors.grey,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (esInicio) {
          _horaInicio = picked;
        } else {
          _horaFin = picked;
        }
      });
    }
  }

  Map<String, dynamic> _generateEventJson() {
    final startDateTime = DateTime(
      _fechaInicio!.year,
      _fechaInicio!.month,
      _fechaInicio!.day,
      _horaInicio!.hour,
      _horaInicio!.minute,
    );

    final endDateTime = DateTime(
      _fechaFin!.year,
      _fechaFin!.month,
      _fechaFin!.day,
      _horaFin!.hour,
      _horaFin!.minute,
    );

    return {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "title": _titleController.text,
      "description": _descriptionController.text,
      "video": _videoController.text.isEmpty ? null : _videoController.text,
      "slug": _titleController.text
          .toLowerCase()
          .replaceAll(' ', '-')
          .replaceAll(RegExp(r'[^\w\s-]'), ''),
      "url": _titleController.text
          .toLowerCase()
          .replaceAll(' ', '-')
          .replaceAll(RegExp(r'[^\w\s-]'), ''),
      "images": {
        "activityImage": {
          "full": {
            "url": _imageUrlController.text.isEmpty
                ? "https://cdn.joinnus.com/default-event.jpg"
                : _imageUrlController.text
          }
        },
        "__typename": "ActivityImages"
      },
      "pricing": {
        "isFree": _isFree,
        "code": "PEN",
        "symbol": "S/",
        "amount": _isFree ? 0 : double.tryParse(_priceController.text) ?? 0,
        "__typename": "ActivityPricing"
      },
      "geolocation": {
        "city": _selectedCity,
        "country": {"code": "PE"},
        "address": _addressController.text,
        "geopoint": {"latitude": -12.049748, "longitude": -77.049807},
        "__typename": "ActivityGeolocation"
      },
      "date": {
        "starts": startDateTime.toIso8601String(),
        "ends": endDateTime.toIso8601String(),
        "__typename": "ActivityDate"
      },
      "metadatas": [],
      "settings": {"foreignActivity": false, "__typename": "ActivitySettings"},
      "categories": {
        "main": {
          "name": _categories
              .firstWhere((cat) => cat['value'] == _selectedCategory)['label'],
          "slug": _selectedCategory,
          "__typename": "Category"
        },
        "__typename": "Categories"
      },
      "organizer": {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "slug": null,
        "firstName": _organizerNameController.text,
        "lastName": "",
        "__typename": "ActivityOrganizer"
      },
      "isPast": false,
      "soldOut": false,
      "state": 1,
      "activityType": "",
      "__typename": "Activity"
    };
  }

  Future<void> _crearEvento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona las fechas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_horaInicio == null || _horaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona las horas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Generar JSON del evento
    final eventJson = _generateEventJson();

    // Mostrar el JSON en consola (para debugging)
    print('Evento creado:');

    // Simular creación del evento
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Mostrar dialog con el JSON generado
      _showEventCreatedDialog(eventJson);
    }
  }

  void _showEventCreatedDialog(Map<String, dynamic> eventJson) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: appColor),
              SizedBox(width: 8),
              Text(
                '¡Evento Creado!',
                style: TextStyle(color: appColor),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu evento ha sido creado exitosamente.',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cerrar',
                style: TextStyle(color: appColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Crear Evento',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Título de la sección
                const Text(
                  'Información del Evento',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Título
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título del Evento',
                    labelStyle: TextStyle(color: appColor),
                    prefixIcon: Icon(Icons.event, color: appColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el título del evento';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Descripción
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: TextStyle(color: appColor),
                    prefixIcon: Icon(Icons.description, color: appColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor),
                    ),
                    hintText: 'Describe tu evento en detalle...',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo Dirección
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    labelStyle: TextStyle(color: appColor),
                    prefixIcon: Icon(Icons.location_on, color: appColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor),
                    ),
                    hintText: 'Ej: Av. Larco 123, Miraflores',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa la dirección';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown Ciudad
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    labelStyle: TextStyle(color: appColor),
                    prefixIcon: Icon(Icons.location_city, color: appColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor),
                    ),
                  ),
                  dropdownColor: Colors.grey[800],
                  items: _cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city['value'],
                      child: Text(city['label']!,
                          style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown Categoría
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    labelStyle: TextStyle(color: appColor),
                    prefixIcon: Icon(Icons.category, color: appColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor),
                    ),
                  ),
                  dropdownColor: Colors.grey[800],
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['value'],
                      child: Text(category['label']!,
                          style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Campo Organizador
                TextFormField(
                  controller: _organizerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Organizador',
                    labelStyle: TextStyle(color: appColor),
                    prefixIcon: Icon(Icons.person, color: appColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa el nombre del organizador';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo URL de Video
                TextFormField(
                  controller: _videoController,
                  decoration: const InputDecoration(
                    labelText: 'URL del Video (Opcional)',
                    labelStyle: TextStyle(color: appColor),
                    prefixIcon: Icon(Icons.video_library, color: appColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor),
                    ),
                    hintText: 'https://...',
                  ),
                ),
                const SizedBox(height: 16),

                // Campo URL de Imagen
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL de la Imagen (Opcional)',
                    labelStyle: TextStyle(color: appColor),
                    prefixIcon: Icon(Icons.image, color: appColor),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: appColor),
                    ),
                    hintText: 'https://...',
                  ),
                ),
                const SizedBox(height: 20),

                // Sección de Fechas y Horas
                const Text(
                  'Fecha y Hora',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Fecha y Hora de Inicio
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _seleccionarFecha(true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: appColor),
                              const SizedBox(width: 8),
                              Text(
                                _fechaInicio == null
                                    ? 'Fecha Inicio'
                                    : '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}',
                                style: TextStyle(
                                  color: _fechaInicio == null
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => _seleccionarHora(true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: appColor),
                              const SizedBox(width: 8),
                              Text(
                                _horaInicio == null
                                    ? 'Hora Inicio'
                                    : _horaInicio!.format(context),
                                style: TextStyle(
                                  color: _horaInicio == null
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Fecha y Hora de Fin
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _seleccionarFecha(false),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: appColor),
                              const SizedBox(width: 8),
                              Text(
                                _fechaFin == null
                                    ? 'Fecha Fin'
                                    : '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}',
                                style: TextStyle(
                                  color: _fechaFin == null
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => _seleccionarHora(false),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: appColor),
                              const SizedBox(width: 8),
                              Text(
                                _horaFin == null
                                    ? 'Hora Fin'
                                    : _horaFin!.format(context),
                                style: TextStyle(
                                  color: _horaFin == null
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sección de Precio
                const Text(
                  'Precio',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Switch Gratis
                Row(
                  children: [
                    Switch(
                      value: _isFree,
                      onChanged: (value) {
                        setState(() {
                          _isFree = value;
                          if (value) {
                            _priceController.text = '0';
                          }
                        });
                      },
                      activeColor: appColor,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Evento Gratuito',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Campo Precio
                if (!_isFree)
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Precio (S/)',
                      labelStyle: TextStyle(color: appColor),
                      prefixIcon: Icon(Icons.attach_money, color: appColor),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appColor),
                      ),
                      hintText: '0.00',
                    ),
                    validator: (value) {
                      if (!_isFree && (value == null || value.isEmpty)) {
                        return 'Por favor ingresa el precio';
                      }
                      if (!_isFree && double.tryParse(value!) == null) {
                        return 'Por favor ingresa un precio válido';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 40),

                // Botón Crear Evento
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _crearEvento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: appColor.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Crear Evento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
