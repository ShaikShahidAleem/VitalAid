/**
 * Node.js script to export Firestore collection to JSON
 * 
 * Prerequisites:
 * 1. Install Node.js
 * 2. Install Firebase CLI: npm install -g firebase-tools
 * 3. Or install firebase-admin: npm install firebase-admin
 * 
 * Method 1: Using Firebase CLI (Recommended)
 * -------------------------------------------
 * 1. Login to Firebase:
 *    firebase login
 * 
 * 2. Select your project:
 *    firebase use your-project-id
 * 
 * 3. Export collection:
 *    firebase firestore:export first_aid_procedures.json --collection-ids=first_aid_procedures
 * 
 * 
 * Method 2: Using this script with Firebase Admin SDK
 * ---------------------------------------------------
 * 1. Install dependencies:
 *    npm install firebase-admin
 * 
 * 2. Download your service account key from Firebase Console:
 *    - Go to Project Settings > Service Accounts
 *    - Click "Generate new private key"
 *    - Save as service-account.json in this directory
 * 
 * 3. Run this script:
 *    node export_firestore.js
 */

const admin = require('firebase-admin');
const fs = require('fs');

// Load service account - REPLACE with your service account path
// Note: Path is relative to project root, not this script's location
const path = require('path');
const serviceAccount = require(path.join(__dirname, '..', 'service-account.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function exportCollection(collectionName, outputFile) {
  console.log(`🚀 Starting export of '${collectionName}' collection...\n`);
  
  try {
    const snapshot = await db.collection(collectionName).get();
    
    if (snapshot.empty) {
      console.log('⚠️  No documents found in collection');
      return;
    }
    
    const documents = [];
    
    snapshot.forEach(doc => {
      const data = {
        id: doc.id,
        ...doc.data()
      };
      documents.push(data);
      console.log(`  ✓ Found document: ${doc.id}`);
    });
    
    const exportData = {
      collection: collectionName,
      documentCount: documents.length,
      exportedAt: new Date().toISOString(),
      documents: documents
    };
    
    // Write to JSON file with pretty formatting
    fs.writeFileSync('first_aid_procedures.json', JSON.stringify(exportData, null, 2));
    
    console.log(`\n✅ Export successful!`);
    console.log(`📁 File saved to: first_aid_procedures.json`);
    console.log(`📊 Total documents: ${documents.length}`);
    
  } catch (error) {
    console.error('❌ Export failed:', error);
    process.exit(1);
  }
}

// Export first_aid_procedures collection
exportCollection('first_aid_procedures', 'first_aid_procedures.json')
  .then(() => {
    console.log('\n✨ Done!');
    process.exit(0);
  })
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
