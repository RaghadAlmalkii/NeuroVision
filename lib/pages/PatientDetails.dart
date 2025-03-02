import 'package:flutter/material.dart';

class PatientDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> tests;

  const PatientDetailsPage(
      {Key? key, required this.tests, required int nationalId})
      : super(key: key);

  String getGender(int gender) {
    return gender == 0 ? "Male" : "Female";
  }

  String formatDate(String date) {
    if (date.isEmpty) return "Unknown";
    final DateTime parsedDate = DateTime.parse(date);
    return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Assume all tests in the list belong to the same patient (same national_id).
    final patientName = tests.first['fullname'];
    final nationalId = tests.first['national_id'];

    return Scaffold(
      appBar: AppBar(
        title: Text('$patientName (ID: $nationalId)'),
        backgroundColor: const Color(0xFFB3D9FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: tests.length,
          itemBuilder: (context, index) {
            // Skip index 0
            if (index == 0) {
              return const SizedBox(); // Return an empty widget for index 0
            }

            final test = tests[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // MRI Image
                    Center(
                      child: test['MRI'] != null
                          ? Image.memory(
                              test['MRI'],
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.image_not_supported,
                              size: 200,
                              color: Colors.grey,
                            ),
                    ),
                    const SizedBox(height: 20),
                    // Test Details
                    Text(
                      "Test ${index}:",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Age: ${test['age'] ?? 'Unknown'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Gender: ${getGender(test['gender'])}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Test Date: ${formatDate(test['date'])}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "${test['testResult'] ?? 'Unknown'}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
