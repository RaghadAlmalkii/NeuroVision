import 'package:flutter/material.dart';
import 'package:neuro_vision7/database/database_helper.dart';
import 'package:neuro_vision7/pages/testMRIImage.dart';

class PatientPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const PatientPage({Key? key, required this.user}) : super(key: key);

  @override
  _PatientPageState createState() => _PatientPageState();
}

enum gender { male, female }

class _PatientPageState extends State<PatientPage> {
  gender? _gender = gender.male;
  bool showAddPatientForm = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController searchIdController = TextEditingController();
  bool isSaved = false; // Tracks if information is saved
  Map<String, dynamic>? savedPatient;
  Map<String, dynamic>? foundPatient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FA),
      appBar: AppBar(
        title: Text('Patients Page'),
        backgroundColor: const Color(0xFFB3D9FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Enter Patient ID
                const Text(
                  'Search for a Patient:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: searchIdController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter Patient ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Search Button
                ElevatedButton(
                  onPressed: () async {
                    String idInput = searchIdController.text.trim();
                    if (idInput.isEmpty ||
                        !RegExp(r'^\d+$').hasMatch(idInput)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Enter a valid National ID')),
                      );
                      return;
                    }

                    try {
                      int nationalId = int.parse(idInput);
                      final patient = await DatabaseHelper()
                          .getPatientByNationalId(nationalId);

                      if (patient != null) {
                        setState(() {
                          foundPatient = patient;
                        });
                      } else {
                        setState(() {
                          foundPatient = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Patient not found!')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                // Display Patient Information
                if (foundPatient != null) ...[
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Name: ${foundPatient!['fullname']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Age: ${foundPatient!['age']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Gender: ${foundPatient!['gender'] == 0 ? 'Male' : 'Female'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'National ID: ${foundPatient!['national_id']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Test MRI Image Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TestMRIImage(patient: foundPatient!),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(168, 14, 198, 158),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Test MRI Image',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
                const Text(
                  'OR\n',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showAddPatientForm = !showAddPatientForm;
                      isSaved =
                          false; // Reset the saved state when opening the form
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Add New Patient',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                if (showAddPatientForm)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Patient Information',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: fullnameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nationalIdController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'National ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'National ID is required';
                            }
                            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return 'National ID must be exactly 10 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: ageController,
                          decoration: InputDecoration(
                            labelText: 'Age',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Age is required';
                            }
                            final int? age = int.tryParse(value);
                            if (age == null || age <= 0) {
                              return 'Enter a valid positive number for age';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Gender',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        ListTile(
                          title: const Text('Male'),
                          leading: Radio<gender>(
                            value: gender.male,
                            groupValue: _gender,
                            onChanged: (gender? value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: const Text('Female'),
                          leading: Radio<gender>(
                            value: gender.female,
                            groupValue: _gender,
                            onChanged: (gender? value) {
                              setState(() {
                                _gender = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Save Information Button
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String fullname = fullnameController.text.trim();
                              String age = ageController.text.trim();
                              String nationalId =
                                  nationalIdController.text.trim();
                              final Map<String, dynamic> patient = {
                                'fullname': fullname,
                                'gender': _gender == gender.male ? 0 : 1,
                                'age': int.parse(age),
                                'national_id': int.parse(nationalId),
                                'date': null,
                                'testResult': null,
                                'MRI': null,
                              };

                              try {
                                bool isExist = await DatabaseHelper()
                                    .isNationalIdExist(int.parse(nationalId));
                                if (isExist) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Error: National ID already exists!')),
                                  );
                                  return;
                                }
                                await DatabaseHelper().registerPatient(patient);

                                setState(() {
                                  isSaved = true; // Mark information as saved
                                  savedPatient =
                                      patient; // Store saved patient data
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Patient registered successfully!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: ${e.toString()}')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Add Information',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Test MRI Image Button (Visible only if saved successfully)
                        if (isSaved)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TestMRIImage(patient: savedPatient!),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(168, 14, 198, 158),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Test MRI Image',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
