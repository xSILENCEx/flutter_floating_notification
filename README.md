<style>
pre {
  overflow-y: auto;
  max-height: 400px;
}
</style>

# Flutter Flush Bar

A Flutter package of custom flush bar. 

<br>

### 1. A FlutterFlushBar() maintains a queue

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_flush_bar/new.gif"  height=430 style="float: left">

```Dart
final random = Random();

final color = Color.fromARGB(
    255,
    random.nextInt(255),
    random.nextInt(255),
    random.nextInt(255),
);

final double randomHeight = 100 + random.nextInt(100).toDouble();

final v = await FlutterFlushBar().showFlushBar<int>(
    context,
    childBuilder: (context, dismiss) {
    return Container(
        color: color,
        height: randomHeight,
        alignment: Alignment.center,
        child: ElevatedButton(
        onPressed: () => dismiss(value: color.value),
        child: const Text('Dismiss'),
        ),
    );
    },
);

debugPrint('v: $v');
```

<br>

### 1. The FlutterFlushBar.global() contains a global queue

<img src="https://raw.githubusercontent.com/xSILENCEx/project_images/main/flutter_flush_bar/global.gif"  height=430 style="float: left">

```Dart
final random = Random();

final color = Color.fromARGB(
    255,
    random.nextInt(255),
    random.nextInt(255),
    random.nextInt(255),
);

final double randomHeight = 100 + random.nextInt(100).toDouble();

final v = await FlutterFlushBar.global().showFlushBar<int>(
    context,
    childBuilder: (context, dismiss) {
    return Container(
        color: color,
        height: randomHeight,
        alignment: Alignment.center,
        child: ElevatedButton(
        onPressed: () => dismiss(value: color.value),
        child: const Text('Dismiss Global'),
        ),
    );
    },
);

debugPrint('v: $v');
```