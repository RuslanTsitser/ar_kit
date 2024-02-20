import 'dart:async';

import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class SimpleArKit extends StatefulWidget {
  const SimpleArKit({super.key});

  @override
  State<SimpleArKit> createState() => _SimpleArKitState();
}

class _SimpleArKitState extends State<SimpleArKit> {
  late ARKitController arkitController;
  Timer? timer;
  bool anchorWasFound = false;

  @override
  void dispose() {
    timer?.cancel();
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Image Detection Sample')),
        body: Stack(
          fit: StackFit.expand,
          children: [
            ARKitSceneView(
              trackingImages: const [
                ARKitReferenceImage(
                  name:
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/The_Blue_Marble_%28remastered%29.jpg/1920px-The_Blue_Marble_%28remastered%29.jpg',
                  physicalWidth: 0.5,
                ),
                ARKitReferenceImage(
                  name: 'https://psv4.userapi.com/c236331/u223802256/docs/d34/2763e51c723e/identifier.png',
                  physicalWidth: 0.5,
                ),
              ],
              // detectionImages: const [
              //   ARKitReferenceImage(
              //     name:
              //         'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/The_Blue_Marble_%28remastered%29.jpg/1920px-The_Blue_Marble_%28remastered%29.jpg',
              //     physicalWidth: 0.1,
              //   ),
              // ],
              onARKitViewCreated: onARKitViewCreated,
              configuration: ARKitConfiguration.imageTracking,
              planeDetection: ARPlaneDetection.horizontalAndVertical,
              environmentTexturing: ARWorldTrackingConfigurationEnvironmentTexturing.automatic,
              maximumNumberOfTrackedImages: 1,
              showFeaturePoints: true,
            ),
            anchorWasFound
                ? Container()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Point the camera at the earth image from the article about Earth on Wikipedia.',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                  ),
          ],
        ),
      );

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
        final earthPosition = anchor.transform.getColumn(3);
        node?.position = vector.Vector3(earthPosition.x, earthPosition.y, earthPosition.z);
      }
    }
  }

  void onAnchorWasFound(ARKitAnchor anchor) {
    if (anchor is ARKitImageAnchor) {
      setState(() => anchorWasFound = true);

      final material = ARKitMaterial(
        lightingModelName: ARKitLightingModel.lambert,
        diffuse: ARKitMaterialProperty.image(
            'https://kartinki.pics/uploads/posts/2021-07/1626766949_10-kartinkin-com-p-tekstura-planeti-zemlya-besshovnaya-krasiv-30.jpg'),
      );
      final sphere = ARKitSphere(
        materials: [material],
        radius: 0.1,
      );

      final earthPosition = anchor.transform.getColumn(3);
      final node = ARKitNode(
        geometry: sphere,
        position: vector.Vector3(earthPosition.x, earthPosition.y, earthPosition.z),
        eulerAngles: vector.Vector3.zero(),
      );
      if (anchor.referenceImageName != null) {
        arkitController.add(node);

        timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          final old = node.eulerAngles;
          final eulerAngles = vector.Vector3(old.x + 0.01, old.y, old.z);
          node.eulerAngles = eulerAngles;
        });

        nodes[anchor.referenceImageName!] = node;
      }
    }
  }
}
