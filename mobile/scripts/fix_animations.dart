import 'dart:io';

void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  final targetSuffix =
      '.animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0)';

  for (final file in files) {
    var content = file.readAsStringSync();
    if (!content.contains(targetSuffix)) continue;

    // Remove the suffix from the end of Scaffold (which is usually where it is)
    content = content.replaceAll(targetSuffix, '');

    // Now find 'body: '
    int bodyIndex = content.indexOf('body: ');
    if (bodyIndex == -1) {
      bodyIndex = content.indexOf('body:\n');
    }
    if (bodyIndex == -1) {
      bodyIndex = content.indexOf('body:\r\n');
    }

    if (bodyIndex != -1) {
      // Find the start of the expression
      int start = bodyIndex + 5;

      int parenCount = 0;
      int braceCount = 0;
      int bracketCount = 0;
      int i = start;
      bool started = false;

      while (i < content.length) {
        final c = content[i];
        if (c == '(') {
          parenCount++;
        } else if (c == ')') {
          parenCount--;
        } else if (c == '{') {
          braceCount++;
        } else if (c == '}') {
          braceCount--;
        } else if (c == '[') {
          bracketCount++;
        } else if (c == ']') {
          bracketCount--;
        }

        if (!started && c != ' ' && c != '\n' && c != '\r') {
          started = true;
        }

        if (started &&
            parenCount == 0 &&
            braceCount == 0 &&
            bracketCount == 0) {
          // Are we at the end of the expression?
          // The expression ends when we hit a comma or a closing bracket of the parent (like `)` for Scaffold)
          // Wait, if body is `body: Center(child: Text('A')),`
          // the counts will be 0 after `)` of Center.
          // Let's check if the next non-whitespace char is `,` or `)`
          int nextI = i + 1;
          while (nextI < content.length &&
              (content[nextI] == ' ' ||
                  content[nextI] == '\n' ||
                  content[nextI] == '\r')) {
            nextI++;
          }
          if (nextI < content.length &&
              (content[nextI] == ',' || content[nextI] == ')')) {
            // We found the end!
            content =
                content.substring(0, i + 1) +
                targetSuffix +
                content.substring(i + 1);
            break;
          }
        }
        i++;
      }
    }

    file.writeAsStringSync(content);
    // ignore: avoid_print
    print('Updated ${file.path}');
  }
}
