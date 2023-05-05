import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flowy_plugin/flowy_plugin.dart';
import 'package:flutter/material.dart';

class FlowyMarketplaceEditor extends StatelessWidget {
  const FlowyMarketplaceEditor({
    super.key,
    required this.editorState,
    this.userShortcutEvents = const [],
  });

  final EditorState editorState;
  final List<ShortcutEvent> userShortcutEvents;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FlowyPluginService>(
      future: FlowyPluginService.instance,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final List<FlowyPlugin> plugins = snapshot.data!.plugins.toList();
          return AppFlowyEditor(
            editorState: editorState,
            shortcutEvents: [
              ...plugins.fold([], (val, plugin) => [...val, ...plugin.shortcutEvents]),
              ...userShortcutEvents,
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
