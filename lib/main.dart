import 'package:flutter/material.dart';
import 'package:flutter_dev_tools/repositories/student_repository.dart';
import 'package:flutter_dev_tools/ui/student_list.dart';

void main() {
  runApp(
    MaterialApp(
      home: StudentList(repository: StudentRepositoryImpl()),
    ),
  );
}
