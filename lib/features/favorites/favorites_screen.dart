import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/category_engine.dart';
import '../../services/library_controller.dart';
import '../collection/collection_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    return CollectionScreen(
      title: 'Favorites',
      subtitle: 'Matches the device favorite flag when the system supports it.',
      assets: favoriteAssets(library.visibleAssets),
      heroPrefix: 'favorites',
    );
  }
}
