import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _initializeCamera();
    } else {
      setState(() {
        _errorMessage = 'Camera permission is required to scan products';
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras found on this device';
        });
        return;
      }

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing camera: ${e.toString()}';
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile image = await _controller!.takePicture();
      
      // Process image with ML Kit for barcode detection
      final inputImage = InputImage.fromFilePath(image.path);
      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);
      
      if (barcodes.isNotEmpty) {
        // Barcode found - navigate to results with barcode
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/results',
            arguments: {
              'barcode': barcodes.first.displayValue,
              'imagePath': image.path,
            },
          );
        }
      } else {
        // No barcode - send image for visual recognition
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/results',
            arguments: {
              'imagePath': image.path,
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking picture: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    
    final currentFlashMode = _controller!.value.flashMode;
    final newFlashMode = currentFlashMode == FlashMode.off 
        ? FlashMode.torch 
        : FlashMode.off;
    
    await _controller!.setFlashMode(newFlashMode);
    setState(() {});
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    
    final currentCamera = _controller!.description;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera != currentCamera,
    );
    
    await _controller!.dispose();
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    
    await _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Product'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_isInitialized && _cameras != null && _cameras!.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: _switchCamera,
              tooltip: 'Switch Camera',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _isInitialized && !_isProcessing
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Flash toggle
                FloatingActionButton(
                  heroTag: 'flash',
                  mini: true,
                  onPressed: _toggleFlash,
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: Icon(
                    _controller?.value.flashMode == FlashMode.torch
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                // Capture button
                FloatingActionButton.large(
                  heroTag: 'capture',
                  onPressed: _takePicture,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
              ],
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                  _requestCameraPermission();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        CameraPreview(_controller!),
        
        // Scanning overlay
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Scanning product...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Scanning guide frame
        if (!_isProcessing)
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Point camera at product or barcode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        
        // Instructions at top
        if (!_isProcessing)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Align the product within the frame and tap the camera button',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
