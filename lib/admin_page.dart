import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'login_page.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final picker = ImagePicker();

  Future<String> convertImageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  void showEditDialog(DocumentSnapshot product) async {
    Map<String, dynamic> data = product.data() as Map<String, dynamic>;

    TextEditingController nameController = TextEditingController(text: data['name']);
    TextEditingController priceController = TextEditingController(text: data['price'].toString());
    bool isAvailable = data['isAvailable'];
    File? newImageFile;
    String imageBase64 = data.containsKey('imageBase64') ? data['imageBase64'] : '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل المنتج'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      newImageFile = File(pickedFile.path);
                    });
                  }
                },
                child: newImageFile != null
                    ? Image.file(newImageFile!, height: 100)
                    : (data.containsKey('imageBase64') && data['imageBase64'] != ''
                        ? Image.memory(base64Decode(data['imageBase64']), height: 100)
                        : Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey[300],
                            child: Icon(Icons.image_not_supported, color: Colors.grey[700]),
                          )),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'اسم المنتج'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'السعر'),
              ),
              SwitchListTile(
                title: Text('متوفر'),
                value: isAvailable,
                onChanged: (value) {
                  setState(() {
                    isAvailable = value;
                  });
                },
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              String updatedImageBase64 = imageBase64;

              if (newImageFile != null) {
                updatedImageBase64 = await convertImageToBase64(newImageFile!);
              }

              FirebaseFirestore.instance
                  .collection('products')
                  .doc(product.id)
                  .update({
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0,
                'isAvailable': isAvailable,
                'imageBase64': updatedImageBase64,
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تحديث المنتج')),
              );
            },
            child: Text('حفظ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حذف المنتج')),
    );
  }

  void showAddProductDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    bool isAvailable = true;
    File? imageFile;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة منتج جديد'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: imageFile != null
                    ? Image.file(imageFile!, height: 100)
                    : Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.add_a_photo, color: Colors.grey[700]),
                      ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'اسم المنتج'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'السعر'),
              ),
              SwitchListTile(
                title: Text('متوفر'),
                value: isAvailable,
                onChanged: (value) {
                  setState(() {
                    isAvailable = value;
                  });
                },
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (imageFile == null ||
                  nameController.text.isEmpty ||
                  priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('الرجاء إدخال جميع البيانات')),
                );
                return;
              }

              String imageBase64 = await convertImageToBase64(imageFile!);

              FirebaseFirestore.instance.collection('products').add({
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0,
                'isAvailable': isAvailable,
                'imageBase64': imageBase64,
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم إضافة المنتج')),
              );
            },
            child: Text('إضافة'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('صفحة الأدمن', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: showAddProductDialog,
          ),
          IconButton(
            icon: Icon(Icons.logout),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('لا توجد منتجات حالياً'));
          }

          final products = snapshot.data!.docs;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              Map<String, dynamic> data = product.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  leading: data.containsKey('imageBase64') && data['imageBase64'] != ''
                      ? Image.memory(
                          base64Decode(data['imageBase64']),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: Icon(Icons.image_not_supported),
                        ),
                  title: Text(data['name']),
                  subtitle: Text('السعر: ${data['price']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => showEditDialog(product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteProduct(product.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
