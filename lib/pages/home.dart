import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  final Map<String, dynamic> user;

  // Constructor to receive user data
  const AccountPage({super.key, required this.user});

Future <void> navToInfoPage(BuildContext context) async{
  Navigator.pushNamed(context, '/info', arguments: user);
}
Future <void> navToPreviousTestsPage(BuildContext context) async{
  Navigator.pushNamed(context, '/previousTests', arguments: user);
}
Future <void> navTopatientPage(BuildContext context) async{
  Navigator.pushNamed(context, '/patient', arguments: user);
}


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFEFF5FA), // Light background
    appBar: AppBar(
      title: Text('Hi Dr. ${user['fullname']}'),
      backgroundColor: const Color(0xFFB3D9FF), // Light blue color
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            onPressed: () async {
              navToInfoPage(context);
            },
            icon: Image.asset('assets/personal-information-icon-3.jpg'),
          ),
        ),
      ],
    ),
    body: Row(
      children: [
        _buildSection(
          context,
          iconPath: 'assets/log-icon.png',
          label: 'Patients Records',
          onPressed: () async {
            navToPreviousTestsPage(context);
          },
        ),
        _buildSection(
          context,
          iconPath: 'assets/brain-icon.png',
          label: 'Test MRI Image',
          onPressed: () async {
            navTopatientPage(context);
          },
        ),
      ],
    ),
  );
}

Widget _buildSection(
  BuildContext context, {
  required String iconPath,
  required String label,
  required VoidCallback onPressed,
}) {
  return Expanded(
    flex: 1,
    child: Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Image.asset(iconPath, height: 64.0, width: 64.0), // Adjust size for better design
          ),
          const SizedBox(height: 10.0), // Add spacing between icon and text
          Text(
            label,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold), // Style text
          ),
        ],
      ),
    ),
  );
}
}
       