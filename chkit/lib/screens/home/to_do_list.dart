import 'package:chkit/screens/home/edit_task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chkit/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final storageRef = FirebaseStorage.instance.ref();

class ToDoList extends StatelessWidget {
  final bool completed;

  const ToDoList({Key? key, required this.completed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('users').doc(uid).collection('tasks').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Tasks> toDoTasks = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] as String;
            final taskId = doc.id;
            final image = data.containsKey('image') ? data['image'] as bool : false;

            return Tasks(taskId: taskId, title: title, image: image);
          }).toList();

          List<Tasks> filteredTasks = toDoTasks;
          if (completed) {
            filteredTasks = toDoTasks.where((task) => task.image).toList();
          } else {
            filteredTasks = toDoTasks.where((task) => !task.image).toList();
          }

          if (filteredTasks.isEmpty) {
            return Center(
              child: Text(
                completed ? 'No tasks completed yet' : 'All tasks completed. Try adding more!',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            child: Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 15,
                children: filteredTasks.map((task) {
                  if (completed && task.image) {
                    return FutureBuilder<String>(
                      future: storageRef.child(task.taskId).getDownloadURL(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error occurred');
                        }
                        final imageUrl = snapshot.data!;
                        return Container(
                          width: 170,
                          height: 226,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF2E6B46),
                              width: 3,
                            ),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(30),
                              right: Radius.circular(30),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 4),  // Update the offset to create an inner shadow
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskPage(taskId: task.taskId),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      color: Color(0xFFEDE8DB),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final textSpan = TextSpan(
                          text: task.title,
                          style: const TextStyle(
                            color: Color(0xFF230505),
                            fontSize: 18,
                          ),
                        );
                        final textPainter = TextPainter(
                          text: textSpan,
                          textDirection: TextDirection.ltr,
                          maxLines: 1,
                        )..layout(maxWidth: constraints.maxWidth - 40);

                        return Container(
                          width: 170,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF2E6B46),
                              width: 3,
                            ),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(30),
                              right: Radius.circular(30),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskPage(taskId: task.taskId),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: const TextStyle(
                                      color: Color(0xFF230505),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }).toList(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const Text('Error occurred');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
