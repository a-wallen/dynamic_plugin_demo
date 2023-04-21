import 'package:flutter/widgets.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

const DoubleDividerType = 'double_divider';

ShortcutEvent helloWorld = ShortcutEvent(
  key: 'hello_world',
  character: 'a',
  handler: (state, event) {
    print('This is code from a dynamic plugin!');
    return KeyEventResult.handled;
});
