import 'package:flutter/material.dart';
import 'package:caffe_pandawa/helpers/capitalize.dart';
import 'package:caffe_pandawa/models/Recipe.dart';
import 'package:caffe_pandawa/pages/manajemen_resep/resep_form.dart';
import 'package:caffe_pandawa/services/resep_services.dart';

class ManajemenResep extends StatefulWidget {
  @override
  _ManajemenResepState createState() => _ManajemenResepState();
}

class _ManajemenResepState extends State<ManajemenResep> {
  List<Recipe> recipes = [];
  List<Recipe> filteredRecipes = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  // Color theme - tetap sama
  static const primaryColor = Colors.brown;
  static const primaryColorLight = Color(0xFFE0F7FA);
  static const surfaceColor = Colors.white;
  static const backgroundColor = Color(0xFFF8F9FA);

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedRecipes = await ResepServices.getRecipes();
      setState(() {
        recipes = loadedRecipes;
        filteredRecipes = loadedRecipes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _filterRecipes(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredRecipes = recipes;
      } else {
        filteredRecipes = recipes.where((recipe) {
          final name = recipe.name?.toLowerCase() ?? '';
          final productName = recipe.product?.namaProduct.toLowerCase() ?? '';
          final description = recipe.description?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) ||
              productName.contains(searchLower) ||
              description.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> deleteRecipe(Recipe recipe) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteDialog(recipe),
    );

    if (confirm == true) {
      try {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: primaryColor),
                SizedBox(width: 20),
                Text('Menghapus resep...'),
              ],
            ),
          ),
        );

        // Simulate delete operation
        await Future.delayed(Duration(milliseconds: 500));

        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resep berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        loadRecipes();
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus resep: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDeleteDialog(Recipe recipe) {
    return AlertDialog(
      title: Text('Konfirmasi Hapus'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apakah Anda yakin ingin menghapus resep ini?'),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(8),
            color: primaryColorLight,
            child: Text(
              recipe.name ?? recipe.product?.namaProduct ?? 'Tanpa Nama',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tindakan ini tidak dapat dibatalkan.',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('BATAL'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text('HAPUS'),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16),
      color: surfaceColor,
      child: TextField(
        onChanged: _filterRecipes,
        decoration: InputDecoration(
          hintText: 'Cari resep, produk, atau deskripsi...',
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _filterRecipes('');
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, int index) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: surfaceColor,
      child: Column(
        children: [
          // Header dengan warna solid
          Container(
            width: double.infinity,
            color: primaryColor,
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  color: Colors.white,
                  child: Icon(
                    Icons.restaurant_menu,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (recipe.name ??
                                recipe.product?.namaProduct ??
                                'Tanpa Nama')
                            .capitalize(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (recipe.product != null)
                        Text(
                          'Produk: ${recipe.product!.namaProduct}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                _buildStatusBadge(recipe.isActive),
              ],
            ),
          ),
          // Content area
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe.description != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    color: Colors.grey[100],
                    child: Text(
                      recipe.description!,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                Row(
                  children: [
                    _buildInfoChip(
                      icon: Icons.list_alt,
                      label: '${recipe.ingredients?.length ?? 0} Bahan',
                      color: primaryColor,
                    ),
                    SizedBox(width: 12),
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: 'Aktif',
                      color: recipe.isActive ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 1,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildActionButton(
                      icon: Icons.visibility,
                      label: 'LIHAT',
                      color: primaryColor,
                      onPressed: () => _showRecipeDetails(recipe),
                    ),
                    SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.edit,
                      label: 'EDIT',
                      color: primaryColor,
                      onPressed: () => _editRecipe(recipe),
                    ),
                    SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete,
                      label: 'HAPUS',
                      color: Colors.red,
                      onPressed: () => deleteRecipe(recipe),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: isActive ? Colors.green : Colors.red,
      child: Text(
        isActive ? 'AKTIF' : 'TIDAK AKTIF',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        color: color.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            color: primaryColorLight,
            child: Icon(
              searchQuery.isNotEmpty ? Icons.search_off : Icons.restaurant_menu,
              size: 64,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 24),
          Text(
            searchQuery.isNotEmpty ? 'TIDAK ADA HASIL' : 'BELUM ADA RESEP',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Text(
              searchQuery.isNotEmpty
                  ? 'Coba kata kunci lain atau buat resep baru'
                  : 'Mulai dengan membuat resep pertama Anda',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (searchQuery.isEmpty) ...[
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createNewRecipe,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: Text(
                'BUAT RESEP PERTAMA',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            color: Colors.red.withOpacity(0.1),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'TERJADI KESALAHAN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 32),
            padding: EdgeInsets.all(16),
            color: Colors.red.withOpacity(0.05),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: loadRecipes,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Text(
              'COBA LAGI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(Recipe recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restaurant_menu, color: primaryColor),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                (recipe.name ?? recipe.product?.namaProduct ?? 'Tanpa Nama')
                    .capitalize(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (recipe.description != null) ...[
                Text(
                  'DESKRIPSI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.grey[100],
                  child: Text(recipe.description!),
                ),
                SizedBox(height: 16),
              ],
              Text(
                'INFORMASI RESEP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: 8),
              _buildInfoRow(
                  'Status', recipe.isActive ? 'Aktif' : 'Tidak Aktif'),
              _buildInfoRow(
                  'Jumlah Bahan', '${recipe.ingredients?.length ?? 0} item'),
              if (recipe.product != null)
                _buildInfoRow(
                    'Produk Terkait', recipe.product!.namaProduct.capitalize()),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('TUTUP'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editRecipe(Recipe recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResepForm(recipe: recipe),
      ),
    );
    if (result == true) {
      loadRecipes();
    }
  }

  Future<void> _createNewRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResepForm()),
    );
    if (result == true) {
      loadRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Kelola Resep',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        actions: [
          IconButton(
            onPressed: loadRecipes,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primaryColor),
                  SizedBox(height: 16),
                  Text(
                    'MEMUAT RESEP...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    _buildSearchBar(),
                    Expanded(
                      child: filteredRecipes.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: loadRecipes,
                              color: primaryColor,
                              child: ListView.builder(
                                padding: EdgeInsets.only(bottom: 100),
                                itemCount: filteredRecipes.length,
                                itemBuilder: (context, index) =>
                                    _buildRecipeCard(
                                        filteredRecipes[index], index),
                              ),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRecipe,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
    );
  }
}
