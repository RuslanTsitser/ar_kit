import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class SimpleArKit extends StatefulWidget {
  const SimpleArKit({super.key});

  @override
  State<SimpleArKit> createState() => _SimpleArKitState();
}

class _SimpleArKitState extends State<SimpleArKit> {
  late ARKitController arkitController;

  ARKitReferenceNode? node;

  @override
  void dispose() {
    arkitController.onAddNodeForAnchor = null;
    arkitController.onUpdateNodeForAnchor = null;
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ARKit in Flutter')),
        body: Stack(
          children: [
            ARKitSceneView(
              onARKitViewCreated: onARKitViewCreated,
              showFeaturePoints: true,
              planeDetection: ARPlaneDetection.horizontal,
              enableTapRecognizer: true,
              environmentTexturing: ARWorldTrackingConfigurationEnvironmentTexturing.automatic,
              configuration: ARKitConfiguration.worldTracking,
            ),
          ],
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onARTap = _onTap;
  }

  void _onTap(List<ARKitTestResult> ar) {
    final point = ar.firstWhereOrNull(
      (o) => o.type == ARKitHitTestResultType.featurePoint,
    );
    if (point != null) {
      _onARTapHandler(point);
    }
  }

  void _onARTapHandler(ARKitTestResult point) {
    final position = vector.Vector3(
      point.worldTransform.getColumn(3).x,
      point.worldTransform.getColumn(3).y,
      point.worldTransform.getColumn(3).z,
    );

    final node = _getNodeFromFlutterAsset(position);
    // final node = _getNodeFromNetwork(position);
    arkitController.add(node);
  }

  ARKitGltfNode _getNodeFromFlutterAsset(vector.Vector3 position) => ARKitGltfNode(
        assetType: AssetType.flutterAsset,
        url: 'assets/objects/poubelle.glb',
        scale: vector.Vector3(0.05, 0.05, 0.05),
        position: position,
      );
}
