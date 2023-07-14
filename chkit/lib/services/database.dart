import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chkit/models/task.dart';
import 'dart:typed_data';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future updateUserData(String title, {Uint8List? image}) async {
    return await userCollection.doc(uid).set({
      'title': title,
      'image': image,
  });
  }


  Stream<List<Tasks>> getTasks(String userId) {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final tasksCollectionRef = userDocRef.collection('tasks');

    return tasksCollectionRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final title = doc.data()['title'] as String;
        final image= doc.data()['image'] as bool;
        final taskId = doc.id;


        return Tasks(taskId: taskId, title: title, image: image);
      }).toList();
    });
  }


  Stream<List<Tasks>> get tasks {
    return getTasks(uid);
  }
}

