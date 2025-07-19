import 'package:flutter/material.dart';
import 'package:caffe_pandawa/services/eoq_services.dart';

class EOQSetting extends StatefulWidget {
  final Map<String, dynamic>? existingData;

  const EOQSetting({Key? key, this.existingData}) : super(key: key);

  @override
  _EOQSettingState createState() => _EOQSettingState();
}

class _EOQSettingState extends State<EOQSetting> {
  final EOQServices _services = EOQServices();
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? selectedMaterial;
  final TextEditingController _materialController = TextEditingController();
  final TextEditingController _orderCostController = TextEditingController();
  final TextEditingController _holdingCostController = TextEditingController();
  final TextEditingController _annualDemandController = TextEditingController();

  bool _isLoading = false;
  bool _showSuggestions = false;
  List<dynamic> _suggestions = [];
  List<dynamic> _allRawMaterials = [];
  bool _isLoadingMaterials = false;
  final FocusNode _materialFocusNode = FocusNode();
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _materialController.addListener(_onSearchChanged);
    _materialFocusNode.addListener(_onFocusChanged);
    _loadRawMaterials();

    if (widget.existingData != null) {
      _isEditMode = true;
      _populateExistingData();
    }
  }

  void _populateExistingData() {
    final data = widget.existingData!;
    selectedMaterial = {
      'id': data['raw_material_id'],
      'nama': data['raw_material_name'],
    };
    _materialController.text = data['raw_material_name'] ?? '';
    _orderCostController.text = data['order_cost']?.toString() ?? '';
    _holdingCostController.text =
        data['holding_cost_percent']?.toString() ?? '';
    _annualDemandController.text = data['annual_demand']?.toString() ?? '';
  }

  @override
  void dispose() {
    _materialController.removeListener(_onSearchChanged);
    _materialController.dispose();
    _materialFocusNode.removeListener(_onFocusChanged);
    _materialFocusNode.dispose();
    _orderCostController.dispose();
    _holdingCostController.dispose();
    _annualDemandController.dispose();
    super.dispose();
  }

  void _loadRawMaterials() async {
    setState(() => _isLoadingMaterials = true);
    try {
      final materials = await _services.fetchRawMaterialsForEOQ();
      setState(() {
        _allRawMaterials = materials;
        _isLoadingMaterials = false;
      });
    } catch (e) {
      setState(() {
        _allRawMaterials = [];
        _isLoadingMaterials = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Gagal memuat data bahan baku: ${e.toString()}")),
      );
    }
  }

  void _onFocusChanged() {
    if (!_materialFocusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _materialController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
      return;
    }

    final filteredMaterials = _allRawMaterials.where((material) {
      final materialName = material['nama'].toString().toLowerCase();
      return materialName.contains(query);
    }).toList();

    setState(() {
      _suggestions = filteredMaterials;
      _showSuggestions = filteredMaterials.isNotEmpty;
    });
  }

  void _selectMaterial(Map<String, dynamic> material) {
    setState(() {
      selectedMaterial = material;
      _materialController.text = material['nama'];
      _showSuggestions = false;
      _suggestions = [];
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || selectedMaterial == null) return;

    setState(() => _isLoading = true);

    final payload = {
      "raw_material_id": selectedMaterial!["id"],
      "ordering_cost": _orderCostController.text,
      "holding_cost_percent": _holdingCostController.text,
      if (_annualDemandController.text.isNotEmpty)
        "annual_demand": _annualDemandController.text,
    };

    try {
      final success = await _services.saveEOQSetting(payload);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? "Pengaturan EOQ berhasil diperbarui"
                : "Pengaturan EOQ berhasil disimpan"),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan pengaturan EOQ"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1EB),
      appBar: AppBar(
        title: Text(
          _isEditMode ? "Edit Pengaturan EOQ" : "Pengaturan EOQ Baru",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF8B4513),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Konfigurasi EOQ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isEditMode
                        ? "Perbarui pengaturan EOQ untuk bahan baku yang dipilih"
                        : "Atur parameter EOQ untuk optimalisasi pemesanan bahan baku",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Form Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Material Selection Card
                    _buildSectionCard(
                      title: "Pilih Bahan Baku",
                      icon: Icons.inventory_2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _materialController,
                            focusNode: _materialFocusNode,
                            enabled: !_isEditMode && !_isLoadingMaterials,
                            decoration: InputDecoration(
                              hintText: "Cari bahan baku...",
                              prefixIcon: const Icon(Icons.search,
                                  color: Color(0xFF8B4513)),
                              suffixIcon: _isLoadingMaterials
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF8B4513),
                                      ),
                                    )
                                  : const Icon(Icons.arrow_drop_down,
                                      color: Color(0xFF8B4513)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF8B4513), width: 2),
                              ),
                              filled: true,
                              fillColor: _isEditMode
                                  ? Colors.grey.shade100
                                  : Colors.white,
                            ),
                            validator: (value) {
                              if (selectedMaterial == null) {
                                return "Bahan baku harus dipilih";
                              }
                              return null;
                            },
                            onTap: () {
                              if (!_isEditMode && _suggestions.isNotEmpty) {
                                setState(() {
                                  _showSuggestions = true;
                                });
                              }
                            },
                          ),
                          if (_showSuggestions && _suggestions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _suggestions.length,
                                itemBuilder: (context, index) {
                                  final suggestion = _suggestions[index];
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _selectMaterial(suggestion),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF8B4513)
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.inventory_2_outlined,
                                                size: 16,
                                                color: Color(0xFF8B4513),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                suggestion['nama'],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF5D4037),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Cost Parameters Card
                    _buildSectionCard(
                      title: "Parameter Biaya",
                      icon: Icons.attach_money,
                      child: Column(
                        children: [
                          _buildCustomTextField(
                            controller: _orderCostController,
                            label: "Biaya Pemesanan",
                            hint: "Masukkan biaya per order",
                            prefix: "Rp ",
                            keyboardType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty
                                ? "Biaya pemesanan wajib diisi"
                                : null,
                            helpText:
                                "Biaya yang dikeluarkan setiap kali melakukan pemesanan",
                          ),
                          const SizedBox(height: 16),
                          _buildCustomTextField(
                            controller: _holdingCostController,
                            label: "Biaya Penyimpanan (%/tahun)",
                            hint: "Masukkan persentase biaya simpan",
                            suffix: "%",
                            keyboardType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty
                                ? "Biaya penyimpanan wajib diisi"
                                : null,
                            helpText:
                                "Persentase biaya penyimpanan dari nilai stok per tahun",
                          ),
                          const SizedBox(height: 16),
                          _buildCustomTextField(
                            controller: _annualDemandController,
                            label: "Permintaan Tahunan (Opsional)",
                            hint: "Masukkan estimasi kebutuhan per tahun",
                            suffix: "unit",
                            keyboardType: TextInputType.number,
                            helpText:
                                "Jika kosong, sistem akan menggunakan data historis",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B4513),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_isEditMode ? Icons.update : Icons.save),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isEditMode
                                        ? "Perbarui Pengaturan"
                                        : "Simpan Pengaturan",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B4513).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF8B4513),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5D4037),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF8B4513), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        if (helpText != null) ...[
          const SizedBox(height: 4),
          Text(
            helpText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
