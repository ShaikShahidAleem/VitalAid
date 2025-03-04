// add_medical_record_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddMedicalRecordPage extends StatefulWidget {
  const AddMedicalRecordPage({Key? key}) : super(key: key);

  @override
  _AddMedicalRecordPageState createState() => _AddMedicalRecordPageState();
}

class _AddMedicalRecordPageState extends State<AddMedicalRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  TextEditingController _dateOfAdmissionController = TextEditingController();
  TextEditingController _checkupDateController = TextEditingController();
  TextEditingController _doctorConsultedController = TextEditingController();
  TextEditingController _prescriptionOfferedController = TextEditingController();

  List<String> _medicalReportUrls = [];
  List<File> _medicalReportFiles = [];

  Future<void> _pickMedicalReports() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null) {
      setState(() {
        _medicalReportFiles = images.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<void> _uploadMedicalReports() async {
    if (_medicalReportFiles.isEmpty) return;

    setState(() {});

    List<String> urls = [];
    for (File file in _medicalReportFiles) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + "_" + file.path.split('/').last;
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('medical_reports')
          .child(_auth.currentUser!.uid)
          .child(fileName);

      await ref.putFile(file);
      String downloadURL = await ref.getDownloadURL();
      urls.add(downloadURL);
    }

    setState(() {
      _medicalReportUrls = urls;
    });
  }

  Future<void> _saveMedicalRecord() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Upload medical reports
      await _uploadMedicalReports();

      // Save data to Firestore
      try {
        await _firestore.collection('medical_records').add({
          'userId': _auth.currentUser!.uid,
          'dateOfAdmission': _dateOfAdmissionController.text,
          'checkupDate': _checkupDateController.text,
          'doctorConsulted': _doctorConsultedController.text,
          'prescriptionOffered': _prescriptionOfferedController.text,
          'medicalReports': _medicalReportUrls,
        });

        // Navigate back to medical records page
        Navigator.pop(context);
      } catch (e) {
        print("Error saving medical record: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save medical record")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medical Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateOfAdmissionController,
                decoration: const InputDecoration(labelText: 'Date of Admission'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the date of admission';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _checkupDateController,
                decoration: const InputDecoration(labelText: 'Checkup Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the checkup date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _doctorConsultedController,
                decoration: const InputDecoration(labelText: 'Doctor Consulted'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the doctor\'s name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _prescriptionOfferedController,
                decoration: const InputDecoration(labelText: 'Prescription Offered'),
                maxLines: 3,
              ),
              ElevatedButton(
                onPressed: _pickMedicalReports,
                child: const Text('Pick Medical Reports'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveMedicalRecord,
                child: const Text('Save Medical Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
