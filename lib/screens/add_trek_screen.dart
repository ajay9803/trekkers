import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/trek.dart';
import '../providers/treks_provider.dart';

class AddTrekPage extends StatefulWidget {
  const AddTrekPage({super.key});

  @override
  State<AddTrekPage> createState() => _AddTrekPageState();
}

class _AddTrekPageState extends State<AddTrekPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _slotsController = TextEditingController();
  final _difficultyController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _startLocationController = TextEditingController();

  final List<XFile> _images = [];

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _slotsController.dispose();
    _difficultyController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _startLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? pickedImages = await _picker.pickMultiImage();
      if (pickedImages != null) {
        setState(() {
          _images.addAll(pickedImages);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    for (var img in _images) {
      File file = File(img.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('treks/$fileName');
      await ref.putFile(file);
      String url = await ref.getDownloadURL();
      imageUrls.add(url);
    }
    return imageUrls;
  }

  void _saveTrek() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final uploadedImages = await _uploadImages();

      final trek = Trek(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        slotsAvailable: int.parse(_slotsController.text),
        difficulty: _difficultyController.text,
        distanceKm: double.parse(_distanceController.text),
        durationDays: int.parse(_durationController.text),
        startLocation: _startLocationController.text,
        images: uploadedImages,
        poi: [],
        createdAt: DateTime.now(),
      );

      await Provider.of<TreksProvider>(context, listen: false).addTrek(trek);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    final number = num.tryParse(value);
    if (number == null) return 'Enter a valid number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Trek')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Trek Name'),
                      validator: (val) => val!.isEmpty ? 'Enter name' : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (val) =>
                          val!.isEmpty ? 'Enter description' : null,
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: _validateNumber,
                    ),
                    TextFormField(
                      controller: _slotsController,
                      decoration:
                          const InputDecoration(labelText: 'Slots Available'),
                      keyboardType: TextInputType.number,
                      validator: _validateNumber,
                    ),
                    TextFormField(
                      controller: _difficultyController,
                      decoration:
                          const InputDecoration(labelText: 'Difficulty'),
                    ),
                    TextFormField(
                      controller: _distanceController,
                      decoration:
                          const InputDecoration(labelText: 'Distance (km)'),
                      keyboardType: TextInputType.number,
                      validator: _validateNumber,
                    ),
                    TextFormField(
                      controller: _durationController,
                      decoration:
                          const InputDecoration(labelText: 'Duration (days)'),
                      keyboardType: TextInputType.number,
                      validator: _validateNumber,
                    ),
                    TextFormField(
                      controller: _startLocationController,
                      decoration:
                          const InputDecoration(labelText: 'Start Location'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Add Images'),
                    ),
                    if (_images.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (ctx, i) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Image.file(
                              File(_images[i].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveTrek,
                      child: const Text('Add Trek'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
