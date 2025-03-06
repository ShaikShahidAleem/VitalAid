import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_edit_medical_record_page.dart';

class MedicalRecordsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteRecord(BuildContext context, String recordId) async {
    final User? user = _auth.currentUser;
    final String? uid = user?.uid;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('medical_records')
          .doc(recordId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    final String? uid = user?.uid;

    if (uid == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Records'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(uid)
            .collection('medical_records')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data?.docs ?? [];

          if (records.isEmpty) {
            return Center(child: Text('No medical records found.'));
          }

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index].data() as Map<String, dynamic>;
              final recordId = records[index].id;
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Date: ${record['checkupDate'] ?? 'N/A'}'),
                  subtitle: Text('Doctor: ${record['doctorConsulted'] ?? 'N/A'}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditMedicalRecordPage(
                                recordId: recordId,
                                record: record,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteRecord(context, recordId),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Medical Record Details'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Checkup Date: ${record['checkupDate'] ?? 'N/A'}'),
                              Text('Doctor Consulted: ${record['doctorConsulted'] ?? 'N/A'}'),
                              Text('Prescription: ${record['prescriptionOffered'] ?? 'N/A'}'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text('Close'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditMedicalRecordPage(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}