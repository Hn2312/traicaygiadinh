import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fruit.dart';

final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://gimigizuhiypqimztblx.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdpbWlnaXp1aGl5cHFpbXp0Ymx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5MzQ5MDAsImV4cCI6MjA5MzUxMDkwMH0.IUNiVGn6FNDTIN6oVcMFYdL8nmXrNI4VeCivV0Cb1QQ',
  );

  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin - Trái Cây Gia Đình',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AdminPage(),
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'kg');
  final _imageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _originCtrl = TextEditingController();

  List<Fruit> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase.from('products').select().order('name');
      setState(() {
        products = (data as List).map((json) => Fruit.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi tải: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _addProduct() async {
    if (_nameCtrl.text.trim().isEmpty || _priceCtrl.text.trim().isEmpty) {
      _showSnackBar("Vui lòng nhập tên và giá sản phẩm", Colors.red);
      return;
    }

    try {
      await supabase.from('products').insert({
        'name': _nameCtrl.text.trim(),
        'price': int.parse(_priceCtrl.text.trim()),
        'unit': _unitCtrl.text.trim(),
        'image_url': _imageCtrl.text.trim().isEmpty
            ? null
            : _imageCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'origin': _originCtrl.text.trim(),
      });

      _clearForm();
      await _loadProducts();
      _showSnackBar("✅ Thêm sản phẩm thành công!", Colors.green);
    } catch (e) {
      _showSnackBar("Lỗi: $e", Colors.red);
    }
  }

  void _clearForm() {
    _nameCtrl.clear();
    _priceCtrl.clear();
    _imageCtrl.clear();
    _descCtrl.clear();
    _originCtrl.clear();
  }

  Future<void> _deleteProduct(String id) async {
    try {
      await supabase.from('products').delete().eq('id', id);
      await _loadProducts();
      _showSnackBar("Đã xóa sản phẩm", Colors.green);
    } catch (e) {
      _showSnackBar("Lỗi xóa: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Quản lý Sản phẩm"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Row(
        children: [
          // ==================== FORM THÊM SẢN PHẨM ====================
          Container(
            width: 460,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thêm sản phẩm mới",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Điền thông tin bên dưới",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(_nameCtrl, "Tên sản phẩm", Icons.apple),
                  _buildTextField(
                    _priceCtrl,
                    "Giá (VNĐ)",
                    Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(_unitCtrl, "Đơn vị", Icons.scale),
                  _buildTextField(
                    _imageCtrl,
                    "Link ảnh (image_url)",
                    Icons.image,
                  ),
                  _buildTextField(_originCtrl, "Xuất xứ", Icons.location_on),
                  _buildTextField(
                    _descCtrl,
                    "Mô tả",
                    Icons.description,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Thêm sản phẩm",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==================== DANH SÁCH SẢN PHẨM ====================
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                ? const Center(
                    child: Text(
                      "Chưa có sản phẩm nào",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: p.imageUrl != null
                                ? Image.network(
                                    p.imageUrl!,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image,
                                      size: 70,
                                      color: Colors.grey,
                                    ),
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 70,
                                    color: Colors.grey,
                                  ),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${p.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ / ${p.unit} • ${p.origin}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(p.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }
}
