import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/model/task_model.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  var titleController = TextEditingController();
  var notesController = TextEditingController();
  var isTaskCompleted = false;

  @override
  Widget build(BuildContext context) {
    var fWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
            margin: const EdgeInsets.only(top: 30),
            child: const Center(
                child: Text(
              'Add Task',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ))),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context,false);
          },
          child: const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Icon(Icons.close, size: 30),
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            infoCard(fWidth, 80, 'Title', titleController),
            infoCard(fWidth, 100, 'Notes', notesController),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15.0),
                  )),
              child: CheckboxListTile(
                splashRadius: 5,
                //checkColor: const Color(0xFF1A4D54),
                title: const Text('Task Completed',style:  TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, )),
                value: isTaskCompleted,
                onChanged: (newValue) {
                  setState(() {
                    isTaskCompleted = newValue!;
                  });
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Container(
          margin: const EdgeInsets.only(left: 20),
          child: addTaskWidget(fWidth)),
    );
  }

  Widget addTaskWidget(double width) {
    return InkWell(
      onTap: () {
        if (titleController.text.isNotEmpty &&
            notesController.text.isNotEmpty) {
          addTasksToDB().then((value) => {
                if (value)
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Task added successfully in DB"),
                        backgroundColor: Colors.green,
                      ),
                    )
                  }
                else
                  {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Error while adding task to DB"),
                        backgroundColor: Colors.redAccent,
                      ),
                    )
                  }
              });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please add a title"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
          width: width,
          height: 60,
          margin: const EdgeInsets.only(left: 10),
          decoration: const BoxDecoration(
              color: Color(0xFF1A4D54),
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              )),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Add Task',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          )),
    );
  }

  Widget infoCard(double width, double height, String name,
      TextEditingController controller) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: const BorderRadius.all(
            Radius.circular(15.0),
          )),
      child: Padding(
        padding: const EdgeInsets.only(left: 30, top: 20),
        child: TextFormField(
          decoration: InputDecoration(
            hintText: name,
            border: InputBorder.none
          ),
          controller: controller,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  Future<bool> addTasksToDB() async {
    try {
      final taskBox = Hive.box<TaskModel>('tasks');
      final newTask =
          TaskModel(titleController.text, notesController.text, isTaskCompleted);
      taskBox.add(newTask);
      Navigator.pop(context,true);
      return true;
    } catch (e) {
      return false;
    }
  }
}
