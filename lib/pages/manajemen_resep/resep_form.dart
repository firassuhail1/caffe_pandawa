import 'package:caffe_pandawa/services/product_services.dart';
import 'package:flutter/material.dart';
import 'package:caffe_pandawa/helpers/capitalize.dart';
import 'package:caffe_pandawa/helpers/flushbar_message.dart';
import 'package:caffe_pandawa/models/BahanBaku.dart';
import 'package:caffe_pandawa/models/Product.dart';
import 'package:caffe_pandawa/models/Recipe.dart';
import 'package:caffe_pandawa/models/RecipeIngredient.dart';
import 'package:caffe_pandawa/services/resep_services.dart';

class ResepForm extends StatefulWidget {
  final Recipe? recipe;

  const ResepForm({Key? key, this.recipe}) : super(key: key);

  @override
  _ResepFormState createState() => _ResepFormState();
}

class _ResepFormState extends State<ResepForm> with TickerProviderStateMixin {
  // Controllers & Keys
  // final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form Data
  int? selectedProduct;
  bool isActive = true;
  List<RecipeIngredientForm> ingredients = [];

  // Loading States
  bool isLoading = false;
  bool isLoadingProducts = false;
  bool isLoadingRawMaterials = false;

  // Data Lists
  List<Product> availableProducts = [];
  List<BahanBaku> availableRawMaterials = [];

  // Color Scheme
  static const Color primaryColor = Colors.brown;
  static const Color primaryColorDark = Color.fromARGB(255, 83, 59, 50);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeData();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeData() {
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name ?? '';
      _descriptionController.text = widget.recipe!.description ?? '';
      selectedProduct = widget.recipe!.product?.id;
      isActive = widget.recipe!.isActive;
      ingredients = widget.recipe!.ingredients!
          .map((ing) => RecipeIngredientForm(
                rawMaterialId: ing.rawMaterialId,
                quantityNeeded: ing.quantityNeeded,
                rawMaterial: ing.rawMaterial,
              ))
          .toList();
    }

