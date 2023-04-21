import 'dart:async';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flowy_eval/flowy_eval.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:flutter_eval/flutter_eval.dart';

/// Plugins that are downloaded via the marketplace must implement this class.
///
/// Each plugin should have a top-level function called `[registerPlugin]` that
/// returns a plugin that implements this class. For example:
/// ```dart
/// class MyFlowyPlugin implements FlowyPlugin {
/// // implementation here...
/// }
///
/// FlowyPlugin registerPlugin() {
///   return MyFlowyPlugin()
/// }
/// ```
abstract class FlowyPlugin {
  String get name;
  Iterable<ThemeData>? get themes;
  Iterable<ShortcutEvent>? get shortcuts;
  Iterable<NodeWidgetBuilder>? get nodes;
}

class PluginLocationService {
  static Directory get location => Directory("C:\\Users\\IT\\Development\\AppFlowy\\dynamic_editor_plugin_demo\\lib\\plugins");
}

/// Singleton class which can only be constructed asynchronously
///
/// The path of the plugins should be initialized by another service
/// since the plugins must be locatable at runtime.
class PluginLoader {
  PluginLoader._();

  static final Completer _completer = Completer();
  final Compiler _compiler = Compiler()
    ..addPlugin(flutterEvalPlugin)
    ..addPlugin(flowyEvalPlugin);
  late Runtime _runtime;

  static PluginLoader? _instance;
  /// A factory constructor that returns the singleton instance of this class
  static Future<PluginLoader> get instance async {
    if (_instance == null) {
      _instance = PluginLoader._();
      await _instance!._initialize();
      _completer.complete();
    } else if (!_completer.isCompleted) {
      await _completer.future;
    }
    return _instance!;
  }

  bool _isFlowyPluginDirectory(FileSystemEntity entity) =>
    entity is Directory;
    // && p.extension(entity.path) == 'flowy_plugin';

  Future<Iterable<_PluginLib>> get _libs async => PluginLocationService.location
      .listSync()
      .where(_isFlowyPluginDirectory)
      .map<Directory>((entity) => entity as Directory)
      .map<_PluginLib>((dir) => _PluginLib.fromDirectory(dir))
      .toList();

  Future<void> _initialize() async {
    for (final lib in await _libs) {
      final plugin = _compiler.compile({lib.package: lib.sources});
      final out = File('${lib.package}.evc');
      await out.writeAsBytes(plugin.write());
      _runtime = Runtime.ofProgram(plugin)
        ..addPlugin(flutterEvalPlugin)
        ..addPlugin(flowyEvalPlugin)
        ..setup();
      // TODO(a-wallen) scan for all types of plugins right now we only support shortcut events.
      final flowyPlugin = _runtime.executeLib('package:${lib.package}/plugin.dart', 'getShortcut') as $Instance;
      _plugins.add(flowyPlugin.$value);
    }
  }

  final List<ShortcutEvent> _plugins = [];
  /// When an awaited instance of [PluginLoader] is available, the plugins should
  /// also be initialized, and we can get a list of all libraries that are dynamically
  /// added to the applciation
  ///
  /// This is a copy of the backing property, the plugins should not be modifiable by the user.
  Iterable<ShortcutEvent> get plugins => List.from(_plugins);
}

class _PluginLib {
  static const String fileExt = '.flowy_plugin';
  /// Expects plugins in the following format.
  ///
  /// <directory> (the directory is also the library name)
  ///   - <plugin_1> (also a directory)
  ///     file1.dart (the content of plugin_1)
  ///     file2.dart
  factory _PluginLib.fromDirectory(Directory directory) {
    if (!directory.name.contains(_PluginLib.fileExt)) {
      // TODO (a-wallen) throw better exception
      throw Exception('Loaded plugin library does not have the ${_PluginLib.fileExt} extension.');
    }

    return _PluginLib(
      package: directory.name.split('.').first,
      sources: directory.listSync()
        .whereType<File>()
        .toList(),
    );
  }

  _PluginLib({
    required String package,
    required Iterable<File> sources,
  }) : _package = package, _sources = sources;

  final String _package;
  String get package => _package;

  final Iterable<File> _sources;
  Map<String, String> get sources => _sources.fold({}, (previousValue, source) => {
    ...previousValue,
    ...{
      source.name: source.readAsStringSync(),
    }
  });
}

extension _DirName on Directory {
  String get name => path.split(Platform.pathSeparator).last;
}

extension _FileName on File {
  String get name => path.split(Platform.pathSeparator).last;
}
