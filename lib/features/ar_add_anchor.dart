import 'dart:async';

import 'package:ar_kit/core/logging/app_logger.dart';
import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ArAddAnchor extends StatefulWidget {
  const ArAddAnchor({super.key});

  @override
  State<ArAddAnchor> createState() => _ArAddAnchorState();
}

class _ArAddAnchorState extends State<ArAddAnchor> {
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
    this.arkitController.onARTap = _onTap;
    this.arkitController.onUpdateNodeForAnchor = onUpdateNodeForAnchor;
  }

  void _onTap(List<ARKitTestResult> ar) {
    logInfo(ar.map((e) => e.toJson()).toList());
    final point = ar.firstWhereOrNull((o) {
      logInfo(o.toJson());
      return o.anchor != null;
    });
    if (point != null) {
      _addAnchorNode(point);
    }
  }

  Map<String, ARKitNode> nodes = {};

  void onUpdateNodeForAnchor(ARKitAnchor anchor) {
    logInfo({
      'nodes': nodes.keys,
      'onUpdateNodeForAnchor': anchor.toJson(),
    });
    if (nodes.keys.contains(anchor.identifier)) {
      final node = nodes[anchor.identifier];
      final earthPosition = anchor.transform.getColumn(3);
      node?.position = vector.Vector3(earthPosition.x, earthPosition.y, earthPosition.z);
    }
  }

  Future<void> _addAnchorNode(ARKitTestResult point) async {
    final anchor = point.anchor!;
    logInfo('add anchor node: ${anchor.identifier}');

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

    arkitController.add(node);

    nodes[anchor.identifier] = node;
  }
}
