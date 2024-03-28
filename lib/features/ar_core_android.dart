import 'package:ar_kit/core/logging/app_logger.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:vector_math/vector_math_64.dart' as vector;

class ArDrawingAndroidScreen extends StatefulWidget {
  const ArDrawingAndroidScreen({super.key});

  @override
  State<ArDrawingAndroidScreen> createState() => _ArDrawingAndroidScreenState();
}

class _ArDrawingAndroidScreenState extends State<ArDrawingAndroidScreen> {
  late ArCoreController arCoreController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello World'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onFabTap();
        },
        child: const Icon(Icons.delete),
      ),
      body: ArCoreView(
        enableUpdateListener: true,
        enableTapRecognizer: true,
        type: ArCoreViewType.STANDARDVIEW,
        onArCoreViewCreated: _onArCoreViewCreated,
        debug: true,
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = _onPlaneTap;
    arCoreController.onTrackingImage = _onTrackingImage;
  }

  Future<void> _onFabTap() async {
    final response = await http.get(Uri.parse(
        'https://parsefiles.back4app.com/gy5DcBsmJFEhxkEKeKlArNJaLJ39WGVyZXHSKXPD/f3362aa65bb9c76551e138cb8722c457_49.png'));
    final bytes = response.bodyBytes;
    logInfo({
      'length': bytes.length,
    });

    // await arCoreController.loadMultipleAugmentedImage(bytesMap: {
    //   'test_image': bytes,
    // });
    // await arCoreController.loadAugmentedImagesDatabase(bytes: bytes);
    await arCoreController.loadSingleAugmentedImage(bytes: bytes);
    logInfo('Image added');
    // final result = await arCoreController.getTrackingState();
    // logInfo(result);
  }

  static const _nodeName = 'test_node';
  ArCoreNode? _node;

  void _onTrackingImage(ArCoreAugmentedImage image) {
    logInfo({
      'name': image.name,
      'index': image.index,
      'centerPose': image.centerPose,
      'extentX': image.extentX,
      'extentZ': image.extentZ,
      'trackingMethod': image.trackingMethod,
    });
    if (_node != null) {
      arCoreController.removeNode(nodeName: _nodeName);
    }
    _node = ArCoreNode(
      name: _nodeName,
      shape: ArCoreCube(
        size: vector.Vector3(0.1, 0.1, 0.1),
        materials: [
          ArCoreMaterial(
            color: Colors.red,
          ),
        ],
      ),
      position: image.centerPose.translation,
      rotation: image.centerPose.rotation,
    );
    arCoreController.addArCoreNode(_node!);
  }

  void _onPlaneTap(List<ArCoreHitTestResult> hits) async {
    final hit = hits.first;
    final response = await http.get(Uri.parse(
        'https://parsefiles.back4app.com/gy5DcBsmJFEhxkEKeKlArNJaLJ39WGVyZXHSKXPD/d5d8d0ebc50e85e7eb642d0a6094ca8a_50.png'));
    final image = ArCoreImage(
      bytes: response.bodyBytes,
      width: 100,
      height: 100,
    );
    final imageNode = ArCoreNode(
      name: _nodeName,
      image: image,
      position: vector.Vector3(
        hit.pose.translation[0],
        hit.pose.translation[1],
        hit.pose.translation[2],
      ),
      rotation: hit.pose.rotation +
          vector.Vector4(
            1,
            0,
            0,
            0,
          ),
    );
    arCoreController.removeNode(nodeName: _nodeName);
    arCoreController.addArCoreNode(imageNode);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}
