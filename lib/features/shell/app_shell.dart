import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/luma_tokens.dart';
import '../../services/selection_controller.dart';
import '../../widgets/glass_bottom_bar.dart';
import '../albums/albums_screen.dart';
import '../gallery/gallery_screen.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _index = 0;

  static const _items = [
    GlassBottomBarItem(
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome,
      label: 'Home',
    ),
    GlassBottomBarItem(
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
      label: 'Library',
    ),
    GlassBottomBarItem(
      icon: Icons.search_rounded,
      selectedIcon: Icons.search_rounded,
      label: 'Search',
    ),
    GlassBottomBarItem(
      icon: Icons.photo_album_outlined,
      selectedIcon: Icons.photo_album_rounded,
      label: 'Albums',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: _index,
              children: const [
                HomeScreen(),
                GalleryScreen(),
                SearchScreen(),
                AlbumsScreen(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassBottomBar(
              items: _items,
              index: _index,
              onSelect: (value) {
                context.read<SelectionController>().clear();
                setState(() => _index = value);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Extra padding token referenced if a screen needs to clear the floating bar.
double get lumaShellBottomClearance => 96 + LumaTokens.space16;
