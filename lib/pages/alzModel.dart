import 'package:tflite_flutter/tflite_flutter.dart' as tflite;



 /*----------------------------LoadModel-----------------------------*/ 
class AlzModel{

  tflite.Interpreter? _interpreter;

 Future <void> loadModel ()async {
  try{
    _interpreter = await tflite.Interpreter.fromAsset('assets/AlzEarlyDetection_ModelCNN.tflite');
    print("Model loaded Successfully!");
  }
  catch(e){
    print("Erorr loading Model: $e");
  }

 }

  // Access the loaded interpreter
    tflite.Interpreter? get interpreter => _interpreter;

  // Dispose the interpreter when done
  void dispose() {
    _interpreter?.close();
  }
}