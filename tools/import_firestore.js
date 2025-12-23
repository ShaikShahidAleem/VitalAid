/**
 * Firestore Import Script
 * 
 * Usage:
 * 1. Install dependencies: npm install firebase-admin
 * 2. Make sure service-account.json is in project root
 * 3. Run: node tools/import_firestore.js
 * 
 * Options:
 * - Skip existing documents: --skip-existing
 * - Overwrite existing: --overwrite (default)
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Load service account
const serviceAccount = require(path.join(__dirname, '..', 'service-account.json'));

// Initialize Firebase
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Configuration
const JSON_FILE = path.join(__dirname, '..', 'first_aid_procedures.json');
const COLLECTION_NAME = 'first_aid_procedures';
const SKIP_EXISTING = process.argv.includes('--skip-existing');

async function importDocuments() {
  console.log('🚀 Starting Firestore import...\n');
  console.log(`📁 Reading: ${JSON_FILE}`);
  console.log(`📦 Collection: ${COLLECTION_NAME}`);
  console.log(`⚙️  Mode: ${SKIP_EXISTING ? 'Skip existing' : 'Overwrite existing'}\n`);

  try {
    // Read JSON file
    const jsonData = fs.readFileSync(JSON_FILE, 'utf8');
    const data = JSON.parse(jsonData);
    
    const documents = data.documents || [];
    console.log(`📊 Total documents to import: ${documents.length}\n`);

    let imported = 0;
    let skipped = 0;
    let errors = 0;

    // Process each document
    for (const doc of documents) {
      const docId = doc.id;
      
      // Check if document exists
      const docRef = db.collection(COLLECTION_NAME).doc(docId);
      const docSnap = await docRef.get();

      if (docSnap.exists && SKIP_EXISTING) {
        console.log(`  ⏭️  Skipped: ${docId} (already exists)`);
        skipped++;
        continue;
      }

      // Prepare document data (remove 'id' field, keep everything else)
      const docData = {
        name: doc.name,
        description: doc.description,
        keywords: doc.keywords,
        notes: doc.notes,
        steps: doc.steps
      };

      // Add to Firestore
      await docRef.set(docData, { merge: true });
      
      console.log(`  ✅ Imported: ${docId} - ${doc.name}`);
      imported++;
    }

    // Summary
    console.log('\n' + '='.repeat(50));
    console.log('📈 Import Summary:');
    console.log(`   ✅ Imported: ${imported}`);
    console.log(`   ⏭️  Skipped: ${skipped}`);
    console.log(`   ❌ Errors: ${errors}`);
    console.log(`   📊 Total: ${documents.length}`);
    console.log('='.repeat(50));
    console.log('\n✨ Import completed successfully!');

  } catch (error) {
    console.error('\n❌ Import failed:', error.message);
    process.exit(1);
  }
}

// Run import
importDocuments();
