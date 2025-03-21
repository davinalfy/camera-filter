import 'package:cloud_firestore/cloud_firestore.dart';

class biodataservice {
  final FirebaseFirestore db;

  const biodataservice(this.db);

  Future<String> add(Map<String, dynamic> data) async {
    //add a new document with a generate ID
    final document = await db.collection('biodata').add(data);
    return document.id;
  }

  //fetching data
  Stream<QuerySnapshot<Map<String, dynamic>>> getBiodata() {
    return db.collection('biodata').snapshots();
  }

  //delete a document by ID
  Future<void> delete(String documentId) async {
    await db.collection('biodata').doc(documentId).delete();
  }

  //update a document by ID
  Future<void> update(String documentId, Map<String, dynamic> data) async {
    await db.collection('biodata').doc(documentId).update(data);
  }
}