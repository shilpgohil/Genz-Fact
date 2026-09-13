import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/luma_tokens.dart';
import '../core/utilities/formatters.dart';
import '../models/date_section.dart';
import '../models/media_asset.dart';
import '../services/date_grouping.dart';
import '../services/library_controller.dart';
import '../services/selection_controller.dart';
import 'photo_tile.dart';

class AssetGrid extends StatelessWidget {
  const AssetGrid({
    super.key,
    required this.assets,
    this.heroPrefix,
    this.onOpen,
    this.padding,
  });

  final List<MediaAsset> assets;
  final String? heroPrefix;
  final void Function(MediaAsset asset)? onOpen;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final selection = context.watch<SelectionController>();
    final landscape = MediaQuery.sizeOf(context).width > 700;
    final columns = library.appSettings.columnsFor(landscape: landscape);
    final sections = groupByDay(assets);
    final rows = buildGalleryRows(sections, columns);

    return ListView.builder(
      padding: padding ?? const EdgeInsets.only(bottom: 120),
      itemCount: rows.length,
      itemBuilder: (context, index) {
        final row = rows[index];
        if (row.kind == GalleryRowKind.header) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              LumaTokens.space16,
              LumaTokens.space20,
              LumaTokens.space16,
              LumaTokens.space8,
            ),
            child: Text(
              formatDayHeader(row.date!),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: LumaTokens.gridGap),
          child: Row(
            children: [
              for (final asset in row.assets)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(LumaTokens.gridGap / 2),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PhotoTile(
                        asset: asset,
                        image: library.thumb(asset.id),
                        selected: selection.contains(asset.id),
                        selectionMode: selection.isActive,
                        heroTag: '${heroPrefix ?? 'grid'}-${asset.id}',
                        onTap: () {
                          if (selection.isActive) {
                            selection.toggle(asset.id);
                          } else {
                            onOpen?.call(asset);
                          }
                        },
                        onLongPress: () => selection.toggle(asset.id),
                      ),
                    ),
                  ),
                ),
              for (var i = row.assets.length; i < columns; i++)
                const Expanded(child: SizedBox()),
            ],
          ),
        );
      },
    );
  }
}
