import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/model/task_model.dart';
import 'package:todo_app/screens/home_page.dart';


void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());
  await Hive.openBox<TaskModel>('tasks');
  runApp(const MaterialApp(debugShowCheckedModeBanner
      : false,home: HomePage()));
}
