import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  late TextEditingController _dateOfAdmissionController;
  late TextEditingController _checkupDateController;
  late TextEditingController _doctorConsultedController;
  late TextEditingController _prescriptionOfferedController;
  late TextEditingController _testResultsController;

  List<File> _prescriptionImages = [];
  List<File> _prescriptionPdfs = [];
  List<File> _testResultsImages = [];
  List<File> _testResultsPdfs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateOfAdmissionController = TextEditingController(
        text: widget.record?['dateOfAdmission'] ?? '');
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
    _dateOfAdmissionController.dispose();
    _checkupDateController.dispose();
    _doctorConsultedController.dispose();
    _prescriptionOfferedController.dispose();
    _testResultsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF44CDFF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
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
          _isLoading = true;
        });

        final String? uid = _auth.currentUser?.uid;
        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not logged in'),
            ),
          );
          return;
        }

        // Upload files and get URLs
        List<String> prescriptionImageUrls = await _uploadFiles(_prescriptionImages, 'prescription_images');
        List<String> prescriptionPdfUrls = await _uploadFiles(_prescriptionPdfs, 'prescription_pdfs');
        List<String> testResultsImageUrls = await _uploadFiles(_testResultsImages, 'test_results_images');
        List<String> testResultsPdfUrls = await _uploadFiles(_testResultsPdfs, 'test_results_pdfs');

        final data = {
          'dateOfAdmission': _dateOfAdmissionController.text,
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

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Record saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print("Error saving record: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving record: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFileSelectionButtons(String field) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.photo_library,
            label: 'Photos',
            onTap: () => _pickImages(field),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: () => _takePhoto(field),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.picture_as_pdf,
            label: 'PDFs',
            onTap: () => _pickPdfs(field),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF44CDFF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF44CDFF).withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0EA5E9), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0EA5E9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(String field) {
    List<File> images =
        field == 'prescription' ? _prescriptionImages : _testResultsImages;
    List<File> pdfs =
        field == 'prescription' ? _prescriptionPdfs : _testResultsPdfs;

    if (images.isEmpty && pdfs.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${images.length} image(s) selected',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF44CDFF).withOpacity(0.3),
                      ),
                      image: DecorationImage(
                        image: FileImage(images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (pdfs.isNotEmpty) ...[
            if (images.isNotEmpty) const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${pdfs.length} PDF(s) selected',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...pdfs.map((pdf) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${pdf.path.split('/').last}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF44CDFF), Color(0xFF0EA5E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.recordId == null ? 'Add Medical Record' : 'Edit Medical Record',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: [
                // Header Section
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF44CDFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Record Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Date of Admission Field
                _buildStyledTextField(
                  controller: _dateOfAdmissionController,
                  label: 'Date of Admission',
                  icon: Icons.calendar_today,
                  readOnly: true,
                  onTap: () => _selectDate(context, _dateOfAdmissionController),
                  validator: (value) => null,
                ),
                const SizedBox(height: 16),

                // Checkup Date Field
                _buildStyledTextField(
                  controller: _checkupDateController,
                  label: 'Checkup Date',
                  icon: Icons.event,
                  readOnly: true,
                  onTap: () => _selectDate(context, _checkupDateController),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select the checkup date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Doctor Consulted Field
                _buildStyledTextField(
                  controller: _doctorConsultedController,
                  label: 'Doctor Consulted',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the doctor\'s name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Prescription Field
                _buildStyledTextField(
                  controller: _prescriptionOfferedController,
                  label: 'Prescription Offered',
                  icon: Icons.medical_services,
                  maxLines: 4,
                  validator: (value) => null,
                ),
                const SizedBox(height: 16),

                // Test Results Field
                _buildStyledTextField(
                  controller: _testResultsController,
                  label: 'Test Results',
                  icon: Icons.science,
                  maxLines: 4,
                  validator: (value) => null,
                ),
                const SizedBox(height: 24),

                // Prescription Files Section
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF44CDFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Prescription Files',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFileSelectionButtons('prescription'),
                _buildFilePreview('prescription'),
                const SizedBox(height: 24),

                // Test Results Files Section
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF44CDFF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Test Result Files',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFileSelectionButtons('testResults'),
                _buildFilePreview('testResults'),
                const SizedBox(height: 32),

                // Save Button
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF44CDFF), Color(0xFF0EA5E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF44CDFF).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _saveRecord,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.save, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Save Medical Record',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Loading Overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF44CDFF)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Saving record...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF44CDFF),
          ),
          suffixIcon: readOnly
              ? const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF44CDFF),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF44CDFF),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}