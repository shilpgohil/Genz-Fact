import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/luma_colors.dart';
import '../../core/theme/luma_tokens.dart';
import '../../core/utilities/formatters.dart';
import '../../models/app_models.dart';
import '../../models/library_health.dart';
import '../../services/category_engine.dart';
import '../../services/library_controller.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_surface.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/moment_card.dart';
import '../../widgets/photo_tile.dart';
import '../../widgets/section_header.dart';
import '../cleanup/cleanup_screen.dart';
import '../collection/collection_screen.dart';
import '../moments/moments_screen.dart';
import '../settings/settings_screen.dart';
import '../storage/health_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final colors = context.luma;
    final assets = library.visibleAssets;
    final recent = assets.take(12).toList();

    if (library.phase == LibraryPhase.indexing && assets.isEmpty) {
      return const LoadingState();
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                LumaTokens.space20,
                LumaTokens.space12,
                LumaTokens.space12,
                LumaTokens.space8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Luma',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        Text(
                          library.indexing
                              ? 'Indexing ${library.indexedCount} items…'
                              : formatCount(assets.length, 'item'),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Gallery health',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const HealthScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.auto_awesome_outlined),
                  ),
                  if (library.isSessionLibrary)
                    IconButton(
                      tooltip: 'Add photos',
                      onPressed: library.manageLimitedAccess,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                    ),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (library.permission == LumaPermission.limited)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LumaTokens.space20,
              ),
              child: LumaGlass(
                padding: const EdgeInsets.all(LumaTokens.space16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Limited access — Luma can only see the photos you selected.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: library.manageLimitedAccess,
                      child: Text(
                        'Manage',
                        style: TextStyle(color: colors.accent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (assets.isEmpty)
          SliverFillRemaining(
            child: EmptyState(
              title: 'No photos yet',
              message: library.isSessionLibrary
                  ? 'Choose photos from this device. Luma keeps them in this tab and does not upload them.'
                  : 'When this library has photos or videos, Luma will group them into moments and categories automatically.',
              actionLabel: library.isSessionLibrary ? 'Choose photos' : null,
              onAction: library.isSessionLibrary
                  ? library.manageLimitedAccess
                  : null,
            ),
          )
        else ...[
          if (recent.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recent',
                subtitle: 'Latest in this library',
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 168,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LumaTokens.space20,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final asset = recent[i];
                    return SizedBox(
                      width: 118,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          LumaTokens.radiusTile,
                        ),
                        child: PhotoTile(
                          asset: asset,
                          image: library.thumb(asset.id),
                          heroTag: 'home-recent-${asset.id}',
                          onTap: () => openViewer(context, assets, asset.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          if (library.categories.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SectionHeader(title: 'Discover')),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 108,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LumaTokens.space20,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: library.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final cat = library.categories[i];
                    return _CategoryChip(
                      category: cat,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => CollectionScreen(
                              title: cat.title,
                              assets: assetsForCategory(
                                library.visibleAssets,
                                cat.kind,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Moments',
              subtitle: library.moments.isEmpty
                  ? 'Need a few photos taken close together'
                  : formatCount(library.moments.length, 'moment'),
              actionLabel: library.moments.length > 3 ? 'See all' : null,
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const MomentsScreen()),
              ),
            ),
          ),
          if (library.moments.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: LumaTokens.space20),
                child: Text(
                  'Moments appear when several photos are captured within a few hours of each other.',
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: library.moments.take(4).length,
              itemBuilder: (context, i) {
                final moment = library.moments[i];
                return MomentCard(
                  moment: moment,
                  imageFor: (id) =>
                      library.thumb(id, size: LumaTokens.thumbnailHero),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CollectionScreen(
                        title: moment.title,
                        subtitle: moment.subtitle,
                        assets: moment.assets,
                        heroPrefix: 'moment-${moment.id}',
                      ),
                    ),
                  ),
                );
              },
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                LumaTokens.space20,
                LumaTokens.space24,
                LumaTokens.space20,
                120,
              ),
              child: Material(
                color: colors.surface,
                borderRadius: BorderRadius.circular(LumaTokens.radiusCard),
                child: InkWell(
                  borderRadius: BorderRadius.circular(LumaTokens.radiusCard),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const CleanupScreen(),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(LumaTokens.space20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_fix_high_outlined,
                          color: colors.accent,
                        ),
                        const SizedBox(width: LumaTokens.space16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cleanup',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Duplicates, large files, and screenshots — you choose what to remove.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.onTap});
  final MediaCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(LumaTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(LumaTokens.radiusCard),
        child: SizedBox(
          width: 148,
          child: Padding(
            padding: const EdgeInsets.all(LumaTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  formatCount(category.count, 'item'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
