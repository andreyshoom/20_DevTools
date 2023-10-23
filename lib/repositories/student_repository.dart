import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../model/student.dart';

abstract class StudentRepository {
  Future<List<Student>> getAllStudents();
  Future<void> toggleActivistStatus(Student student);
}

class StudentRepositoryImpl implements StudentRepository {
  List<Student> students = [];

  Future<String> readFromFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/students.json');

    if (!await file.exists()) {
      return await rootBundle.loadString('assets/students.json');
    }
    return file.readAsString();
  }

  Future<void> writeToFile(String jsonString) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/students.json');

    try {
      await file.writeAsString(jsonString, mode: FileMode.write);
    } catch (e) {
      print("Error writing to file: $e");
    }
  }

  @override
  Future<List<Student>> getAllStudents() async {
    if (students.isEmpty) {
      String jsonString = await readFromFile();
      List<dynamic> jsonResponse = json.decode(jsonString);
      students = jsonResponse.map((student) {
        return Student(
          student['name'],
          student['averageScore'].toDouble(),
          student['isActivist'],
          student['imageUrl'],
        );
      }).toList();
    }
    return students;
  }

  @override
  Future<void> toggleActivistStatus(Student student) async {
    int index = students.indexWhere((s) => s.name == student.name);
    if (index != -1) {
      students[index].isActivist = !students[index].isActivist;

      Map<String, dynamic> updateStudent = {
        'name': students[index].name,
        'averageScore': students[index].averageScore,
        'isActivist': students[index].isActivist,
        'imageUrl': students[index].imageUrl,
      };

      String currentData = await readFromFile();
      List<dynamic> currentStudents = json.decode(currentData);
      currentStudents[index] = updateStudent;

      String jsonString = json.encode(currentStudents);
      await writeToFile(jsonString);
    } else {
      print("Student not found!");
    }
  }

  // Old function before perfomance optimization

  // @override
  // Future<void> toggleActivistStatus(Student student) async {
  //   int index = students.indexWhere((s) => s.name == student.name);
  //   if (index != -1) {
  //     students[index].isActivist = !students[index].isActivist;
  //     List<Map<String, dynamic>> jsonStudents = students.map((student) {
  //       return {
  //         'name': student.name,
  //         'averageScore': student.averageScore,
  //         'isActivist': student.isActivist,
  //         'imageUrl': student.imageUrl,
  //       };
  //     }).toList();

  //     String jsonString = json.encode(jsonStudents);
  //     await writeToFile(jsonString);
  //   } else {
  //     print("Student not found!");
  //   }
  // }
}
