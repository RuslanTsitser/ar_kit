import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ArWithAnimation extends StatefulWidget {
  const ArWithAnimation({super.key});

  @override
  State<ArWithAnimation> createState() => _ArWithAnimationState();
}

class _ArWithAnimationState extends State<ArWithAnimation> {
  late ARKitController arkitController;

  ARKitReferenceNode? node;
  bool idle = true;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Custom Animation')),
        floatingActionButton: FloatingActionButton(
          child: Icon(idle ? Icons.play_arrow : Icons.stop),
          onPressed: () async {
            if (idle) {
              await arkitController.playAnimation(
                  key: 'dancing',
                  sceneName: 'art.scnassets/twist_danceFixed',
                  animationIdentifier: 'twist_danceFixed-1');
            } else {
              await arkitController.stopAnimation(key: 'dancing');
            }
            setState(() => idle = !idle);
          },
        ),
        body: ARKitSceneView(
          onARKitViewCreated: onARKitViewCreated,
          showFeaturePoints: true,
          planeDetection: ARPlaneDetection.horizontal,
          enableTapRecognizer: true,
          environmentTexturing: ARWorldTrackingConfigurationEnvironmentTexturing.automatic,
          configuration: ARKitConfiguration.worldTracking,
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    // this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arkitController.onARTap = _onTap;
  }

  // void _handleAddAnchor(ARKitAnchor anchor) {
  //   if (anchor is! ARKitPlaneAnchor) {
  //     return;
  //   }
  //   _addPlane(arkitController, anchor);
  // }

  // void _addPlane(ARKitController? controller, ARKitPlaneAnchor anchor) {
  //   if (node != null) {
  //     controller?.remove(node!.name);
  //   }
  //   node = ARKitReferenceNode(
  //     url: 'art.scnassets/idleFixed.dae',
  //     position: vector.Vector3(0, 0, 0),
  //     scale: vector.Vector3(0.02, 0.02, 0.02),
  //   );
  //   controller?.add(node!, parentNodeName: anchor.nodeName);
  // }

  void _onTap(List<ARKitTestResult> ar) {
    final point = ar.firstWhereOrNull(
      (o) => o.type == ARKitHitTestResultType.featurePoint,
    );
    if (point != null) {
      _addAnimationNode(point);
    }
  }

  Future<void> _addAnimationNode(ARKitTestResult point) async {
    final position = vector.Vector3(
      point.worldTransform.getColumn(3).x,
      point.worldTransform.getColumn(3).y,
      point.worldTransform.getColumn(3).z,
    );

    final node = _getNodeFromFlutterAsset(position);
    // final node = _getNodeFromNetwork(position);
    arkitController.add(node);
  }

  ARKitReferenceNode _getNodeFromFlutterAsset(vector.Vector3 position) => ARKitReferenceNode(
        url: 'art.scnassets/idleFixed.dae',
        scale: vector.Vector3(0.02, 0.02, 0.02),
        position: position,
      );
}
