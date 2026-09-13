import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/luma_tokens.dart';
import '../../services/library_controller.dart';
import '../../services/search_engine.dart';
import '../../widgets/asset_grid.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/search_field.dart';
import '../collection/collection_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  var _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final intent = parseSearchQuery(_query);
    final results = _query.trim().isEmpty
        ? library.visibleAssets.take(0).toList()
        : library.search(_query);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              LumaTokens.space20,
              LumaTokens.space8,
              LumaTokens.space20,
              LumaTokens.space12,
            ),
            child: LumaSearchField(
              controller: _controller,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LumaTokens.space20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dates, months, years, videos, screenshots, favorites, large files, album names. Not scene recognition.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: LumaTokens.space8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final hint in const [
                'Yesterday',
                'Videos',
                'Screenshots',
                'Favorites',
                'August',
              ])
                ActionChip(
                  label: Text(hint),
                  onPressed: () {
                    _controller.text = hint;
                    setState(() => _query = hint);
                  },
                ),
            ],
          ),
          const SizedBox(height: LumaTokens.space12),
          Expanded(
            child: _query.trim().isEmpty
                ? const EmptyState(
                    icon: Icons.search_rounded,
                    title: 'Search this library',
                    message: 'Try “2024”, “videos”, or an album name. Results stay on device.',
                  )
                : results.isEmpty
                ? EmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: 'No matches',
                    message: intent.unrecognized.isEmpty
                        ? 'Nothing in the library matches that metadata.'
                        : 'Not understood as a filter: ${intent.unrecognized.join(', ')}. Titles are still searched.',
                  )
                : AssetGrid(
                    assets: results,
                    heroPrefix: 'search',
                    onOpen: (asset) => openViewer(context, results, asset.id),
                  ),
          ),
        ],
      ),
    );
  }
}
