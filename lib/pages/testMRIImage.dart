import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:neuro_vision7/pages/alzModel.dart';
import 'package:neuro_vision7/database/database_helper.dart';

class TestMRIImage extends StatefulWidget {
  final Map<String, dynamic> patient;

  const TestMRIImage({Key? key, required this.patient}) : super(key: key);

  @override
  _TestMRIImage createState() => _TestMRIImage();
}

class _TestMRIImage extends State<TestMRIImage> {
  File? _selectedImage;
  String? _predictionResult;
  final AlzModel _model = AlzModel();
  List<String>? _labels;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Define controllers for form fields
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      await _model.loadModel();
      _labels = await loadLabels();
      if (_labels == null || _labels!.isEmpty) {
        print("Labels are not loaded or empty.");
      }
    } catch (e) {
      print("Error loading model or labels: $e");
    }
  }

  Future<void> uploadImage() async {
    // Pick an image from the gallery
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Validate file type
      final fileExtension = pickedFile.path.split('.').last.toLowerCase();
      if (fileExtension != 'jpg' &&
          fileExtension != 'jpeg' &&
          fileExtension != 'png') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a JPG or PNG image")),
        );
        return; // Exit the function if the file type is invalid
      }

      setState(() {
        _selectedImage = File(pickedFile.path);
        _predictionResult = null;
      });

      // Run the model on the selected image
      if (_selectedImage != null && _model.interpreter != null) {
        await runModel(_selectedImage!, _model);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected")),
      );
    }
  }

  /*----------------------------Imagepreprocessing-----------------------------*/

  Future<List<List<List<double>>>> preprocessImage(
      File imagefile, int inputsize) async {
    final imageBytes = imagefile.readAsBytesSync();
    final img.Image? decodeImage = img.decodeImage(imageBytes);
    if (decodeImage == null) throw Exception("Unaple to decode image");
    final reSizedImage = img.copyResize(decodeImage, width: 200, height: 200);

    // Normalize pixel values to [0, 1]
    List<List<List<double>>> input = [];
    for (int y = 0; y < inputsize; y++) {
      List<List<double>> row = [];
      for (int x = 0; x < inputsize; x++) {
        final pixel = reSizedImage.getPixel(x, y); // Returns a Pixel object
        final r = pixel.r.toDouble() / 255.0; // Get red component and normalize
        final g =
            pixel.g.toDouble() / 255.0; // Get green component and normalize
        final b =
            pixel.b.toDouble() / 255.0; // Get blue component and normalize
        row.add([r, g, b]);
      }
      input.add(row);
    }

    return input;
  }

  /*----------------------------RunModel-----------------------------*/
  Future<void> runModel(File imageFile, AlzModel model) async {
    if (_labels == null || model.interpreter == null) {
      print("Labels or interpreter is not available. Please load them first.");
      return;
    }

    try {
      const inputSize = 200; // Adjust based on your model's input size
      final input = await preprocessImage(imageFile, inputSize);
      final output = List.generate(1, (i) => List.filled(_labels!.length, 0.0));

      // Run the model
      model.interpreter!.run([input], output);

      // Find the class with the highest confidence
      final classIndex =
          output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));

      setState(() {
        _predictionResult = "Test Result: ${_labels![classIndex]}";
      });
    } catch (e) {
      print("Error running the model: $e");
    }
  }

  Future<List<String>> loadLabels() async {
    final labelData = await rootBundle.loadString('assets/labels.txt');
    return labelData.split('\n').map((label) => label.trim()).toList();
  }

  // Other existing methods remain unchanged...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FA),
      appBar: AppBar(
        title: const Text('Alzheimer Early Detection'),
        backgroundColor: const Color(0xFFB3D9FF),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Section: Image Upload
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Square with brain icon
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/brain-icon.png',
                                width: 150,
                                height: 150,
                                color: Colors.black38,
                              ),
                            ),
                            if (_selectedImage != null)
                              Image.file(
                                _selectedImage!,
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Upload Button
                      ElevatedButton(
                        onPressed: () => uploadImage(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "Upload Image",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Prediction Result
                      if (_selectedImage != null)
                        Text(
                          _predictionResult ?? "Processing...",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      else
                        const Text(
                          "Select Image",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Right Section: Form
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Align text to the left
                        children: [
                          Text(
                            'Patient Information',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Full Name: ${widget.patient['fullname']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Age: ${widget.patient['age']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Gender: ${widget.patient['gender'] == 0 ? 'Male' : 'Female'}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'National ID: ${widget.patient['national_id']}',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          // Save Information Button at the center bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  String fullname = fullnameController.text.trim();
                  String age = ageController.text.trim();
                  String nationalId = nationalIdController.text.trim();

                  final Map<String, dynamic> patient = {
                    'fullname': widget.patient['fullname'],
                    'gender': widget.patient['gender'],
                    'age': widget.patient['age'],
                    'national_id': widget.patient['national_id'],
                    'date': DateTime.now().toIso8601String(),
                    'testResult': _predictionResult ?? 'Unknown',
                    'MRI': _selectedImage != null
                        ? await _selectedImage!.readAsBytes()
                        : null,
                  };

                  try {
                    await DatabaseHelper().registerPatient(patient);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Patient registered successfully!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Save Result',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      



/*

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FA), // Light background
      appBar: AppBar(
        title: const Text('Alzheimer Early Detection'),
        backgroundColor: const Color(0xFFB3D9FF), // Light blue color
        elevation: 0,
      ),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Section: Image Upload
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Square with brain icon
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/brain-icon.png',
                                width: 150,
                                height: 150,
                                color: Colors.black38,
                              ),
                            ),
                            if (_selectedImage != null)
                              Image.file(
                                _selectedImage!,
                                width: 300,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Upload Button
                      ElevatedButton(
                        onPressed: () => uploadImage(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "Upload Image",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Prediction Result
                      if (_selectedImage != null)
                        Text(
                          _predictionResult ?? "Processing...",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      else
                        const Text(
                          "Select Image",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Right Section: Form
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Patient Information',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Save Information Button at the center bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String fullname = fullnameController.text.trim();
                    String age = ageController.text.trim();
                    String nationalId = nationalIdController.text.trim();

                    final Map<String, dynamic> patient = {
                      'fullname': fullname,
                      'gender': _gender == gender.male ? 0 : 1,
                      'age': int.parse(age),
                      'national_id': int.parse(nationalId),
                      'date': DateTime.now().toIso8601String(),
                      'testResult': _predictionResult ?? 'Unknown',
                      'MRI': _selectedImage != null
                          ? await _selectedImage!.readAsBytes()
                          : null,
                    };

                    try {
                      await DatabaseHelper().registerPatient(patient);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Patient registered successfully!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Save Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/