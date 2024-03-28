import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';

class RealtyKit extends StatefulWidget {
  const RealtyKit({super.key});

  @override
  State<RealtyKit> createState() => _RealtyKitState();
}

class _RealtyKitState extends State<RealtyKit> {
  late ARKitController arkitController;

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
  }
}
