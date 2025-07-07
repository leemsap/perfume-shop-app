import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/perfume.dart';
import '../providers/perfume_provider.dart';

class CartPage extends StatelessWidget {
  String formatPrice(String price) {
    double value = double.tryParse(price) ?? 0;
    return 'ج.س ${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PerfumeProvider>(context);
    final cartItems = provider.cartItems;

    double total = cartItems.fold(
      0,
      (sum, item) => sum + (double.tryParse(item.price) ?? 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('سلة المشتريات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: cartItems.isEmpty
          ? Center(child: Text('السلة فارغة'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: Image.asset(item.image, width: 50, height: 50, fit: BoxFit.cover),
                        title: Text(item.name),
                        subtitle: Text(formatPrice(item.price)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => provider.removeFromCart(item),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'الإجمالي: ${formatPrice(total.toString())}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('تم إتمام الشراء بنجاح!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        child: Text('إتمام الشراء', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
