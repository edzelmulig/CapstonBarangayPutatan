import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImageService {
  // SELECT IMAGE
  static Future<PlatformFile?> selectImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return null;
    }
    return result.files.first;
  }

  // COMPRESS IMAGE (Helper method)
  static Future<File> compressImage(File file) async {
    // Implement image compression here
    return file; // Placeholder, return the compressed file
  }

  // UPLOAD IMAGE
  static Future<String?> uploadImage(
      PlatformFile? selectedImage, {
        String? oldImageURL,
        String folder = 'serviceImages',
      }) async {
    if (selectedImage == null || selectedImage.path == null) return null;

    // Compress the image before uploading
    final File compressedImage = await compressImage(File(selectedImage.path!));

    // Generate the storage path
    final path = '$folder/${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}_${selectedImage.name}';
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      // Upload the file
      await ref.putFile(compressedImage);
      final downloadURL = await ref.getDownloadURL();

      // If an old image URL exists, delete the old image
      if (oldImageURL != null && oldImageURL.isNotEmpty) {
        final oldImageRef = FirebaseStorage.instance.refFromURL(oldImageURL);
        await oldImageRef.delete();
        debugPrint("Old image deleted successfully.");
      }
      return downloadURL;
    } on FirebaseException catch (e) {
      debugPrint("Firebase Exception during file upload: ${e.message}");
    } catch (e) {
      debugPrint("Error during file upload: $e");
    }
    return null;
  }
}