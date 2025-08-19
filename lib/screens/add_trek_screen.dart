import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trekkers/models/mid_point.dart';
import 'package:trekkers/models/trek.dart';
import 'package:trekkers/providers/treks_provider.dart';

class AddTrekPage extends StatefulWidget {
  const AddTrekPage({super.key});

  @override
  State<AddTrekPage> createState() => _AddTrekPageState();
}

class _AddTrekPageState extends State<AddTrekPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _slotsController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _startLocationController = TextEditingController();
  final _poiController = TextEditingController();

  String _difficulty = "Easy";
  bool _featured = false;
  bool _isActive = true;

  final List<File> _trekImages = [];
  final List<MidPoint> _midPoints = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickTrekImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _trekImages.addAll(pickedFiles.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _addMidPointDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();
    final List<File> midPointImages = [];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          Future<void> pickMidPointImages() async {
            final picked = await _picker.pickMultiImage();
            if (picked != null) {
              setStateDialog(() {
                midPointImages.addAll(picked.map((x) => File(x.path)));
              });
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Add Mid-Point"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(nameController, "Name"),
                  _buildTextField(descController, "Description", maxLines: 3),
                  _buildTextField(latController, "Latitude", isNumber: true),
                  _buildTextField(lngController, "Longitude", isNumber: true),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: midPointImages.map((img) {
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              img,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setStateDialog(() {
                                midPointImages.remove(img);
                              });
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  TextButton.icon(
                    onPressed: pickMidPointImages,
                    icon: const Icon(Icons.image, color: Colors.green),
                    label: const Text(
                      "Add Images",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      descController.text.isNotEmpty &&
                      latController.text.isNotEmpty &&
                      lngController.text.isNotEmpty) {
                    final midPoint = MidPoint(
                      name: nameController.text.trim(),
                      description: descController.text.trim(),
                      lat: double.tryParse(latController.text.trim()) ?? 0.0,
                      lng: double.tryParse(lngController.text.trim()) ?? 0.0,
                      images: midPointImages,
                    );
                    setState(() {
                      _midPoints.add(midPoint);
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveTrek() async {
    if (_formKey.currentState!.validate()) {
      final poiList = _poiController.text
          .split(',')
          .map((e) => e.trim())
          .toList();
      setState(() => _isLoading = true);

      final trek = Trek(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        slotsAvailable: double.tryParse(_slotsController.text.trim()) ?? 0,
        difficulty: _difficulty,
        distanceKm: double.tryParse(_distanceController.text.trim()) ?? 0,
        durationDays: double.tryParse(_durationController.text.trim()) ?? 0,
        startLocation: _startLocationController.text.trim(),
        localImages: _trekImages,
        poi: poiList,
        createdAt: DateTime.now(),
        featured: _featured,
        isActive: _isActive,
        midPoints: _midPoints,
      );

      try {
        await Provider.of<TreksProvider>(context, listen: false).addTrek(trek);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to save trek: $e")));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.green.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (val) => val!.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Trek"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Trek Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _buildTextField(_nameController, "Trek Name"),
              _buildTextField(
                _descriptionController,
                "Description",
                maxLines: 3,
              ),
              _buildTextField(_priceController, "Price", isNumber: true),
              _buildTextField(
                _slotsController,
                "Slots Available",
                isNumber: true,
              ),
              _buildTextField(
                _distanceController,
                "Distance (km)",
                isNumber: true,
              ),
              _buildTextField(
                _durationController,
                "Duration (days)",
                isNumber: true,
              ),
              _buildTextField(_startLocationController, "Start Location"),
              _buildTextField(
                _poiController,
                "Points of Interest (comma separated)",
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: InputDecoration(
                  labelText: "Difficulty",
                  filled: true,
                  fillColor: Colors.green.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ["Easy", "Moderate", "Hard"]
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) => setState(() => _difficulty = val!),
              ),
              SwitchListTile(
                title: const Text("Featured"),
                activeColor: Colors.green,
                value: _featured,
                onChanged: (val) => setState(() => _featured = val),
              ),
              SwitchListTile(
                title: const Text("Active"),
                activeColor: Colors.green,
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),
              const SizedBox(height: 16),
              const Text(
                "Trek Images",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _trekImages.map((img) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.file(
                          img,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.red,
                          ),
                          onPressed: () =>
                              setState(() => _trekImages.remove(img)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              TextButton.icon(
                onPressed: _pickTrekImages,
                icon: const Icon(Icons.image, color: Colors.green),
                label: const Text(
                  "Add Trek Images",
                  style: TextStyle(color: Colors.green),
                ),
              ),
              const Divider(height: 32, thickness: 1),
              ListTile(
                title: const Text("Mid-Points"),
                trailing: IconButton(
                  icon: const Icon(Icons.add, color: Colors.green),
                  onPressed: _addMidPointDialog,
                ),
              ),
              Column(
                children: _midPoints.map((mp) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      title: Text(mp.name),
                      subtitle: Text(
                        "${mp.description}\nLat: ${mp.lat}, Lng: ${mp.lng}",
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => _midPoints.remove(mp)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveTrek,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Save Trek", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
