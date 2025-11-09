import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

class MlKitDetectionResult {
  final List<String> objects;
  final List<String> hazards;
  final String notes;

  MlKitDetectionResult({
    this.objects = const [],
    this.hazards = const [],
    this.notes = "",
  });

  Map<String, dynamic> toJson() => {
        "objects": objects,
        "hazards": hazards,
        "notes": notes,
      };
}

class MlKitService {
  ObjectDetector? _objectDetector;
  bool _isInitialized = false;

  // Common kitchen objects and hazards
  static const List<String> kitchenObjects = [
    'pan',
    'pot',
    'knife',
    'cutting board',
    'bowl',
    'spoon',
    'fork',
    'plate',
    'garlic',
    'onion',
    'vegetable',
    'meat',
    'stove',
    'oven',
  ];

  static const List<String> hazards = [
    'knife',
    'steam',
    'smoke',
    'hot pan',
    'fire',
    'boiling water',
  ];

  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Create object detector options
      final options = ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      );

      _objectDetector = ObjectDetector(options: options);
      _isInitialized = true;
      return true;
    } catch (e) {
      // If ML Kit fails to initialize, we'll use placeholder mode
      _isInitialized = false;
      return false;
    }
  }

  Future<MlKitDetectionResult> detectObjects(String imagePath) async {
    if (!_isInitialized || _objectDetector == null) {
      // Return placeholder result if ML Kit is not available
      return MlKitDetectionResult(
        objects: [],
        hazards: [],
        notes: "ML Kit not initialized - using placeholder detection",
      );
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final List<DetectedObject> objects = await _objectDetector!.processImage(inputImage);

      final detectedLabels = <String>[];
      final detectedHazards = <String>[];

      for (final object in objects) {
        for (final label in object.labels) {
          final labelText = label.text.toLowerCase();
          detectedLabels.add(labelText);

          // Check if it's a hazard
          if (hazards.any((h) => labelText.contains(h.toLowerCase()))) {
            detectedHazards.add(labelText);
          }
        }
      }

      String notes = "";
      if (detectedHazards.isNotEmpty) {
        notes = "Detected potential hazards: ${detectedHazards.join(', ')}";
      } else if (detectedLabels.isNotEmpty) {
        notes = "Detected objects: ${detectedLabels.join(', ')}";
      }

      return MlKitDetectionResult(
        objects: detectedLabels,
        hazards: detectedHazards,
        notes: notes,
      );
    } catch (e) {
      return MlKitDetectionResult(
        objects: [],
        hazards: [],
        notes: "Error processing image: $e",
      );
    }
  }

  // Placeholder method for when ML Kit is not available
  Future<MlKitDetectionResult> detectObjectsPlaceholder(String imagePath) async {
    // This is a placeholder that returns empty results
    // In a real implementation, you might use a simpler image analysis
    // or return mock data for testing
    return MlKitDetectionResult(
      objects: [],
      hazards: [],
      notes: "Placeholder detection - ML Kit not available",
    );
  }

  Future<void> dispose() async {
    await _objectDetector?.close();
    _objectDetector = null;
    _isInitialized = false;
  }
}


