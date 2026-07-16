import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every .order(...) states its direction explicitly', () {
    final offenders = <String>[];

    for (final file in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) {
        continue;
      }
      final source = _withoutComments(file.readAsStringSync());
      for (final call in _orderCalls(source)) {
        if (!call.arguments.contains('ascending')) {
          final line = '\n'.allMatches(source.substring(0, call.offset)).length + 1;
          offenders.add('${file.path}:$line  .order(${call.arguments})');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'These .order(...) calls rely on postgrest-dart defaulting to DESCENDING, which is\n'
          'almost certainly not what they mean. Pass ascending: explicitly.\n\n${offenders.join('\n')}\n',
    );
  });
}

class _OrderCall {
  _OrderCall({required this.offset, required this.arguments});

  final int offset;
  final String arguments;
}

String _withoutComments(String source) {
  final buffer = StringBuffer();
  var index = 0;
  while (index < source.length) {
    final rest = source.length - index;
    if (rest >= 2 && source.startsWith('//', index)) {
      while (index < source.length && source[index] != '\n') {
        buffer.write(' ');
        index++;
      }
      continue;
    }
    if (rest >= 2 && source.startsWith('/*', index)) {
      while (index < source.length && !source.startsWith('*/', index)) {
        buffer.write(source[index] == '\n' ? '\n' : ' ');
        index++;
      }
      buffer.write('  ');
      index += 2;
      continue;
    }
    final character = source[index];
    if (character == "'" || character == '"') {
      buffer.write(character);
      index++;
      while (index < source.length && source[index] != character) {
        if (source[index] == r'\' && index + 1 < source.length) {
          buffer.write('  ');
          index += 2;
          continue;
        }
        buffer.write(source[index] == '\n' ? '\n' : ' ');
        index++;
      }
      if (index < source.length) {
        buffer.write(character);
        index++;
      }
      continue;
    }
    buffer.write(character);
    index++;
  }
  return buffer.toString();
}

Iterable<_OrderCall> _orderCalls(String source) sync* {
  const marker = '.order(';
  var index = source.indexOf(marker);
  while (index != -1) {
    final start = index + marker.length;
    var depth = 1;
    var end = start;
    while (end < source.length && depth > 0) {
      final character = source[end];
      if (character == '(') {
        depth++;
      } else if (character == ')') {
        depth--;
      }
      end++;
    }
    yield _OrderCall(offset: index, arguments: source.substring(start, end - 1));
    index = source.indexOf(marker, end);
  }
}
