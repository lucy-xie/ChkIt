
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

Color green = const Color(0xFF2E6B46);
Color orange = const Color(0xFFECB017);
Color ivory = const Color(0xFFEDE8DB);
Color darkRed = const Color(0xFF230505);

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;

class EditTaskPage extends StatefulWidget {
  final String taskId;

  const EditTaskPage({Key? key, required this.taskId}) : super(key: key);
  
  bool? get image => null;

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController _titleController;
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    fetchTaskData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void fetchTaskData() async {
    try {
      final taskSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(widget.taskId)
          .get();

      if (taskSnapshot.exists) {
        final taskData = taskSnapshot.data() as Map<String, dynamic>;
        final title = taskData['title'] as String? ?? '';

        _titleController.text = title;

        // Check if the task has an image in Firebase Storage
        final imageRef = _storage.ref().child(widget.taskId);
        final downloadURL = await imageRef.getDownloadURL();

        if (downloadURL.isNotEmpty) {
          final imageData =
              await NetworkAssetBundle(Uri.parse(downloadURL)).load('');
          setState(() {
            _image = imageData.buffer.asUint8List();
          });
        }
      }
    } catch (error) {
      print('Failed to fetch task data: $error');
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

  Future<String> uploadImageToStorage(
    String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void updateTask() async {
    final String updatedTitle = _titleController.text.trim();

    final updatedData = {
      'title': updatedTitle,
    };

    final setTrue = {
      'image': true,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(widget.taskId)
          .update(updatedData);

      if (_image != null) {
        // Update the image in Firebase Storage
        Reference ref = _storage.ref().child(widget.taskId);
        await ref.putData(_image!);
        await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(widget.taskId)
          .update(setTrue);
      }

      print('Task updated successfully!');
      Navigator.pop(context);
    } catch (error) {
      print('Failed to update task: $error');
    }
  }

  void deleteTask() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('tasks')
          .doc(widget.taskId)
          .delete();

      if(widget.image == true){
        await _storage.ref().child(widget.taskId).delete();
      }

      print('Task deleted successfully!');
      Navigator.pop(context); 
    } catch (error) {
      print('Failed to delete task: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: green,
        centerTitle: true,
        title: const Text(
          'Edit Task',
          style: TextStyle(color: Color(0xFFEDE8DB)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFEDE8DB)),
        actions: [
          IconButton(
            onPressed: deleteTask,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 25.0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 360,
                  child: TextFormField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: TextStyle(color: green),
                      filled: true,
                      fillColor: const Color.fromRGBO(255, 248, 233, 0.8),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              if (_image != null)
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Center(
                      child: Container(
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
                        child: const Padding(
                          padding: EdgeInsets.all(10),
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
                        child: const Padding(
                          padding: EdgeInsets.all(10),
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
                  onPressed: updateTask,
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
                      'Update Task',
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