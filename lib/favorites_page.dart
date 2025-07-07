import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/perfume_provider.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PerfumeProvider>(context);
    final favorites = provider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: Text('المفضلة'),
        backgroundColor: Colors.deepPurple,
      ),
      body: favorites.isEmpty
          ? Center(child: Text('لا توجد عناصر في المفضلة'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return ListTile(
                  leading: Image.asset(item.image, width: 50, height: 50),
                  title: Text(item.name),
                  subtitle: Text('ج.س ${item.price}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => provider.toggleFavorite(item),
                  ),
                );
              },
            ),
    );
  }
}
