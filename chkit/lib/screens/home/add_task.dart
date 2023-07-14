import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

Color green = const Color(0xFF2E6B46);
Color orange = const Color(0xFFECB017);
Color ivory = const Color(0xFFEDE8DB);
Color darkRed = const Color(0xFF230505);

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseAuth auth = FirebaseAuth.instance;

class _AddTaskScreenState extends State<AddTaskScreen> {
  String title = '';
  Uint8List? _image;
  final User? user = auth.currentUser;
  late final uid = user?.uid;

  void addTask() async {
  try {
    // Add task to Firestore
    DocumentReference taskRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .add({
      'title': title,
      'image': _image != null, // Set 'image' field based on whether _image is not null
    });

    String taskId = taskRef.id;

    if (_image != null) {
      Reference ref = _storage.ref().child(taskId);
      UploadTask uploadTask = ref.putData(_image!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print(downloadUrl);
    }

    print('Task added successfully with ID: $taskId');
  } catch (error) {
    print('Failed to add task: $error');
  }
}


  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    }
    print('No Images Selected');
  }

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,
      appBar: AppBar(
        backgroundColor: green,
        centerTitle: true,
        title: const Text(
          'Add Task',
          style: TextStyle(color: Color(0xFFEDE8DB)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFEDE8DB)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        title = value;
                      });
                    },
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      labelStyle: const TextStyle(color: Color(0xFF2E6B46)),
                      filled: true,
                      fillColor: const Color.fromRGBO(255, 248, 233, 0.8),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              const SizedBox(height: 16.0),
              if (_image != null)
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 360,
                      height: 480,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: MemoryImage(_image!),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Positioned(
                      bottom: 20.0,
                      child: ElevatedButton(
                        onPressed: selectImage,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(green),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Select image to complete task',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFECB017),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_image == null)
                Column(
                  children: [
                    const SizedBox(height: 15.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: selectImage,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(green),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            'Select image to complete task',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFECB017),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                      addTask();
                      Navigator.pop(context); // Go back to the previous screen
                    },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(green),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Add Task',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFEDE8DB),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50.0),
            ],
          ),
        ),
      ),
    );
  }
}
