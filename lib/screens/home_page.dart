import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_app/screens/add_task_page.dart';
import 'package:todo_app/model/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<TaskModel> taskList = [];
  var searchController = TextEditingController();
  var searchText = "";
  final taskBox = Hive.box<TaskModel>('tasks');


  @override
  void initState() {
    retrieveDataFromDB();
    searchController.addListener(() {
      setState(() {
        searchText = searchController.text;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var fWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: fWidth,
        color: const Color(0xFF1A4D54),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [searchBar(fWidth), taskContainer()],
        ),
      ),
    );
  }

  Widget taskContainer() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(15.0),
            )),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                  left: 20, right: 20, bottom: 10, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task-list',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${taskList.length} tasks',
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(createRoute()).then((value)  {
                        if(value)setState(() {retrieveDataFromDB();});
                      });
                    },
                    child: Container(
                        height: 50,
                        width: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                            // color: Colors.blueAccent,
                            color: Color(0xFF1A4D54),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            )),
                        child: const Icon(
                          size: 30,
                          Icons.add,
                          color: Colors.white,
                        )),
                  )
                ],
              ),
            ),
            taskListWidget()
          ],
        ),
      ),
    );
  }

  Route createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const AddTaskPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  Widget taskListWidget() {
    List<TaskModel> filteredTasks = taskList
        .where((task) =>
        task.title.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            var key = filteredTasks[index];
            return Dismissible(
              key: Key(key.title.toString()),
              background: Container(
                decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    )),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
              ),
              onDismissed: (direction) {
                setState(() {
                  deleteTasksFromDB(key).then((value) => {
                        value
                            ? ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text('Task deleted successfully'),
                                ),
                              )
                            : ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  content: Text('Error deleting Task'),
                                ),
                              )
                      });
                });
              },
              child: Card(
                elevation: 4,
                child: ListTile(
                    leading: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                            color: Color(0xFF1A4D54),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            )),
                        child: Center(
                          child: Text(
                            filteredTasks[index].title[0],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        )),
                    title: Text(
                      filteredTasks[index].title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(filteredTasks[index].description),
                    trailing: completedTaskWidget(key)),
              ),
            );
          },
          separatorBuilder: (_, __) {
            return const SizedBox(
              height: 5,
            );
          },
        ),
      ),
    );
  }

  Widget completedTaskWidget(TaskModel model) {
    return InkWell(
      onTap: () {
        var getIndex = taskList.indexWhere((element) => element == model);
        setState(() {
          model.isCompleted = !model.isCompleted;
          taskBox.putAt(getIndex,
              TaskModel(model.title, model.description, model.isCompleted));
        });
      },
      child: model.isCompleted
          ? const Icon(Icons.circle, color: Color(0xFF1A4D54))
          : const Icon(Icons.circle_outlined, color: Color(0xFF1A4D54)),
    );
  }

  Widget searchBar(double width) {
    return Container(
      width: width,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
      decoration: const BoxDecoration(
          color: Colors.white38,
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          )),
      child: Row(
        children: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(
                Icons.search,
                color: Colors.white,
                size: 25,
              )),
          Expanded(
            child: TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search by task..',
                hintStyle: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> deleteTasksFromDB(TaskModel model) async {
    try {
      var getIndex = taskList.indexWhere((element) => element == model);
      taskBox.deleteAt(getIndex);
      taskList.remove(model);
      return true;
    } catch (e) {
      return false;
    }
  }

  void retrieveDataFromDB() {
    taskList = taskBox.values.toList();
  }

  void filterList(){

  }
}
