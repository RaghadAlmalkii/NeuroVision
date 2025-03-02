import 'package:flutter/material.dart';
import 'logIn.dart'; // Import the login page

class InfoPage extends StatelessWidget {
  final Map<String, dynamic> user;

  // Constructor to receive user data
  InfoPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FA), // Light background
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFB3D9FF), // Light blue color
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 400, // Fixed width for clean design
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  const Center(
                    child: Text(
                      'User Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Divider(height: 30, color: Colors.grey),

                  // Full Name
                  _buildInfoRow('Full Name', user['fullname']),
                  const SizedBox(height: 15),

                  // Email
                  _buildInfoRow('Email', user['email']),
                  const SizedBox(height: 15),

                  // Phone
                  _buildInfoRow('Phone', user['phone']),
                  const SizedBox(height: 15),

                  // License ID
                  _buildInfoRow('License ID', user['licenseID']),
                ],
              ),
            ),

            // Logout Button
            ElevatedButton(
              onPressed: () async {
                bool confirmLogout = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm Logout"),
                      content: const Text("Are you sure you want to log out?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // Cancel logout
                          },
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // Confirm logout
                          },
                          child: const Text("Log Out"),
                        ),
                      ],
                    );
                  },
                );

                if (confirmLogout) {
                  // Secure session termination (Clear stored user session)
                  // Example: SharedPreferences prefs = await SharedPreferences.getInstance();
                  // await prefs.clear(); // Clear user data

                  // Redirect to login page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LogIn()), // Redirect
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child:
                  const Text("Log Out", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  // Reusable row widget for displaying info
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // Logout Confirmation Dialog
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _logout(context); // Proceed with logout
              },
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // Logout Functionality
  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LogIn()), // Correct class name
      (route) => false,
    );
  }
}
