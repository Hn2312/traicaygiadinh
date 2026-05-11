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
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const AdminPage(),
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _unitCtrl = TextEditingController(text: 'kg');
  final _imageUrlCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _originCtrl = TextEditingController();

  List<Fruit> products = [];
  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var c in [
      _nameCtrl,
      _priceCtrl,
      _unitCtrl,
      _imageUrlCtrl,
      _descCtrl,
      _originCtrl,
    ])
      c.dispose();
    super.dispose();
  }

  // ==================== SẢN PHẨM ====================
  Future<void> _loadProducts() async {
    setState(() => isLoadingProducts = true);
    try {
      final data = await supabase.from('products').select().order('name');
      setState(() {
        products = (data as List).map((e) => Fruit.fromJson(e)).toList();
        isLoadingProducts = false;
      });
    } catch (e) {
      debugPrint("Lỗi: $e");
      setState(() => isLoadingProducts = false);
    }
  }

  Future<void> _addProduct() async {
    /* ... giữ nguyên code cũ của bạn */
  }
  Future<void> _deleteProduct(String? id) async {
    /* ... giữ nguyên */
  }

  // ==================== CẬP NHẬT TRẠNG THÁI NGAY LẬP TỨC ====================
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId);

      if (mounted) {
        _showSnackBar("✅ Đã cập nhật: $newStatus", Colors.green);
      }
    } catch (e) {
      if (mounted) _showSnackBar("Lỗi: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
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
        title: const Text("Admin - Trái Cây Gia Đình"),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Sản phẩm"),
            Tab(text: "Đơn hàng"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab Sản phẩm (giữ nguyên như cũ của bạn)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Form thêm sản phẩm ... (copy từ code cũ của bạn)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          "Thêm sản phẩm mới",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(_nameCtrl, "Tên trái cây", Icons.apple),
                        _buildTextField(
                          _priceCtrl,
                          "Giá (VNĐ)",
                          Icons.attach_money,
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextField(_unitCtrl, "Đơn vị", Icons.scale),
                        _buildTextField(_imageUrlCtrl, "Link ảnh", Icons.image),
                        _buildTextField(
                          _originCtrl,
                          "Xuất xứ",
                          Icons.location_on,
                        ),
                        _buildTextField(
                          _descCtrl,
                          "Mô tả",
                          Icons.description,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              "Thêm sản phẩm",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: isLoadingProducts
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final p = products[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: p.imageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          p.imageUrl!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.image, size: 60),
                                title: Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "${p.price}đ / ${p.unit} • ${p.origin}",
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteProduct(p.id),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // TAB ĐƠN HÀNG - REAL-TIME TỐT HƠN
          RefreshIndicator(
            onRefresh: () async {},
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                  .from('orders')
                  .stream(primaryKey: ['id'])
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final orders = snapshot.data!;

                if (orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 90,
                          color: Colors.grey,
                        ),
                        Text(
                          "Chưa có đơn hàng nào",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final status = order['status'] ?? 'Chờ xử lý';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Đơn #${order['id'].toString().substring(0, 8)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  order['created_at'].toString().substring(
                                    0,
                                    16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Khách: ${order['customer_name'] ?? 'Không tên'}",
                            ),
                            Text("SĐT: ${order['phone'] ?? ''}"),
                            Text("Địa chỉ: ${order['address'] ?? ''}"),
                            const SizedBox(height: 8),
                            Text(
                              "Sản phẩm: ${(order['items'] as List).join(', ')}",
                            ),
                            Text(
                              "Tổng: ${order['total'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text("Trạng thái: "),
                                DropdownButton<String>(
                                  value: status,
                                  items: const [
                                    DropdownMenuItem(
                                      value: "Chờ xử lý",
                                      child: Text("Chờ xử lý"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Đang xử lý",
                                      child: Text("Đang xử lý"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Đang giao",
                                      child: Text("Đang giao"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Hoàn thành",
                                      child: Text("Hoàn thành"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Đã hủy",
                                      child: Text("Đã hủy"),
                                    ),
                                  ],
                                  onChanged: (newValue) {
                                    if (newValue != null)
                                      _updateOrderStatus(order['id'], newValue);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
