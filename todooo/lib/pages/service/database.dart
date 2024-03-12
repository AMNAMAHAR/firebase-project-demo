import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethod {
  // Firebase Cloud Storage methods

  // Method to upload a file to Firebase Storage
  Future<String> uploadFile(File file, String fileName) async {
    try {
      Reference storageReference =
      FirebaseStorage.instance.ref().child(fileName);
      await storageReference.putFile(file);
      return await storageReference.getDownloadURL();
    } catch (e) {
      print("Error uploading file: $e");
      return ''; // Return empty URL if upload fails
    }
  }

  // Method to download a file from Firebase Storage
  Future<void> downloadFile(
      String downloadURL, String destinationFilePath) async {
    try {
      Reference storageReference = FirebaseStorage.instance.refFromURL(downloadURL);
      await storageReference.writeToFile(File(destinationFilePath));
      print("File downloaded successfully. Saved at: $destinationFilePath");
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  // Method to delete a file from Firebase Storage
  Future<void> deleteFile(String fileName) async {
    try {
      Reference storageReference =
      FirebaseStorage.instance.ref().child(fileName);
      await storageReference.delete();
      print("File deleted successfully");
    } catch (e) {
      print("Error deleting file: $e");
    }
  }

  // Cloud Firestore methods

  Future<void> addWork(Map<String, dynamic> userWorkMap, String collection) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(userWorkMap['Id'])
          .set(userWorkMap);
    } catch (e) {
      print("Error adding work to $collection: $e");
    }
  }

  Future<Stream<QuerySnapshot>> getAllWork(String collection) async {
    try {
      return FirebaseFirestore.instance.collection(collection).snapshots();
    } catch (e) {
      print("Error fetching work from $collection: $e");
      return Stream.empty();
    }
  }

  Future<void> updateIfTicked(String id, String collection, bool newValue) async {
    try {
      final docSnapshot =
      await FirebaseFirestore.instance.collection(collection).doc(id).get();
      if (docSnapshot.exists) {
        await docSnapshot.reference.update({"Yes": newValue});
        print("Document updated successfully");
      } else {
        print("Document with ID $id does not exist in collection $collection");
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }
}
