import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference perfumes =
        FirebaseFirestore.instance.collection('perfumes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('منتجات العطور'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // نافذة لإضافة منتج جديد
              showDialog(
                context: context,
                builder: (context) {
                  final nameController = TextEditingController();
                  final priceController = TextEditingController();
                  final imageUrlController = TextEditingController();

                  return AlertDialog(
                    title: const Text('إضافة منتج جديد'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'اسم العطر'),
                        ),
                        TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'السعر'),
                        ),
                        TextField(
                          controller: imageUrlController,
                          decoration: const InputDecoration(labelText: 'رابط الصورة'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          perfumes.add({
                            'name': nameController.text,
                            'price': int.tryParse(priceController.text) ?? 0,
                            'imageUrl': imageUrlController.text,
                            'isAvailable': true,
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('إضافة'),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: perfumes.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: data['imageUrl'] != null
                    ? Image.network(
                        data['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported),
                title: Text(data['name'] ?? 'بدون اسم'),
                subtitle: Text('السعر: ${data['price']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: data['isAvailable'] ?? false,
                      onChanged: (value) {
                        perfumes.doc(docs[index].id).update({'isAvailable': value});
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        final nameController = TextEditingController(text: data['name']);
                        final priceController =
                            TextEditingController(text: data['price'].toString());

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('تعديل المنتج'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration:
                                      const InputDecoration(labelText: 'اسم العطر'),
                                ),
                                TextField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'السعر'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  perfumes.doc(docs[index].id).update({
                                    'name': nameController.text,
                                    'price': int.tryParse(priceController.text) ??
                                        data['price'],
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text('حفظ'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

