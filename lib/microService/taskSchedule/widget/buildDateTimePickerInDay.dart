import 'package:app_template/manager/GlobalManager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Widget buildDateTimePickerInDay(
  String label,
  ValueChanged<DateTime?> onSaved, {
  required DateTime? startTime,
  required DateTime? endTime,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        ElevatedButton(
          onPressed: () async {
            DateTime? selectedDate = await showDatePicker(
              context: GlobalManager.context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (selectedDate != null) {
              TimeOfDay? selectedTime = await showTimePicker(
                context: GlobalManager.context,
                initialTime: TimeOfDay.now(),
              );
              if (selectedTime != null) {
                final dateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                onSaved(dateTime);
              }
            }
          },
          child: Text(label),
        ),
        SizedBox(width: 10),
        if (label.contains('Start'.tr()))
          Text(startTime != null
              ? startTime!.toLocal().toString()
              : 'No time selected'.tr()),
        if (label.contains('End'.tr()))
          Text(endTime != null
              ? endTime!.toLocal().toString()
              : 'No time selected'.tr()),
      ],
    ),
  );
}
