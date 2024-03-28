import 'package:ar_kit/features/ar_add_anchor.dart';
import 'package:ar_kit/features/ar_core_android.dart';
import 'package:ar_kit/features/ar_with_animation.dart';
import 'package:ar_kit/features/simple_ar_kit.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: ExampleList(),
      ),
    );
  }
}

class ExampleList extends StatelessWidget {
  const ExampleList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ExampleCard(
          example: Example(
            'AR With Animation',
            '-',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ArWithAnimation(),
              ),
            ),
          ),
        ),
        ExampleCard(
          example: Example(
            'Image tracking',
            '-',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimpleArKit(),
              ),
            ),
          ),
        ),
        ExampleCard(
          example: Example(
            'Custom Anchor',
            '-',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ArAddAnchor(),
              ),
            ),
          ),
        ),
        ExampleCard(
          example: Example(
            'RealtyKit',
            '-',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ArAddAnchor(),
              ),
            ),
          ),
        ),
        ExampleCard(
          example: Example(
            'Android ARCore',
            '-',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ArDrawingAndroidScreen(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ExampleCard extends StatelessWidget {
  const ExampleCard({super.key, required this.example});
  final Example example;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          example.onTap();
        },
        child: ListTile(
          title: Text(example.name),
          subtitle: Text(example.description),
        ),
      ),
    );
  }
}

class Example {
  const Example(
    this.name,
    this.description,
    this.onTap,
  );
  final String name;
  final String description;
  final Function onTap;
}
