import 'package:dynamic_editor_plugin_demo/plugin_loader.dart';
import 'package:flutter/material.dart';

/// Shows the available plugins
class PluginDrawer extends StatelessWidget {
  const PluginDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PluginLoader.instance,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List plugins = snapshot.data!.plugins.toList();
          return ListView.builder(
            itemCount: snapshot.data!.plugins.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: plugins[index].name,
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
