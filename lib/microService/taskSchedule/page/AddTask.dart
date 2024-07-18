import 'package:app_template/database/daos/TaskDao.dart';
import 'package:app_template/manager/GlobalManager.dart';
import 'package:app_template/microService/taskSchedule/module/AddTaskModel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../common/Task.dart';
import '../common/Todo.dart';
import '../component/TodoWidget.dart';
import '../widget/buildDateTimePickerInFull.dart';
import '../widget/buildDropdownField.dart';
import '../widget/buildTextField.dart';

class AddTaskPage extends StatefulWidget {
  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  AddTaskModel addTaskModel = AddTaskModel();

  @override
  void initState() {
    super.initState();
    // 初始化Task為空
    GlobalManager.task = TaskModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'.tr()),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              buildTextField(
                  'Task Name'.tr(), (value) => GlobalManager.task.name = value,
                  initialValue: GlobalManager.task.name, validator: true),
              buildTextField(
                'Label'.tr(),
                (value) => GlobalManager.task.label = value,
                initialValue: GlobalManager.task.label,
              ),
              buildTextField(
                  'Category'.tr(),
                  initialValue: GlobalManager.task.category,
                  (value) => GlobalManager.task.category = value),
              buildTextField(
                  'Description'.tr(),
                  initialValue: GlobalManager.task.description,
                  (value) => GlobalManager.task.description = value,
                  isMultiline: true),
              buildDropdownField(
                  'Priority'.tr(),
                  ['Low', 'Medium', 'High'],
                  (value) => GlobalManager.task.priority = value!,
                  GlobalManager.task.priority),
              buildDateTimePickerInFull('Task Start Time'.tr(), (value) {
                setState(() {
                  GlobalManager.task.startTime = value;
                });
              }, GlobalManager.task.startTime, GlobalManager.task.endTime),
              buildDateTimePickerInFull('Task End Time'.tr(), (value) {
                setState(() {
                  GlobalManager.task.endTime = value;
                });
              }, GlobalManager.task.startTime, GlobalManager.task.endTime),
              const Divider(height: 20),
              Text(
                'Todos'.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...GlobalManager.task.todos!.map((todo) {
                return TodoForm(
                  key: ValueKey(todo.todoID),
                  todo: todo,
                  onDelete: () {
                    setState(() {
                      GlobalManager.task.todos?.remove(todo);
                    });
                  },
                );
              }).toList(),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    print("------------TODO-----------------");
                    GlobalManager.task.todos?.add(Todo());
                  });
                },
                icon: Icon(Icons.add),
                label: Text('Add Todo'.tr()),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    try {
                      TaskModel task = GlobalManager.task;
                      task.taskId = "task_" + Uuid().v4().toString();

                      // 任务名称检查
                      final istask =
                          await TaskDao().selectTaskByTaskName(task.name!);
                      if (istask != null) {
                        // 已存在相同任务名
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("this task name is exist!".tr())));
                      } else {
                        // 不存在
                        print("------------Task------------------");
                        print(task.toString());
                        // Add code to save task to database
                        for (Todo item in GlobalManager.task.todos!) {
                          // 1. 格式转化
                          Map todoMap = item.toMap();
                          // 2. 增加
                          addTaskModel.addTodo(todoMap);
                        }

                        // 写入数据库中
                        addTaskModel.insertDataToDatabase(task);

                        // 创建
                        Map result = await addTaskModel.createTask(
                            taskID: GlobalManager.task.taskId,
                            taskName: GlobalManager.task.name);
                        print("result:${result}");
                        // 提示
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(result["msg"].toString().tr())));
                      }
                    } catch (e) {
                      // 失败
                      print(
                          "create task failure, more detail: ${e.toString()}");
                      // 提示
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Task Added failure!'.tr())));
                    }
                  }
                },
                child: Text('Submit'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
