import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_flush_bar/flutter_flush_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final FlutterFlushBar _flushBar = FlutterFlushBar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyHomePage(title: 'title')),
              ),
              child: const Text('Next'),
            ),
            if (ModalRoute.of(context)?.canPop ?? false)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Pop'),
              ),
            TextButton(
              onPressed: () async {
                // 生成随机数
                // 再根据随机数生成随机颜色

                final random = Random();
                final color = Color.fromARGB(
                  255,
                  random.nextInt(255),
                  random.nextInt(255),
                  random.nextInt(255),
                );

                final v = await FlutterFlushBar.global().showFlushBar<int>(
                  context,
                  childBuilder: (context, dismiss) {
                    return Container(
                      color: color,
                      height: 200,
                      alignment: Alignment.center,
                      child: TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        onPressed: () => dismiss(value: 123),
                        child: const Text('Dismiss'),
                      ),
                    );
                  },
                );

                debugPrint('v: $v');
              },
              child: const Text('Show Flush'),
            ),
          ],
        ),
      ),
    );
  }
}
