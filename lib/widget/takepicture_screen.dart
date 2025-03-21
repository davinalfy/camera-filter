import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'displaypicture_screen.dart';

class TakePictureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const TakePictureScreen({super.key, required this.cameras});

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  int _selectedCameraIndex = 0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera(_selectedCameraIndex);
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    final camera = widget.cameras[cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller!.initialize().then((_) async {
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _currentZoom = _minZoom;
      setState(() {});
    }).catchError((e) {
      print("Error initializing camera: $e");
    });
  }

  void _switchCamera() async {
    _selectedCameraIndex = (_selectedCameraIndex == 0) ? 1 : 0;
    await _controller?.dispose();
    await _initializeCamera(_selectedCameraIndex);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    double newZoom = (_minZoom + (details.scale - 1) * (_maxZoom - _minZoom))
        .clamp(_minZoom, _maxZoom);

    if ((newZoom - _currentZoom).abs() > 0.1) {
      _currentZoom = newZoom;
      await _controller!.setZoomLevel(_currentZoom);
    }
  }

  void _onTapToFocus(TapDownDetails details) async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    final Size imageSize = renderBox.size;

    double dx = localPosition.dx / imageSize.width;
    double dy = localPosition.dy / imageSize.height;

    await _controller!.setFocusPoint(Offset(dx, dy));
    await _controller!.setFocusMode(FocusMode.auto);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera App')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onScaleUpdate: _onScaleUpdate,
              onTapDown: _onTapToFocus,
              child: Stack(
                children: [
                  CameraPreview(_controller!),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: _switchCamera,
                      child: const Icon(Icons.switch_camera),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller!.takePicture();
            if (!mounted) return;

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: image.path),
              ),
            );
          } catch (e) {
            print("Error taking picture: $e");
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}