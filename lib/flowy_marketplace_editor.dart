import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dynamic_editor_plugin_demo/plugin_loader.dart';
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
    return FutureBuilder<PluginLoader>(
      future: PluginLoader.instance,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final List<ShortcutEvent> plugins = snapshot.data!.plugins.toList();
          return AppFlowyEditor(
            editorState: editorState,
            shortcutEvents: [
              ...plugins.fold([], (val, plugin) => [...val, plugin ]),
              ...userShortcutEvents,
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
