import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddEditMedicalRecordPage extends StatefulWidget {
  final String? recordId;
  final Map<String, dynamic>? record;

  AddEditMedicalRecordPage({Key? key, this.recordId, this.record})
      : super(key: key);

  @override
  _AddEditMedicalRecordPageState createState() =>
      _AddEditMedicalRecordPageState();
}

class _AddEditMedicalRecordPageState extends State<AddEditMedicalRecordPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _checkupDateController;
  late TextEditingController _doctorConsultedController;
  late TextEditingController _prescriptionOfferedController;
  late TextEditingController _testResultsController;

  List<File> _prescriptionImages = [];
  List<File> _prescriptionPdfs = [];
  List<File> _testResultsImages = [];
  List<File> _testResultsPdfs = [];

  @override
  void initState() {
    super.initState();
    _checkupDateController = TextEditingController(
        text: widget.record?['checkupDate'] ?? '');
    _doctorConsultedController = TextEditingController(
        text: widget.record?['doctorConsulted'] ?? '');
    _prescriptionOfferedController = TextEditingController(
        text: widget.record?['prescriptionOffered'] ?? '');
    _testResultsController =
        TextEditingController(text: widget.record?['testResults'] ?? '');
  }

  @override
  void dispose() {
    _checkupDateController.dispose();
    _doctorConsultedController.dispose();
    _prescriptionOfferedController.dispose();
    _testResultsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _checkupDateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _pickImages(String field) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();

    if (images != null) {
      setState(() {
        if (field == 'prescription') {
          _prescriptionImages
              .addAll(images.map((image) => File(image.path)));
        } else {
          _testResultsImages.addAll(images.map((image) => File(image.path)));
        }
      });
    }
  }

  Future<void> _takePhoto(String field) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        if (field == 'prescription') {
          _prescriptionImages.add(File(photo.path));
        } else {
          _testResultsImages.add(File(photo.path));
        }
      });
    }
  }

  Future<void> _pickPdfs(String field) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        if (field == 'prescription') {
          _prescriptionPdfs.addAll(result.files
              .where((file) => file.path != null)
              .map((file) => File(file.path!)));
        } else {
          _testResultsPdfs.addAll(result.files
              .where((file) => file.path != null)
              .map((file) => File(file.path!)));
        }
      });
    }
  }

  Future<List<String>> _uploadFiles(List<File> files, String folderName) async {
    List<String> urls = [];

    if (files.isEmpty) return urls;

    try {
      for (var file in files) {
        String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';

        firebase_storage.Reference storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('users')
            .child(_auth.currentUser!.uid)
            .child(folderName)
            .child(fileName);

        firebase_storage.UploadTask uploadTask = storageRef.putFile(file);

        await uploadTask.whenComplete(() async {
          String downloadUrl = await storageRef.getDownloadURL();
          urls.add(downloadUrl);
        });
      }
    } catch (e) {
      print("Error uploading files: $e");
    }
    return urls;
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          // Show loading indicator
        });

        final String? uid = _auth.currentUser?.uid;
        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not logged in')),
          );
          return;
        }

        // Upload files and get URLs
        List<String> prescriptionImageUrls = await _uploadFiles(_prescriptionImages, 'prescription_images');
        List<String> prescriptionPdfUrls = await _uploadFiles(_prescriptionPdfs, 'prescription_pdfs');
        List<String> testResultsImageUrls = await _uploadFiles(_testResultsImages, 'test_results_images');
        List<String> testResultsPdfUrls = await _uploadFiles(_testResultsPdfs, 'test_results_pdfs');

        final data = {
          'userId': uid,
          'checkupDate': _checkupDateController.text,
          'doctorConsulted': _doctorConsultedController.text,
          'prescriptionOffered': _prescriptionOfferedController.text,
          'testResults': _testResultsController.text,
          'prescriptionImageUrls': prescriptionImageUrls,
          'prescriptionPdfUrls': prescriptionPdfUrls,
          'testResultsImageUrls': testResultsImageUrls,
          'testResultsPdfUrls': testResultsPdfUrls,
          'timestamp': FieldValue.serverTimestamp(),
        };

        if (widget.recordId != null) {
          // Updating existing record
          await _firestore.collection('users').doc(uid).collection('medical_records').doc(widget.recordId).update(data);
        } else {
          // Adding a new record
          await _firestore.collection('users').doc(uid).collection('medical_records').add(data);
        }

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Record saved successfully')),
        );
      } catch (e) {
        print("Error saving record: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving record: $e')),
        );
      } finally {
        setState(() {
          // Hide loading indicator
        });
      }
    }
  }

  Widget _buildFileSelectionButtons(String field) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ElevatedButton(
            onPressed: () => _pickImages(field),
            child: Text('Upload Photos'),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _takePhoto(field),
            child: Text('Take Photo'),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => _pickPdfs(field),
            child: Text('Upload PDFs'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview(String field) {
    List<File> images =
        field == 'prescription' ? _prescriptionImages : _testResultsImages;
    List<File> pdfs =
        field == 'prescription' ? _prescriptionPdfs : _testResultsPdfs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selected Images:'),
        SizedBox(height: 5),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Image.file(images[index],
                    width: 100, height: 100, fit: BoxFit.cover),
              );
            },
          ),
        ),
        SizedBox(height: 10),
        Text('Selected PDFs:'),
        SizedBox(height: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pdfs.map((pdf) => Text(pdf.path.split('/').last)).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.recordId == null ? 'Add Medical Record' : 'Edit Medical Record'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _checkupDateController,
                  decoration: InputDecoration(
                    labelText: 'Checkup Date',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the checkup date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _doctorConsultedController,
                  decoration: InputDecoration(labelText: 'Doctor Consulted'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the doctor\'s name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _prescriptionOfferedController,
                  decoration: InputDecoration(labelText: 'Prescription Offered'),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Text('Prescription Files:'),
                SizedBox(height: 8),
                _buildFileSelectionButtons('prescription'),
                SizedBox(height: 8),
                _buildFilePreview('prescription'),
                SizedBox(height: 16),
                TextFormField(
                  controller: _testResultsController,
                  decoration: InputDecoration(labelText: 'Test Results'),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Text('Test Result Files:'),
                SizedBox(height: 8),
                _buildFileSelectionButtons('testResults'),
                SizedBox(height: 8),
                _buildFilePreview('testResults'),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveRecord,
                  child: Text('Save Medical Record'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}