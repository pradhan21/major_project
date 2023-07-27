import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'api_services.dart';
import 'models.dart';
import 'utils.dart';

class CameraScreen extends StatefulWidget {
  final CameraController controller;

  const CameraScreen({Key? key, required this.controller}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = widget.controller;
    try {
      await _controller.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: ${e.toString()}');
    }
  }

  void _captureImage() async {
    try {
      if (!_controller.value.isInitialized) {
        return;
      }

      final image = await _controller.takePicture(); // Capture the image

      // Process the captured image with the OCR API
      final ocrResult = await OCRAPIService.processImage(image.path);

      // Extract the relevant bill details from the OCR result
      final billDetails = OCRUtils.extractBillDetails(ocrResult);

      // Do something with the extracted bill details
      print('Bill Details: ${billDetails.totalAmount}, ${billDetails.items}');
    } catch (e) {
      print('Error capturing image: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Column(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: CameraPreview(_controller),
          ),
        ),
        ElevatedButton(
          onPressed: _captureImage,
          child: Text('Capture'),
        ),
      ],
    );
  }
}
