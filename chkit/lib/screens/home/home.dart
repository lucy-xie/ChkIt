import 'package:flutter/material.dart';
import 'package:chkit/services/database.dart';
import 'package:provider/provider.dart';
import 'package:chkit/models/task.dart';
import 'add_task.dart';
import 'to_do_list.dart';


Color green = const Color(0xFF2E6B46);
Color orange = const Color(0xFFECB017);
Color ivory = const Color(0xFFEDE8DB);
Color darkRed = const Color(0xFF230505);

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Tasks>?>.value(
      value: DatabaseService(uid: '0').tasks,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        color: ivory,
        theme: ThemeData(
          fontFamily: 'Alata',
          scaffoldBackgroundColor: ivory, 
        ),
        home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: green,
            title: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Chk',
                    style: TextStyle(color: ivory, fontSize: 32, fontFamily: 'Alata',),
                  ),
                  TextSpan(
                    text: 'It',
                    style: TextStyle(color: orange, fontSize: 32, fontFamily: 'Alata',),
    
                  ),
                ],
              ),
            )
          ),
           body: SingleChildScrollView(
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  child: Text(
                    "To Do Tasks",
                    style: TextStyle(fontSize: 20, color: darkRed),
                  ),
                ),
                const ToDoList(completed: false),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,  vertical: 15.0),
                  child: Text(
                    "Completed",
                    style: TextStyle(fontSize: 20, color: darkRed),
                  ),
                ),
                const ToDoList(completed: true),
              ],
                     ),
           ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: green,
            child: Icon(Icons.add, color: ivory),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
          ),
          // bottomNavigationBar:ClipRRect(
          //   borderRadius: const BorderRadius.only(
          //     topLeft: Radius.circular(20.0),
          //     topRight: Radius.circular(20.0),
          //   ),
          //   child: BottomNavigationBar(
          //     showSelectedLabels: false,
          //     showUnselectedLabels: false,
          //     backgroundColor: green,
          //     selectedItemColor: orange,
          //     unselectedItemColor: ivory,
          //     iconSize: 30,
          //     items: const [
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.home),
          //         label: 'Home',
          //       ),
          //       BottomNavigationBarItem(
          //         icon: Icon(Icons.calendar_month_rounded),
          //         label: 'Upcoming',
                  
          //       ),
          //     ],
          //   ),
          ),
        ),
      );
  }
}
