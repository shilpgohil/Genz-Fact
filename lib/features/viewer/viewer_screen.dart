import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/luma_colors.dart';
import '../../core/theme/luma_tokens.dart';
import '../../models/media_asset.dart';
import '../../services/library_controller.dart';
import '../../services/media_actions.dart';
import '../../services/open_video_player.dart';
import '../../widgets/metadata_sheet.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({
    super.key,
    required this.assets,
    required this.initialIndex,
  });

  final List<MediaAsset> assets;
  final int initialIndex;

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  late final PageController _pages;
  late int _index;
  var _chrome = true;
  var _pagingEnabled = true;

  @override
  void initState() {
    super.initState();
    _index = widget.assets.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.assets.length - 1);
    _pages = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.luma;
    final library = context.watch<LibraryController>();
    if (widget.assets.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('This photo is gone.')),
      );
    }
    final asset =
        library.byId(widget.assets[_index].id) ?? widget.assets[_index];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            physics: _pagingEnabled
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            itemCount: widget.assets.length,
            onPageChanged: (value) => setState(() => _index = value),
            itemBuilder: (context, i) {
              final item =
                  library.byId(widget.assets[i].id) ?? widget.assets[i];
              return _ViewerPage(
                asset: item,
                image: library.preview(item.id),
                onTap: () => setState(() => _chrome = !_chrome),
                onPagingEnabled: (enabled) {
                  if (enabled != _pagingEnabled) {
                    setState(() => _pagingEnabled = enabled);
                  }
                },
              );
            },
          ),
          if (_chrome)
            _TopBar(index: _index, total: widget.assets.length, asset: asset),
          if (_chrome) _BottomBar(asset: asset, accent: colors.accent),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.index,
    required this.total,
    required this.asset,
  });

  final int index;
  final int total;
  final MediaAsset asset;

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryController>();
    final colors = context.luma;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xAA000000), Color(0x00000000)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              IconButton(
                color: Colors.white,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
              Expanded(
                child: Text(
                  '${index + 1} / $total',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
              IconButton(
                color: asset.isFavorite ? colors.accent : Colors.white,
                onPressed: () async {
                  try {
                    await library.toggleFavorite(asset.id);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not update favorite.'),
                        ),
                      );
                    }
                  }
                },
                icon: Icon(
                  asset.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.asset, required this.accent});
  final MediaAsset asset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryController>();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0xCC000000), Color(0x00000000)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: LumaTokens.space8,
              vertical: LumaTokens.space8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Action(
                  icon: Icons.ios_share_rounded,
                  label: 'Share',
                  onTap: () => MediaActions.share(context, library, [asset.id]),
                ),
                _Action(
                  icon: Icons.info_outline_rounded,
                  label: 'Info',
                  onTap: () => showMetadataSheet(context, asset),
                ),
                _Action(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  onTap: () async {
                    final ok = await MediaActions.confirmDelete(
                      context,
                      1,
                      accessMode: library.library.accessMode,
                    );
                    if (!ok || !context.mounted) return;
                    try {
                      await library.delete([asset.id]);
                      if (context.mounted) Navigator.pop(context);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not delete this item.'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(LumaTokens.space12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerPage extends StatefulWidget {
  const _ViewerPage({
    required this.asset,
    required this.image,
    required this.onTap,
    required this.onPagingEnabled,
  });

  final MediaAsset asset;
  final ImageProvider? image;
  final VoidCallback onTap;
  final ValueChanged<bool> onPagingEnabled;

  @override
  State<_ViewerPage> createState() => _ViewerPageState();
}

class _ViewerPageState extends State<_ViewerPage> {
  final _transform = TransformationController();

  @override
  void initState() {
    super.initState();
    _transform.addListener(_onTransform);
  }

  void _onTransform() {
    final scale = _transform.value.getMaxScaleOnAxis();
    widget.onPagingEnabled(scale <= 1.05);
  }

  @override
  void dispose() {
    _transform.removeListener(_onTransform);
    _transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.asset.isVideo) {
      return _VideoBody(
        image: widget.image,
        onTap: widget.onTap,
        assetId: widget.asset.id,
      );
    }

    final child = widget.image == null
        ? const ColoredBox(color: Colors.black)
        : Image(
            image: widget.image!,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white54),
            ),
          );

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: () {
        if (_transform.value.getMaxScaleOnAxis() > 1.05) {
          _transform.value = Matrix4.identity();
        } else {
          _transform.value = Matrix4.identity()..scaleByDouble(2.4, 2.4, 1, 1);
        }
      },
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 5,
        child: Center(child: child),
      ),
    );
  }
}

class _VideoBody extends StatefulWidget {
  const _VideoBody({
    required this.image,
    required this.onTap,
    required this.assetId,
  });

  final ImageProvider? image;
  final VoidCallback onTap;
  final String assetId;

  @override
  State<_VideoBody> createState() => _VideoBodyState();
}

class _VideoBodyState extends State<_VideoBody> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final library = context.read<LibraryController>().library;
    final url = library.playbackUrl(widget.assetId);
    final path = url == null ? await library.filePath(widget.assetId) : null;
    if (!mounted) return;
    final controller = createVideoController(path: path, url: url);
    if (controller == null) return;
    try {
      await controller.initialize();
    } catch (_) {
      await controller.dispose();
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return GestureDetector(
      onTap: () {
        widget.onTap();
        if (controller != null && controller.value.isInitialized) {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
          setState(() {});
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (controller != null && controller.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio == 0
                    ? 16 / 9
                    : controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            )
          else if (widget.image != null)
            Image(image: widget.image!, fit: BoxFit.contain)
          else
            const ColoredBox(color: Colors.black),
          if (controller == null || !controller.value.isPlaying)
            const Center(
              child: Icon(
                Icons.play_circle_fill_rounded,
                size: 64,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }
}
