import 'dart:developer';
import 'dart:math'as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

typedef Callback = void Function(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  const Camera(this.cameras, this.setRecognitions, {super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.cameras.isEmpty) {
      log("No Camera is found");
    } else {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;
            int startTime = DateTime.now().microsecondsSinceEpoch;
            Tflite.runModelOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              imageHeight: img.height,
              imageWidth: img.width,
              numResults: 2,
            ).then((recognitions) {
              int endTime = DateTime.now().microsecondsSinceEpoch;
              log("** Detection too ${endTime - startTime}");
              widget.setRecognitions(
                recognitions!,
                img.height,
                img.width,
              );

              isDetecting = false;
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
  }

