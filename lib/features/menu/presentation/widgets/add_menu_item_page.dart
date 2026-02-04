import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apodel_restorant/features/menu/models/menu_item.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/custom_text_field.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/custom_dropdown.dart';

class AddMenuItemPage extends StatefulWidget {
  final String restaurantId;
  final MenuItem? existingItem; // Add this

  const AddMenuItemPage({
    super.key,
    required this.restaurantId,
    this.existingItem, // Add this
  });

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedCategory;
  File? _imageFile;
  String? _existingImageUrl;
  bool _isLoading = false;

  final List<String> _categories = [
    'Pica',
    'Burger',
    'Sandwich',
    'Toast',
    'Pije',
    'Ëmbëlsirë',
    'Sallatë',
    'Pasta',
    'Tjetër',
  ];

  bool get isEditMode => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if editing
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!.name;
      _descriptionController.text = widget.existingItem!.description ?? '';
      _priceController.text = widget.existingItem!.price.toString();
      _selectedCategory = widget.existingItem!.category;
      _existingImageUrl = widget.existingItem!.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _existingImageUrl = null; // Clear existing image when new one is picked
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null)
      return _existingImageUrl; // Keep existing image if no new one

    try {
      final fileName =
          '${widget.restaurantId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${widget.restaurantId}/$fileName';

      await _supabase.storage
          .from('menu-images')
          .upload(
            filePath,
            _imageFile!,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = _supabase.storage
          .from('menu-images')
          .getPublicUrl(filePath);

      return imageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gabim në ngarkimin e fotos: $e',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<bool> _verifyRestaurantOwnership() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) return false;

      final response = await _supabase
          .from('restorants')
          .select('user_id')
          .eq('id', widget.restaurantId)
          .single();

      return response['user_id'] == firebaseUser.uid;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ju lutem zgjidhni kategorinë',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isOwner = await _verifyRestaurantOwnership();
    if (!isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ju nuk keni leje për këtë operacion',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload image (or keep existing)
      final imageUrl = await _uploadImage();

      // Create or update menu item
      final menuItem = MenuItem(
        id: widget.existingItem?.id, // Include ID if editing
        restaurantId: widget.restaurantId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        price: double.parse(_priceController.text.trim()),
        imageUrl: imageUrl,
        category: _selectedCategory!,
      );

      if (isEditMode) {
        // Update existing item
        await _supabase
            .from('menu_items')
            .update(menuItem.toJson())
            .eq('id', widget.existingItem!.id!);
      } else {
        // Insert new item
        await _supabase.from('menu_items').insert(menuItem.toJson());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Produkti u përditësua me sukses!'
                : 'Produkti u shtua me sukses!',
            style: GoogleFonts.nunito(),
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gabim: ${e.toString()}', style: GoogleFonts.nunito()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMenuItem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Fshi Produktin',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        content: Text(
          'A jeni të sigurt që dëshironi të fshini "${_nameController.text}"?',
          style: GoogleFonts.nunito(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Anulo',
              style: GoogleFonts.nunito(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Fshi', style: GoogleFonts.nunito()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabase
            .from('menu_items')
            .delete()
            .eq('id', widget.existingItem!.id!);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Produkti u fshi me sukses!',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gabim: ${e.toString()}',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          isEditMode ? 'Ndrysho Produktin' : 'Shto Produkt të Ri',
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 16),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Image Picker
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 50,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  width: 2,
                                ),
                              ),
                              child: _imageFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : _existingImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        _existingImageUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 48,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Shto Foto',
                                          style: GoogleFonts.nunito(
                                            fontSize: 16,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            label: 'Emri i produktit',
                            hint: 'p.sh. Pica Margarita',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ju lutem shkruani emrin';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          CustomDropdown(
                            label: 'Kategoria',
                            hint: 'Zgjidhni kategorinë',
                            value: _selectedCategory,
                            items: _categories,
                            onChanged: (value) {
                              setState(() => _selectedCategory = value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ju lutem zgjidhni kategorinë';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          CustomTextField(
                            label: 'Çmimi (€)',
                            hint: '0.00',
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ju lutem shkruani çmimin';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'Çmimi duhet të jetë më i madh se 0';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          CustomTextField(
                            label: 'Përshkrimi (opsionale)',
                            hint: 'Përshkrimi i produktit',
                            controller: _descriptionController,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Save/Update Button
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 50,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        FocusScope.of(context).unfocus();
                        if (!_isLoading) _saveMenuItem();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 33, 33, 33),
                        backgroundColor: const Color.fromARGB(
                          255,
                          253,
                          199,
                          69,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              isEditMode ? 'Përditëso' : 'Ruaj Produktin',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  ),

                  // Delete Button (only in edit mode)
                  if (isEditMode) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 50,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _deleteMenuItem,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Fshi Produktin',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
