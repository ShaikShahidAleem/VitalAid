import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false; // To toggle between view and edit modes
  Map<String, dynamic>? profileData;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileData(); // Fetch profile data when the page loads
  }

  Future<void> fetchProfileData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          profileData = snapshot.data() as Map<String, dynamic>;
          // Pre-fill controllers with fetched data
          _fullNameController.text = profileData?['fullName'] ?? '';
          _phoneNumberController.text = profileData?['phoneNumber'] ?? '';
          _addressLine1Controller.text = profileData?['addressLine1'] ?? '';
          _addressLine2Controller.text = profileData?['addressLine2'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching profile data: $e")),
      );
    }
  }

  Future<void> saveProfile() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
        'fullName': _fullNameController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
        'addressLine1': _addressLine1Controller.text.trim(),
        'addressLine2': _addressLine2Controller.text.trim(),
      });

      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving profile data: $e")),
      );
    }
  }

  Widget buildProfileField(String label, TextEditingController controller,
      {bool isEditable = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        if (_isEditing && isEditable)
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter $label',
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              controller.text.isNotEmpty ? controller.text : 'Not provided',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (profileData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon:
                Icon(_isEditing ? Icons.save : Icons.edit), // Toggle Edit/Save button
            onPressed:
                !_isEditing ? () => setState(() => _isEditing = true) : saveProfile,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildProfileField('Full Name', _fullNameController),
              buildProfileField('Phone Number', _phoneNumberController),
              buildProfileField('Address Line 1', _addressLine1Controller),
              buildProfileField('Address Line 2', _addressLine2Controller),
            ],
          ),
        ),
      ),
    );
  }
}