    if (ingredients.isEmpty) {
      ingredients.add(RecipeIngredientForm());
    }
  }

  void _loadInitialData() {
    loadProducts();
    loadRawMaterials();
  }

  Future<void> loadProducts() async {
    setState(() => isLoadingProducts = true);
    try {
      final products = await ProductServices().getProducibleProducts();
      setState(() {
        availableProducts = products;
        isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => isLoadingProducts = false);
      _showErrorMessage('Gagal memuat produk: $e');
    }
  }

  Future<void> loadRawMaterials() async {
    setState(() => isLoadingRawMaterials = true);
    try {
      final materials = await ResepServices.getRawMaterials();
      setState(() {
        availableRawMaterials = materials;
        isLoadingRawMaterials = false;
      });
    } catch (e) {
      setState(() => isLoadingRawMaterials = false);
      _showErrorMessage('Gagal memuat bahan baku: $e');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void addIngredient() {
    setState(() {
      ingredients.add(RecipeIngredientForm());
    });
    // Scroll to bottom to show new ingredient
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void removeIngredient(int index) {
    if (ingredients.length > 1) {
      setState(() {
        ingredients.removeAt(index);
      });
    }
  }

  Future<void> saveRecipe() async {
    // if (!_formKey.currentState!.validate()) return;

    if (selectedProduct == null) {
      _showErrorMessage('Pilih produk terlebih dahulu');
      return;
    }

    // Validate ingredients
    for (int i = 0; i < ingredients.length; i++) {
      if (ingredients[i].rawMaterialId == null ||
          ingredients[i].quantityNeeded <= 0) {
        _showErrorMessage('Lengkapi semua bahan baku pada baris ${i + 1}');
        return;
      }
    }

    setState(() => isLoading = true);

    print('masuk sini');
    try {
      final recipe = Recipe(
        productId: selectedProduct!,
        name: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isActive: isActive,
        ingredients: ingredients
            .map((ing) => RecipeIngredient(
                  rawMaterialId: ing.rawMaterialId!,
                  quantityNeeded: ing.quantityNeeded,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ))
            .toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.recipe == null) {
        final result = await ResepServices.createRecipe(recipe);
        if (result) {
          await flushbarMessage(context, "Resep berhasil dibuat",
              Colors.green.shade600, Icons.check_circle);
          Navigator.pop(context, true);
        } else {
          flushbarMessage(context, "Resep gagal dibuat", Colors.red.shade600,
              Icons.check_circle);
        }
      } else {
        final result =
            await ResepServices.updateRecipe(widget.recipe!.id!, recipe);

        if (result) {
          await flushbarMessage(context, "Resep berhasil di perbarui",
              Colors.green.shade600, Icons.check_circle);
          Navigator.pop(context, true);
        } else {
          flushbarMessage(context, "Resep gagal di perbarui",
              Colors.red.shade600, Icons.check_circle);
        }
      }
    } catch (e) {
      _showErrorMessage('Gagal menyimpan resep: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(6.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildProductSelection(),
                        const SizedBox(height: 24),
                        _buildRecipeDetails(),
                        const SizedBox(height: 24),
                        _buildIngredientsSection(),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.recipe == null ? 'Buat Resep Baru' : 'Edit Resep',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, primaryColorDark],
            ),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: isLoading
              ? Container(
                  padding: const EdgeInsets.all(12),
                  child: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : ElevatedButton.icon(
                  onPressed: saveRecipe,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text(
                    'SIMPAN',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildProductSelection() {
    return _buildCard(
      title: 'Produk',
      icon: Icons.inventory_2_outlined,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.grey.shade50,
            ),
            child: DropdownButtonFormField<int>(
              value: selectedProduct,
              decoration: InputDecoration(
                hintText: 'Pilih Produk',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                prefixIcon:
                    Icon(Icons.inventory_2_outlined, color: primaryColor),
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
              dropdownColor: Colors.white,
              items: availableProducts.map((product) {
                return DropdownMenuItem(
                  value: product.id,
                  child: Text(
                    product.namaProduct.capitalize(),
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              onChanged: (product) {
                setState(() {
                  selectedProduct = product;
                });
              },
              validator: (value) {
                if (value == null) return 'Pilih produk';
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeDetails() {
    return _buildCard(
      title: 'Detail Resep',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Nama Resep',
            hint: 'Masukkan nama resep',
            icon: Icons.title_outlined,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionController,
            label: 'Deskripsi',
            hint: 'Masukkan deskripsi resep (opsional)',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          _buildStatusSwitch(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(icon, color: primaryColor),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? primaryColor.withOpacity(0.1)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isActive ? Icons.toggle_on : Icons.toggle_off,
              color: isActive ? primaryColor : textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Resep',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                Text(
                  isActive ? 'Resep ini aktif' : 'Resep ini tidak aktif',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 20,
            child: Transform.scale(
              scaleY: 0.65,
              scaleX: 0.68,
              child: Switch.adaptive(
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    isActive = value;
                  });
                },
                activeColor: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return _buildCard(
      title: 'Bahan Baku',
      icon: Icons.restaurant_menu_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tambahkan bahan baku yang diperlukan',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: addIngredient,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...ingredients.asMap().entries.map((entry) {
            int index = entry.key;
            RecipeIngredientForm ingredient = entry.value;
            return _buildIngredientCard(ingredient, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(RecipeIngredientForm ingredient, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Bahan ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                if (ingredients.length > 1)
                  IconButton(
                    onPressed: () => removeIngredient(index),
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red.shade400,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildIngredientDropdown(ingredient),
            const SizedBox(height: 16),
            _buildQuantityInput(ingredient),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientDropdown(RecipeIngredientForm ingredient) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonFormField<BahanBaku>(
        value: ingredient.rawMaterial,
        decoration: const InputDecoration(
          hintText: 'Pilih Bahan Baku',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Icon(Icons.restaurant_menu_outlined, color: primaryColor),
        ),
        icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
        items: availableRawMaterials.map((material) {
          return DropdownMenuItem(
            value: material,
            child: Text(material.namaBahanBaku),
          );
        }).toList(),
        onChanged: (material) {
          setState(() {
            ingredient.rawMaterial = material;
            ingredient.rawMaterialId = material?.id;
          });
        },
        validator: (value) {
          if (value == null) return 'Pilih bahan baku';
          return null;
        },
      ),
    );
  }

  Widget _buildQuantityInput(RecipeIngredientForm ingredient) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jumlah',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: TextFormField(
                  initialValue: ingredient.quantityNeeded > 0
                      ? ingredient.quantityNeeded.toString()
                      : '',
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    prefixIcon: Icon(Icons.straighten, color: primaryColor),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    ingredient.quantityNeeded = double.tryParse(value) ?? 0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Masukkan jumlah';
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Jumlah harus lebih dari 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Satuan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: primaryColor.withOpacity(0.05),
                ),
                child: Text(
                  ingredient.rawMaterial?.unitOfMeasure ?? 'Satuan',
                  style: TextStyle(
                    color: ingredient.rawMaterial != null
                        ? textPrimary
                        : textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [primaryColor, primaryColorDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : saveRecipe,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Menyimpan...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    widget.recipe == null ? 'BUAT RESEP' : 'PERBARUI RESEP',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryColor, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}

class RecipeIngredientForm {
  int? rawMaterialId;
  double quantityNeeded;
  BahanBaku? rawMaterial;

  RecipeIngredientForm({
    this.rawMaterialId,
    this.quantityNeeded = 0,
    this.rawMaterial,
  });
}
