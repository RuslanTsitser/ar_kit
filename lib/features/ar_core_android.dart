import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ar_kit/core/logging/app_logger.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class ArDrawingAndroidScreen extends StatefulWidget {
  const ArDrawingAndroidScreen({super.key});

  @override
  State<ArDrawingAndroidScreen> createState() => _ArDrawingAndroidScreenState();
}

class _ArDrawingAndroidScreenState extends State<ArDrawingAndroidScreen> {
  late ArCoreController arController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello World'),
      ),
      body: GestureDetector(
        key: _key,
        onTapDown: (details) => _onTapDown(
          details,
          (bytes) {
            return showDialog(context: context, builder: (context) => AlertDialog(content: Image.memory(bytes)));
          },
        ),
        child: ArCoreView(
          enableUpdateListener: true,
          enableTapRecognizer: false,
          type: ArCoreViewType.STANDARDVIEW,
          onArCoreViewCreated: _onArCoreViewCreated,
          debug: true,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arController = controller;
    arController.onTrackingImage = _onTrackingImage;
  }

  static const _nodeName = 'test_node';
  ArCoreNode? _node;

  Future<void> _onTrackingImage(ArCoreAugmentedImage image) async {
    logInfo({
      'name': image.name,
      'index': image.index,
      'centerPose': {
        'translation': image.centerPose.translation,
        'rotation': image.centerPose.rotation,
      },
      'extentX': image.extentX,
      'extentZ': image.extentZ,
      'trackingMethod': image.trackingMethod,
    });

    if (_node != null) {
      return;
    }
    return createNode(image.centerPose).then((value) {
      _node = value;
      return arController.addArCoreNodeToAugmentedImage(_node!, image.index);
    });
  }

  Future<ArCoreNode> createNode(ArCorePose pose) async {
    final response = await http.get(Uri.parse(
        'https://parsefiles.back4app.com/gy5DcBsmJFEhxkEKeKlArNJaLJ39WGVyZXHSKXPD/d5d8d0ebc50e85e7eb642d0a6094ca8a_50.png'));
    final image = ArCoreImage(
      bytes: response.bodyBytes,
      width: 100,
      height: 100,
    );
    return ArCoreNode(
      name: _nodeName,
      image: image,
    );
  }

  File? imageFile;
  final GlobalKey _key = GlobalKey();

  Future<void> _onTapDown(TapDownDetails details, Future<void> Function(Uint8List) onComplete) async {
    await arController.removeNode(nodeName: _nodeName);
    _node = null;
    final imageBytes = await arController.takePicture();
    final widgetSize = _key.currentContext?.size;
    if (widgetSize != null) {
      final ui.Image image = await _loadImage(imageBytes);
      final croppedImage = await _createImage(
        image,
        Rect.fromCenter(
          center: details.localPosition,
          width: 300,
          height: 300,
        ),
        widgetSize,
      );
      final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();
        await arController.loadSingleAugmentedImage(bytes: bytes);
        onComplete.call(bytes);
      }
    }
  }

  Future<ui.Image> _createImage(ui.Image image, Rect rect, Size widgetSize) async {
    final img.Image newImage = await convertFlutterUiToImage(image);
    final rotatedImage = img.copyRotate(newImage, angle: 90);
    final ratio = rotatedImage.width / widgetSize.width;
    final croppedImage = img.copyCrop(
      rotatedImage,
      x: (rect.left * ratio).toInt(),
      y: (rect.top * ratio).toInt(),
      width: (rect.width * ratio).toInt(),
      height: (rect.height * ratio).toInt(),
    );
    final uiImage = await convertImageToFlutterUi(croppedImage);
    return uiImage;
  }

  Future<ui.Image> _loadImage(Uint8List imageProvider) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageProvider, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<img.Image> convertFlutterUiToImage(ui.Image uiImage) async {
    final uiBytes = await uiImage.toByteData();

    final image =
        img.Image.fromBytes(width: uiImage.width, height: uiImage.height, bytes: uiBytes!.buffer, numChannels: 4);

    return image;
  }

  Future<ui.Image> convertImageToFlutterUi(img.Image image) async {
    if (image.format != img.Format.uint8 || image.numChannels != 4) {
      final cmd = img.Command()
        ..image(image)
        ..convert(format: img.Format.uint8, numChannels: 4);
      final rgba8 = await cmd.getImageThread();
      if (rgba8 != null) {
        image = rgba8;
      }
    }

    ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(image.toUint8List());

    ui.ImageDescriptor id =
        ui.ImageDescriptor.raw(buffer, height: image.height, width: image.width, pixelFormat: ui.PixelFormat.rgba8888);

    ui.Codec codec = await id.instantiateCodec(targetHeight: image.height, targetWidth: image.width);

    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image uiImage = fi.image;

    return uiImage;
  }

  @override
  void dispose() {
    arController.dispose();
    super.dispose();
  }
}
