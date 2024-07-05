import 'package:app_template/manager/GlobalManager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../common/Todo.dart';
import '../widget/buildDateTimePickerInDay.dart';
import '../widget/buildTextField.dart';

class TodoForm extends StatefulWidget {
  final Todo todo;
  final VoidCallback onDelete;

  TodoForm({required this.todo, required this.onDelete, Key? key})
      : super(key: key);

  @override
  _TodoFormState createState() => _TodoFormState(todo);
}

class _TodoFormState extends State<TodoForm> {
  late int index;
  Todo todo;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  _TodoFormState(this.todo);

  @override
  void initState() {
    super.initState();

    // 获取index
    index = GlobalManager.task.todos!.indexOf(todo);
    //
    _nameController.text = widget.todo.name ?? '';
    _descriptionController.text = widget.todo.description ?? '';
    _durationController.text = widget.todo.duration ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildTextField(
                'Name'.tr(),
                initialValue: GlobalManager.task.todos?[index].name,
                (value) => GlobalManager.task.todos?[index].name = value,
                validator: true),
            buildTextField(
                'Description'.tr(),
                initialValue: GlobalManager.task.todos?[index].description,
                (value) => GlobalManager.task.todos?[index].description = value,
                isMultiline: true),
            buildTextField(
              'Duration'.tr(),
              initialValue: GlobalManager.task.todos?[index].duration,
              (value) => GlobalManager.task.todos?[index].duration = value,
            ),
            buildDateTimePickerInDay(
              'Select Start Time'.tr(),
              (value) {
                setState(() {
                  GlobalManager.task.todos?[index].startTime = value;
                });
              },
              startTime: GlobalManager.task.todos?[index].startTime,
              endTime: GlobalManager.task.todos?[index].endTime,
            ),
            buildDateTimePickerInDay('Select End Time'.tr(), (value) {
              setState(() {
                GlobalManager.task.todos?[index].endTime = value;
              });
            },
                startTime: GlobalManager.task.todos?[index].startTime,
                endTime: GlobalManager.task.todos?[index].endTime),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: widget.onDelete,
              child: Text('Delete Todo'.tr()),
              style: ElevatedButton.styleFrom(primary: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
