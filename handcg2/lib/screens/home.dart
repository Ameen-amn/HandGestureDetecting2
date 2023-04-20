import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import './detectScreen.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final List<CameraDescription> cameras;

  @override
  Future<void> didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    await setupCameras();
  }

  setupCameras() async {
    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      log("Error $e.code \n Error message :**$e.message");
    }
  }

  loadModel() async {
    String? res;
    res = await Tflite.loadModel(
        model: "assets/m.tflite", labels: "assets/ml.txt");
    log("**mode $res is loaded ");
  }

  onSelect() {
    loadModel();
    final route = MaterialPageRoute(builder: (context) {
      return DetectScreen(
        cameras: cameras,
      );
    });
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => onSelect(),
                child: const Text("Recognize hand signs"))
          ],
        ),
      ),
    );
  }
}
