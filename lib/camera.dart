import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';

class FaceCaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const FaceCaptureScreen({required this.cameras, Key? key}) : super(key: key);

  @override
  State<FaceCaptureScreen> createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  late CameraController _cameraController;
  late FaceDetector _faceDetector;
  bool _isFaceDetected = false;
  List<File> _capturedImages = [];
  int _currentPoseIndex = 0;
  final List<String> _poses = ["FRONT", "LEFT", "RIGHT"];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
    );
  }

  Future<void> _initializeCamera() async {
    if (widget.cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No cameras available')));
      Navigator.pop(context);
      return;
    }

    _cameraController = CameraController(
      widget.cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front),
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    _startImageStream();
    setState(() {});
  }

  void _startImageStream() {
    _cameraController.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        final WriteBuffer allBytes = WriteBuffer();
        for (Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        final bytes = allBytes.done().buffer.asUint8List();
        final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

        final camera = widget.cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.front);
        final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) ?? InputImageRotation.rotation0deg;

        final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          inputImageData: InputImageData(
            size: imageSize,
            imageRotation: imageRotation,
            inputImageFormat: inputImageFormat,
            planeData: image.planes.map(
              (Plane plane) {
                return InputImagePlaneMetadata(
                  bytesPerRow: plane.bytesPerRow,
                  height: plane.height,
                  width: plane.width,
                );
              },
            ).toList(),
          ),
        );

        final faces = await _faceDetector.processImage(inputImage);
        setState(() {
          _isFaceDetected = faces.isNotEmpty;
        });
      } catch (e) {
        print("Error processing image: $e");
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<void> _captureImage() async {
    if (!_isFaceDetected) return;

    try {
      final file = await _cameraController.takePicture();
      _capturedImages.add(File(file.path));

      if (_currentPoseIndex < _poses.length - 1) {
        setState(() {
          _currentPoseIndex++;
        });
      } else {
        _showCompleteDialog();
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Capture Complete'),
        content: const Text('All poses have been captured. You can now proceed to analysis.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Example: Navigate to result screen, pass _capturedImages
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: ClipOval(
              child: SizedBox(
                width: 300,
                height: 300,
                child: CameraPreview(_cameraController),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Show ${_poses[_currentPoseIndex]}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _isFaceDetected ? '' : 'No face detected',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _isFaceDetected ? _captureImage : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: const Text('Capture'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
