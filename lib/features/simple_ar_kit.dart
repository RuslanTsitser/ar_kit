import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class SimpleArKit extends StatefulWidget {
  const SimpleArKit({super.key});

  @override
  State<SimpleArKit> createState() => _SimpleArKitState();
}

class _SimpleArKitState extends State<SimpleArKit> {
  late ARKitController arkitController;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  List<String> urls = [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/The_Blue_Marble_%28remastered%29.jpg/1920px-The_Blue_Marble_%28remastered%29.jpg'
  ];

  Future<ARKitMaterial> getImageMaterial() async {
    final path = (await getTemporaryDirectory()).path;
    final name = DateTime.now().microsecondsSinceEpoch;
    final imageFile = File('$path/$name.png');
    final image = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    final imageBytes = await image.toImage(pixelRatio: 3);
    final byteData = await imageBytes.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    await imageFile.writeAsBytes(buffer);
    final material = ARKitMaterial(
      lightingModelName: ARKitLightingModel.lambert,
      diffuse: ARKitMaterialProperty.image(
        imageFile.path,
      ),
    );
    return material;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Image Detection Sample')),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final material = await getImageMaterial();
            if (nodes.isNotEmpty) {
              final node = nodes.values.first;

              node.geometry?.materials.value = [material];
            }
          },
        ),
        body: GestureDetector(
          key: _key,
          onTapDown: _onTapDown,
          child: Stack(
            children: [
              Center(
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: SizedBox(
                    width: MediaQuery.sizeOf(context).shortestSide,
                    height: MediaQuery.sizeOf(context).shortestSide,
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          right: 0,
                          width: MediaQuery.sizeOf(context).shortestSide / 3,
                          height: MediaQuery.sizeOf(context).shortestSide / 3,
                          child: Opacity(
                            opacity: 0.8,
                            child: Image.network(
                              'https://parsefiles.back4app.com/gy5DcBsmJFEhxkEKeKlArNJaLJ39WGVyZXHSKXPD/d5d8d0ebc50e85e7eb642d0a6094ca8a_50.png',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ARKitSceneView(
                key: ValueKey(urls),
                trackingImages: [
                  ...urls.map((e) => ARKitReferenceImage(
                        name: e,
                        physicalWidth: 0.02,
                      )),
                ],
                onARKitViewCreated: onARKitViewCreated,
                configuration: ARKitConfiguration.imageTracking,
                planeDetection: ARPlaneDetection.horizontalAndVertical,
                environmentTexturing: ARWorldTrackingConfigurationEnvironmentTexturing.automatic,
                maximumNumberOfTrackedImages: 1,
                showFeaturePoints: true,
              ),
            ],
          ),
        ),
      );

  final GlobalKey _repaintKey = GlobalKey();

  File? imageFile;
  final GlobalKey _key = GlobalKey();

  Future<void> _onTapDown(TapDownDetails details) async {
    for (final node in nodes.values) {
      arkitController.remove(node.name);
    }

    final imageProvider = await arkitController.snapshot();
    final widgetSize = _key.currentContext?.size;
    if (widgetSize != null) {
      final ui.Image image = await _loadImage(imageProvider);
      final croppedImage = await createImage(
        image,
        Rect.fromCenter(
          center: details.localPosition,
          width: 100,
          height: 100,
        ),
        widgetSize,
      );
      final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();
        final path = (await getTemporaryDirectory()).path;
        final now = DateTime.now().microsecondsSinceEpoch;
        final file = File('$path/$now.png');
        await file.writeAsBytes(buffer);
        urls = [];
        imageFile = file;
        setState(() {
          urls = [
            file.path,
          ];
          showDialog(context: context, builder: (context) => AlertDialog(content: Image.file(file)));
        });
      }
    }
  }

  Future<ui.Image> createImage(ui.Image image, Rect rect, Size widgetSize) async {
    final img.Image newImage = await convertFlutterUiToImage(image);
    final ratio = image.width / widgetSize.width;
    final croppedImage = img.copyCrop(
      newImage,
      x: (rect.left * ratio).toInt(),
      y: (rect.top * ratio).toInt(),
      width: (rect.width * ratio).toInt(),
      height: (rect.height * ratio).toInt(),
    );
    final uiImage = await convertImageToFlutterUi(croppedImage);
    return uiImage;
  }

  Future<ui.Image> _loadImage(ImageProvider imageProvider) async {
    final Completer<ui.Image> completer = Completer();
    final ImageStreamListener listener = ImageStreamListener((info, _) {
      final ui.Image image = info.image;
      completer.complete(image);
    });
    final ImageStream stream = imageProvider.resolve(const ImageConfiguration());
    stream.addListener(listener);
    return completer.future;
  }

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onAddNodeForAnchor = onAnchorWasFound;
    this.arkitController.onUpdateNodeForAnchor = onUpdateNodeForAnchor;
    // this.arkitController.onDidRemoveNodeForAnchor = (anchor) {
    //   setState(() => anchorWasFound = false);
    // };
  }

  Map<String, ARKitNode> nodes = {};

  void onUpdateNodeForAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitImageAnchor) {
      if (anchor.isTracked && anchor.referenceImageName != null && nodes.keys.contains(anchor.referenceImageName!)) {
        final node = nodes[anchor.referenceImageName!];

        final earthMatrix = anchor.transform;

        Matrix4 transform = Matrix4.identity();

        // translate the node with earth position
        final earthTranslation = earthMatrix.getTranslation();
        transform.setTranslation(earthTranslation);

        // rotate the node with earth rotation
        final earthRotation = earthMatrix.getRotation();
        transform.setRotation(earthRotation);

        // rotate the node
        const rotationAngleX = 0.5 * math.pi;
        final coSinus = math.cos(rotationAngleX);
        final sinus = math.sin(rotationAngleX);
        final rotationMatrix = Matrix4(
          1, 0, 0, 0, //
          0, coSinus, -sinus, 0, //
          0, sinus, coSinus, 0, //
          0, 0, 0, 1, //
        );
        transform = transform * rotationMatrix;

        node?.transform = transform;
      }
    }
  }

  Future<void> onAnchorWasFound(ARKitAnchor anchor) async {
    if (anchor is ARKitImageAnchor) {
      final material = await getImageMaterial();

      final geometry = ARKitPlane(materials: [material], width: 0.1, height: 0.1);

      final earthMatrix = anchor.transform;

      Matrix4 transformation = Matrix4.identity();

      // translate the node with earth position
      final earthTranslation = earthMatrix.getTranslation();
      transformation.setTranslation(earthTranslation);

      // rotate the node with earth rotation
      final earthRotation = earthMatrix.getRotation();
      transformation.setRotation(earthRotation);

      // rotate the node with 90 degrees
      const rotationAngleX = 0.5 * math.pi;
      final coSinus = math.cos(rotationAngleX);
      final sinus = math.sin(rotationAngleX);
      final rotationMatrix = Matrix4(
        1, 0, 0, 0, //
        0, coSinus, -sinus, 0, //
        0, sinus, coSinus, 0, //
        0, 0, 0, 1, //
      );

      transformation = transformation * rotationMatrix;
      final name = anchor.referenceImageName ?? 'earth';
      final node = ARKitNode(
        name: name,
        geometry: geometry,
        transformation: transformation,
      );
      if (anchor.referenceImageName != null) {
        arkitController.add(node);

        nodes[name] = node;
      }
    }
  }
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

Future<img.Image> convertFlutterUiToImage(ui.Image uiImage) async {
  final uiBytes = await uiImage.toByteData();

  final image =
      img.Image.fromBytes(width: uiImage.width, height: uiImage.height, bytes: uiBytes!.buffer, numChannels: 4);

  return image;
}
