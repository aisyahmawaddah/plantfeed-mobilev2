import 'package:flutter/material.dart';
import 'package:plant_feed/Services/services.dart';
import 'dart:io'; // For handling file uploads
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = "None Selected";
  File? _productPhoto; // To hold the selected image file

  bool _isLoading = false;

  // Method to pick the image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _productPhoto = File(image.path);
      });
    }
  }

  // Save Product
  Future<void> _saveProduct() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        // API call to add the product
        await apiService.sellProduct(
          1, // Example sellerId, change this as needed
          _nameController.text,
          _descriptionController.text,
          _selectedCategory,
          '', // Custom category if necessary
          _priceController.text,
          _quantityController.text,
          _productPhoto,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product added successfully!")),
        );
        Navigator.pop(context); // Return to the previous screen
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add product: $error")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sell a Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Product Name",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "Enter Product Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "Enter product name"
                      : null,
                ),
                const SizedBox(height: 10),

                const Text(
                  "Description",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: "Enter Product Description",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value == null || value.isEmpty
                      ? "Enter product description"
                      : null,
                ),
                const SizedBox(height: 10),

                const Text(
                  "Category",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: <String>["None Selected", "Fruit", "Seed", "Pest Control", "Sapling", "Fertiliser", "Tool", "Others"]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Select Product Category",
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Product Price",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    hintText: "Enter Product Price",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? "Enter product price"
                      : null,
                ),
                const SizedBox(height: 10),

                const Text(
                  "Stock Available",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    hintText: "Enter Stock Number",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value == null || value.isEmpty
                      ? "Enter stock number"
                      : null,
                ),
                const SizedBox(height: 10),

                const Text(
                  "Photo",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_productPhoto != null
                          ? _productPhoto!.path.split('/').last
                          : 'No file chosen'),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: const Text("Upload"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Save Button
                Center(
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _saveProduct,
                          icon: const Icon(Icons.save),
                          label: const Text("Add Product"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                // Button to return to marketplace
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the previous screen
                    },
                    child: const Text(
                      "Return to my marketplace screen",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}