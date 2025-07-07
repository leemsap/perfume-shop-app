import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'providers/perfume_provider.dart';
import 'favorites_page.dart';
import 'login_page.dart';
import 'models/perfume.dart';
import 'cart_page.dart'; 






void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => PerfumeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متجر العطور',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_mall_rounded, size: 100, color: Colors.deepPurple),
              SizedBox(height: 20),
              Text('مرحباً بك في متجر العطور',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  textAlign: TextAlign.center),
              SizedBox(height: 12),
              Text('اكتشف أجمل وأرقى أنواع العطور الأصلية.',
                  style: TextStyle(fontSize: 16, color: Colors.black87), textAlign: TextAlign.center),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PerfumeShop()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: StadiumBorder(),
                ),
                child: Text('تسوق الآن', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PerfumeShop extends StatelessWidget {
  final List<Perfume> products = [
    Perfume(id: '1', name: 'عطر الفخامة', price: '300', image: 'assets/images/perfume1.jpeg'),
    Perfume(id: '2', name: 'عطر الورود', price: '350', image: 'assets/images/perfume2.jpeg'),
    Perfume(id: '3', name: 'عطر النعومة', price: '280', image: 'assets/images/perfume3.jpeg'),
    Perfume(id: '4', name: 'عطر المساء', price: '320', image: 'assets/images/perfume4.jpeg'),
    Perfume(id: '5', name: 'عطر الرمان', price: '290', image: 'assets/images/perfume5.jpeg'),
  ];

  String formatPrice(String price) {
    double value = double.tryParse(price) ?? 0;
    return 'ج.س ${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PerfumeProvider>(context);

    return Scaffold(
     appBar: AppBar(
  title: Text('متجر العطور', style: TextStyle(color: Colors.white)),
  backgroundColor: Colors.deepPurple,
  actions: [
    IconButton(
      icon: Icon(Icons.favorite, color: Colors.white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FavoritesPage()),
        );
      },
    ),
    IconButton(
      icon: Icon(Icons.shopping_cart, color: Colors.white),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CartPage()), // تأكد CartPage موجودة
        );
      },
    ),
    IconButton(
      icon: Icon(Icons.logout, color: Colors.white),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );
      },
    ),
  ],
),

      backgroundColor: Color.fromARGB(255, 204, 122, 34),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        itemCount: products.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75),
        itemBuilder: (context, index) {
          final product = products[index];
          final isFav = provider.isFavorite(product);

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 3,
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.asset(product.image, height: 120, fit: BoxFit.cover, width: double.infinity),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.grey),
                        onPressed: () => provider.toggleFavorite(product),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Text(product.name, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                Text(formatPrice(product.price), style: TextStyle(color: Colors.deepPurple)),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    provider.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.name} أُضيف إلى السلة')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: Text('أضف إلى السلة', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
