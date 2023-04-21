import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:dynamic_editor_plugin_demo/flowy_marketplace_editor.dart';
import 'package:dynamic_editor_plugin_demo/plugin_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppFlowyEditorLocalizations.delegate,
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

enum FormFactor {
  collapsed._(),
  expanded._();

  const FormFactor._();

  factory FormFactor.fromSize(Size size) {
    if (size.width < 800) return FormFactor.collapsed;
    return FormFactor.expanded;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final EditorState editorState = EditorState.empty();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final FormFactor formFactor = FormFactor.fromSize(size);
    return MobileView(editorState: EditorState.empty());
    switch (formFactor) {
      case FormFactor.collapsed:
      case FormFactor.expanded:
        return DesktopView(editorState: editorState);
    }
  }
}

class MobileView extends StatelessWidget {
  const MobileView({super.key, required this.editorState});

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(child: PluginDrawer(),),
      body: FlowyMarketplaceEditor(editorState: editorState)
    );
  }
}

class DesktopView extends StatelessWidget {
  const DesktopView({super.key, required this.editorState});

  final EditorState editorState;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const PluginDrawer(),
        Expanded(child: FlowyMarketplaceEditor(editorState: editorState)),
      ],
    );
  }
}
