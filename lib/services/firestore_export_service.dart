import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class FirestoreExportService {
  /// Export all documents from a collection to a JSON file
  static Future<String> exportCollectionToJson({
    required String collectionName,
    String fileName = 'firestore_export.json',
  }) async {
    try {
      // Get all documents from the collection
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionName).get();

      // Convert to a map structure
      List<Map<String, dynamic>> documents = [];
      
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> docData = {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
        documents.add(docData);
      }

      // Create the export data structure
      Map<String, dynamic> exportData = {
        'collection': collectionName,
        'documentCount': documents.length,
        'exportedAt': DateTime.now().toIso8601String(),
        'documents': documents,
      };

      // Convert to JSON string
      String jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get the app's documents directory
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${documentsDirectory.path}/$fileName';
      
      // Write to file
      File file = File(filePath);
      await file.writeAsString(jsonString);

      print('✅ Export successful!');
      print('📁 File saved to: $filePath');
      print('📊 Total documents: ${documents.length}');
      
      return filePath;
    } catch (e) {
      print('❌ Export failed: $e');
      rethrow;
    }
  }

  /// Export first_aid_procedures collection specifically
  static Future<String> exportFirstAidProcedures() async {
    return await exportCollectionToJson(
      collectionName: 'first_aid_procedures',
      fileName: 'first_aid_procedures.json',
    );
  }

  /// Get collection document count
  static Future<int> getDocumentCount(String collectionName) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(collectionName).get();
    return querySnapshot.docs.length;
  }

  /// Preview collection data (returns first 5 documents as JSON string)
  static Future<String> previewCollection(String collectionName) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(collectionName).limit(5).get();

    List<Map<String, dynamic>> documents = [];
    
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      documents.add({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }

    return const JsonEncoder.withIndent('  ').convert({
      'collection': collectionName,
      'previewCount': documents.length,
      'documents': documents,
    });
  }
}

// Example usage in a Flutter widget:
/*
import 'package:vitalaid/services/firestore_export_service.dart';

void exportData() async {
  try {
    String filePath = await FirestoreExportService.exportFirstAidProcedures();
    print('Export saved to: $filePath');
    
    // Show success message to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export saved to: $filePath')),
    );
  } catch (e) {
    print('Export failed: $e');
  }
}
*/

// To run as a standalone script, use this main():
/*
import 'package:firebase_core/firebase_core.dart';
import 'package:vitalaid/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  String filePath = await FirestoreExportService.exportFirstAidProcedures();
  print('Done! Export saved to: $filePath');
  exit(0);
}
*/
