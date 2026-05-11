import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fruit.dart';

final supabase = Supabase.instance.client;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Fruit> cart = [];
  int totalPrice = 0;
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
      final data = await supabase
          .from('products')
          .select()
          .order('name', ascending: true);

      setState(() {
        products = (data as List)
            .map((json) => Fruit.fromJson(json as Map<String, dynamic>))
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Lỗi tải sản phẩm: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveOrder({
    required String customerName,
    required String phone,
    required String address,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('orders').insert({
        'user_id': user.id,
        'customer_name': customerName,
        'phone': phone,
        'address': address,
        'items': cart.map((e) => e.name).toList(),
        'total': totalPrice,
        'status': 'Chờ xử lý',
      });
    } catch (e) {
      debugPrint("Lỗi lưu đơn hàng: $e");
    }
  }

  void addToCart(Fruit fruit) {
    setState(() {
      cart.add(fruit);
      totalPrice += fruit.price;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text("Đã thêm ${fruit.name}")),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void showProductDetail(Fruit fruit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: fruit.imageUrl != null
                      ? Image.network(
                          fruit.imageUrl!,
                          height: 220,
                          fit: BoxFit.contain,
                        )
                      : const Text("🍎", style: TextStyle(fontSize: 140)),
                ),
                const SizedBox(height: 24),
                Text(
                  fruit.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${fruit.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ / ${fruit.unit}",
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Xuất xứ: ${fruit.origin}"),
                const SizedBox(height: 16),
                Text(fruit.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      addToCart(fruit);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Thêm vào giỏ hàng",
                      style: TextStyle(fontSize: 18, color: Colors.white),
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

  void showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "🛒 Giỏ hàng (${cart.length})",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "Tổng: ${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 30),
            Expanded(
              child: cart.isEmpty
                  ? const Center(
                      child: Text(
                        "Giỏ hàng trống",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: item.imageUrl != null
                                ? Image.network(
                                    item.imageUrl!,
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.image,
                                    size: 55,
                                    color: Colors.grey,
                                  ),
                          ),
                          title: Text(item.name),
                          subtitle: Text(
                            "${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                totalPrice -= item.price;
                                cart.removeAt(index);
                              });
                              Navigator.pop(context);
                              showCart();
                            },
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: cart.isEmpty
                  ? null
                  : () {
                      Navigator.pop(context);
                      _showCustomerInfoForm();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "Tiếp tục thanh toán",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerInfoForm() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thông tin nhận hàng"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Họ và tên"),
            ),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Số điện thoại"),
            ),
            TextField(
              controller: addressCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: "Địa chỉ nhận hàng"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty ||
                  phoneCtrl.text.trim().isEmpty ||
                  addressCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Vui lòng nhập đầy đủ thông tin"),
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _completePayment(
                nameCtrl.text.trim(),
                phoneCtrl.text.trim(),
                addressCtrl.text.trim(),
              );
            },
            child: const Text("Xác nhận & Đặt hàng"),
          ),
        ],
      ),
    );
  }

  void _completePayment(String name, String phone, String address) async {
    await _saveOrder(customerName: name, phone: phone, address: address);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Đặt hàng thành công! Cảm ơn bạn."),
          backgroundColor: Colors.green,
        ),
      );
    }
    setState(() {
      cart.clear();
      totalPrice = 0;
    });
  }

  void showOrderHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.88,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "📜 Lịch sử đặt hàng",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabase
                    .from('orders')
                    .stream(primaryKey: ['id'])
                    .eq('user_id', supabase.auth.currentUser!.id)
                    .order('created_at', ascending: false),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  final orders = snapshot.data!;

                  if (orders.isEmpty) {
                    return const Center(child: Text("Chưa có đơn hàng nào"));
                  }

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final o = orders[index];
                      final status = o['status'] ?? 'Chờ xử lý';
                      Color color = Colors.orange;
                      if (status == 'Đang xử lý') color = Colors.blue;
                      if (status == 'Đang giao') color = Colors.purple;
                      if (status == 'Hoàn thành') color = Colors.green;
                      if (status == 'Đã hủy') color = Colors.red;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            "Đơn #${o['id'].toString().substring(0, 8)}",
                          ),
                          subtitle: Text(
                            "${(o['items'] as List).join(', ')}\n"
                            "Tổng: ${o['total'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ\n"
                            "${o['customer_name'] ?? ''} • ${o['phone'] ?? ''}\n"
                            "${o['address'] ?? ''}",
                          ),
                          trailing: Text(
                            status,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Trái Cây Gia Đình",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: showOrderHistory,
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          IconButton(
            icon: Badge(
              label: Text(cart.length.toString()),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: showCart,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        color: Colors.green,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : products.isEmpty
            ? const Center(child: Text("Chưa có sản phẩm nào"))
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final fruit = products[index];
                  return GestureDetector(
                    onTap: () => showProductDetail(fruit),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 6,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Container(
                                color: Colors.green[50],
                                child: Center(
                                  child: fruit.imageUrl != null
                                      ? Image.network(
                                          fruit.imageUrl!,
                                          height: 115,
                                          fit: BoxFit.contain,
                                        )
                                      : const Text(
                                          "🍎",
                                          style: TextStyle(fontSize: 70),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                              child: Column(
                                children: [
                                  Text(
                                    fruit.name,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${fruit.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}đ/${fruit.unit}",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => addToCart(fruit),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        minimumSize: const Size(
                                          double.infinity,
                                          44,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Thêm giỏ",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
