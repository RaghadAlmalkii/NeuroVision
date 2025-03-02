import 'package:flutter/material.dart';
import 'package:neuro_vision7/database/database_helper.dart';
import 'dart:typed_data';

import 'PatientDetails.dart';

class PreviousTestsPage extends StatefulWidget {
  const PreviousTestsPage({Key? key}) : super(key: key);

  @override
  State<PreviousTestsPage> createState() => _PreviousTestsPageState();
}

class _PreviousTestsPageState extends State<PreviousTestsPage> {
  final DatabaseHelper dbHelper = DatabaseHelper();

  late Map<int, List<Map<String, dynamic>>> groupedData =
      {}; // Grouped by national_id
  late List<int> nationalIds = []; // List of national IDs for display
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
    searchController.addListener(_filterPatients);
  }

  Future<void> _loadPatients() async {
    final allPatients = await dbHelper.getAllPatients();

    // Group patients by national_id
    groupedData = {};
    for (var patient in allPatients) {
      final nationalId = patient['national_id'];
      if (!groupedData.containsKey(nationalId)) {
        groupedData[nationalId] = [];
      }
      groupedData[nationalId]?.add(patient);
    }

    nationalIds = groupedData.keys.toList(); // Get all unique national IDs
    setState(() {});
  }

  void _filterPatients() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        nationalIds = groupedData.keys.toList();
      } else {
        nationalIds = groupedData.keys.where((id) {
          final tests = groupedData[id]!;
          final fullName = tests.first['fullname']?.toLowerCase() ?? '';
          return fullName.contains(query) || id.toString().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FA),
      appBar: AppBar(
        title: const Text('Patients Records'),
        backgroundColor: const Color(0xFFB3D9FF),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by name or ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // List of Patients Grouped by National ID
          Expanded(
            child: nationalIds.isEmpty
                ? const Center(child: Text('No patients found.'))
                : ListView.builder(
                    itemCount: nationalIds.length,
                    itemBuilder: (context, index) {
                      final nationalId = nationalIds[index];
                      final tests = groupedData[nationalId]!;
                      final patientName =
                          tests.first['fullname'] ?? 'Unknown Name';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: tests.first['MRI'] != null &&
                                  tests.first['MRI'] is Uint8List
                              ? CircleAvatar(
                                  backgroundImage:
                                      MemoryImage(tests.first['MRI']),
                                  radius: 30,
                                )
                              : const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                          title: Text(
                              "${patientName ?? 'Unknown'} (ID: ${nationalId ?? 'N/A'})"),
                          subtitle: Text(
                              "${tests.length - 1} test(s) available"), // Number of tests

                          onTap: () {
                            if (tests.length - 1 != 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PatientDetailsPage(
                                    nationalId: nationalId,
                                    tests: tests,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'There is no tests for this patient!')),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
