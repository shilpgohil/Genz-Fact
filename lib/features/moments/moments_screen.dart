import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/library_controller.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/moment_card.dart';
import '../collection/collection_screen.dart';

class MomentsScreen extends StatelessWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryController>();
    final moments = library.moments;

    return Scaffold(
      appBar: AppBar(title: const Text('Moments')),
      body: moments.isEmpty
          ? const EmptyState(
              icon: Icons.nights_stay_outlined,
              title: 'No moments yet',
              message: 'Luma groups photos taken close together in time. Titles come from weekdays and time of day — never invented events.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: moments.length,
              itemBuilder: (context, i) {
                final moment = moments[i];
                return MomentCard(
                  moment: moment,
                  imageFor: library.thumb,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CollectionScreen(
                        title: moment.title,
                        subtitle: moment.subtitle,
                        assets: moment.assets,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
