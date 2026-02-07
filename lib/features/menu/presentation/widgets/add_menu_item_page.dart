import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:apodel_restorant/features/menu/models/menu_item.dart';
import 'package:apodel_restorant/features/menu/services/image_service.dart';
import 'package:apodel_restorant/features/menu/services/menu_item_service.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/custom_text_field.dart';
import 'package:apodel_restorant/features/registration/presentation/widgets/custom_dropdown.dart';

class AddMenuItemPage extends StatefulWidget {
  final String restaurantId;
  final MenuItem? existingItem;

  const AddMenuItemPage({
    super.key,
    required this.restaurantId,
    this.existingItem,
  });

  @override
  State<AddMenuItemPage> createState() => _AddMenuItemPageState();
}

class _AddMenuItemPageState extends State<AddMenuItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();
  final _menuItemService = MenuItemService();

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
    final image = await _imageService.pickImage();
    if (image != null) {
      setState(() {
        _imageFile = image;
        _existingImageUrl = null;
      });
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

    final isOwner = await _menuItemService.verifyRestaurantOwnership(
      widget.restaurantId,
    );
    if (!isOwner) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ju nuk keni leje për këtë operacion',
              style: GoogleFonts.nunito(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload image
      final imageUrl = await _imageService.uploadImage(
        restaurantId: widget.restaurantId,
        imageFile: _imageFile,
        existingImageUrl: _existingImageUrl,
        context: context,
      );

      // Create menu item
      final menuItem = MenuItem(
        id: widget.existingItem?.id,
        restaurantId: widget.restaurantId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        price: double.parse(_priceController.text.trim()),
        imageUrl: imageUrl,
        category: _selectedCategory!,
      );

      // Save to database
      final success = await _menuItemService.saveMenuItem(
        context: context,
        menuItem: menuItem,
        isEditMode: isEditMode,
        existingItemId: widget.existingItem?.id,
      );

      if (success && mounted) {
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMenuItem() async {
    final success = await _menuItemService.deleteMenuItem(
      context: context,
      itemId: widget.existingItem!.id!,
      itemName: _nameController.text,
    );

    if (success && mounted) {
      Navigator.pop(context, true);
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
                          const SizedBox(height: 15),

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
                          style: GoogleFonts.nunito(fontSize: 18),
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
