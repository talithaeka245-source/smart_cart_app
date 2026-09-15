import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

// 1. FORMATTER RUPIAH
extension FormatRupiah on num {
  String toRupiah() => toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

// 2. MODEL PRODUCT & CART ITEM
class Product {
  final String id;
  final String name;
  final int price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  int get totalPrice => product.price * quantity;
}

// 3. STATE MANAGER (CART PROVIDER)
class CartProvider extends ChangeNotifier {
  final List<Product> _products = [
    Product(id: '1', name: 'Laptop RPL Pro', price: 8999000, imageUrl: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=300'),
    Product(id: '2', name: 'Mouse Wireless', price: 185000, imageUrl: 'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=300'),
    Product(id: '3', name: 'Keyboard Mech', price: 520000, imageUrl: 'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=300'),
    Product(id: '4', name: 'Monitor 24 Inch', price: 1750000, imageUrl: 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=300'),
    Product(id: '5', name: 'Earphone TWS', price: 299000, imageUrl: 'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=300'),
    Product(id: '6', name: 'Smartphone 5G', price: 2899000, imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=300'),
  ];

  final Map<String, CartItem> _cartItems = {};
  String _searchQuery = '';

  CartProvider() {
    _cartItems['1'] = CartItem(product: _products[0], quantity: 1);
    _cartItems['2'] = CartItem(product: _products[1], quantity: 1);
    _cartItems['5'] = CartItem(product: _products[4], quantity: 1);
    _cartItems['6'] = CartItem(product: _products[5], quantity: 1);
  }

  String get searchQuery => _searchQuery;

  List<Product> get products {
    if (_searchQuery.isEmpty) return [..._products];
    return _products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Map<String, CartItem> get cartItems => {..._cartItems};

  int get totalItemCount => _cartItems.values.fold(0, (sum, item) => sum + item.quantity);
  int get totalBayar => _cartItems.values.fold(0, (sum, item) => sum + item.totalPrice);

  int getQuantity(String productId) => _cartItems[productId]?.quantity ?? 0;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addItem(Product product) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems[product.id]!.quantity += 1;
    } else {
      _cartItems[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_cartItems.containsKey(productId)) return;
    if (_cartItems[productId]!.quantity > 1) {
      _cartItems[productId]!.quantity -= 1;
    } else {
      _cartItems.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }
}

// 4. UI TAMPILAN
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'E-Catalog SMKN 3 Tuban',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'Roboto', scaffoldBackgroundColor: const Color(0xFFE8F1F9)),
    home: const MobileFrame(),
  );
}

class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFD6E4F0),
    body: Center(
      child: Container(
        width: 380, height: 740,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))]),
        child: const ClipRRect(borderRadius: BorderRadius.all(Radius.circular(24)), child: MainScreen()),
      ),
    ),
  );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1575E6), elevation: 0,
        leading: _currentIndex == 1
            ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => setState(() => _currentIndex = 0))
            : Padding(padding: const EdgeInsets.all(10.0), child: Container(decoration: const BoxDecoration(color: Color(0xFFFFCC00), shape: BoxShape.circle), child: const Icon(Icons.school, size: 18, color: Color(0xFF1575E6)))),
        title: Text(_currentIndex == 0 ? 'E-Catalog SMKN 3 Tuban' : 'Keranjang Belanja', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(alignment: Alignment.center, children: [
              IconButton(icon: Icon(_currentIndex == 0 ? Icons.shopping_cart : Icons.auto_awesome, color: Colors.white, size: 22), onPressed: () => setState(() => _currentIndex = 1)),
              if (_currentIndex == 0 && cartProvider.totalItemCount > 0)
                Positioned(right: 4, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: Text('${cartProvider.totalItemCount}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ]),
          )
        ],
      ),
      body: _currentIndex == 0 ? _buildKatalog(cartProvider) : _buildKeranjang(cartProvider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, selectedItemColor: const Color(0xFF1575E6), unselectedItemColor: const Color(0xFF8FA7C4),
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Katalog'),
          BottomNavigationBarItem(icon: Badge(label: Text('${cartProvider.totalItemCount}'), isLabelVisible: cartProvider.totalItemCount > 0, child: const Icon(Icons.shopping_cart)), label: 'Keranjang'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildKatalog(CartProvider cartProvider) => Padding(
    padding: const EdgeInsets.all(12.0),
    child: Column(children: [
      Container(
        height: 42, padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCCE0F5))),
        child: Row(children: [
          const Icon(Icons.search, color: Color(0xFF1575E6), size: 20), const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (val) => cartProvider.setSearchQuery(val),
              decoration: const InputDecoration(hintText: 'Cari produk...', hintStyle: TextStyle(fontSize: 13, color: Colors.grey), border: InputBorder.none, isDense: true),
            ),
          ),
          const Icon(Icons.tune, color: Color(0xFF1575E6), size: 20),
        ]),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: cartProvider.products.isEmpty
            ? const Center(child: Text('Produk tidak ditemukan.'))
            : GridView.builder(
                itemCount: cartProvider.products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.62, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemBuilder: (_, i) => _buildProductCard(cartProvider.products[i], cartProvider),
              ),
      ),
    ]),
  );

  Widget _buildProductCard(Product item, CartProvider cartProvider) {
    final qty = cartProvider.getQuantity(item.id);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE1ECF7))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(item.imageUrl, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFFEAF2FB), child: const Icon(Icons.image, color: Color(0xFF1575E6)))),
          ),
        ),
        const SizedBox(height: 8),
        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text('Rp ${item.price.toRupiah()}', style: const TextStyle(color: Color(0xFF1575E6), fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity, height: 30,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1575E6), elevation: 0, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
            onPressed: () {
              cartProvider.addItem(item);
              ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text('${item.name} ditambahkan ke keranjang!'), duration: const Duration(seconds: 1), backgroundColor: const Color(0xFF1575E6)));
            },
            icon: const Icon(Icons.add_shopping_cart, size: 14, color: Colors.white),
            label: Text(qty > 0 ? 'Tambah ($qty)' : 'Tambah', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _buildKeranjang(CartProvider cartProvider) {
    final cartList = cartProvider.cartItems.values.toList();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE1ECF7))),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFF1575E6), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 16)),
            const SizedBox(width: 8),
            const Text('Total Pembayaran:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('Rp ${cartProvider.totalBayar.toRupiah()}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1575E6))),
          ]),
        ),
        const SizedBox(height: 12),
        const Row(children: [Icon(Icons.shopping_cart, size: 16, color: Color(0xFF1575E6)), SizedBox(width: 6), Text('Daftar Item Belanja', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1575E6), fontSize: 13))]),
        const SizedBox(height: 8),
        Expanded(
          child: cartList.isEmpty
              ? const Center(child: Text('Keranjang belanjaan masih kosong.'))
              : ListView.builder(itemCount: cartList.length, itemBuilder: (_, i) => _buildCartTile(cartList[i], cartProvider)),
        ),
        SizedBox(
          width: double.infinity, height: 40,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1575E6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            label: const Text('Lanjutkan ke Pembayaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ]),
    );
  }

  Widget _buildCartTile(CartItem cartItem, CartProvider cartProvider) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE1ECF7))),
    child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network(cartItem.product.imageUrl, width: 42, height: 42, fit: BoxFit.cover)),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(cartItem.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), Text('Rp ${cartItem.product.price.toRupiah()}', style: const TextStyle(color: Color(0xFF1575E6), fontSize: 11, fontWeight: FontWeight.w600))])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(6)),
        child: Row(children: [
          GestureDetector(onTap: () => cartProvider.removeSingleItem(cartItem.product.id), child: const Text('-', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1575E6)))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('${cartItem.quantity}x', style: const TextStyle(fontSize: 11))),
          GestureDetector(onTap: () => cartProvider.addItem(cartItem.product), child: const Text('+', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1575E6)))),
        ]),
      ),
      const SizedBox(width: 8),
      GestureDetector(onTap: () => cartProvider.removeItem(cartItem.product.id), child: const Icon(Icons.delete_outline, color: Color(0xFF1575E6), size: 18)),
    ]),
  );
}