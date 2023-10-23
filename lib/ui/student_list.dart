import 'dart:async';

import 'package:flutter/material.dart';
import '../model/student.dart';
import '../repositories/student_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StudentList extends StatefulWidget {
  final StudentRepository repository;

  const StudentList({Key? key, required this.repository}) : super(key: key);

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  late Future<List<Student>> studentsFuture;
  late List<Student> students;
  bool isToggle = false;
  final StreamController<String> _streamController =
      StreamController.broadcast();
  late final _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _streamController.stream.listen((data) {
      print(data);
    });
    studentsFuture = widget.repository.getAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actionsIconTheme: IconThemeData(
            color: !isToggle ? Colors.white : Colors.green[300],
            size: 50,
          ),
          actions: [
            IconButton(
              tooltip: 'Internet data ON/OFF',
              onPressed: () {
                setState(() {
                  isToggle = !isToggle;
                });
              },
              icon: !isToggle
                  ? const Icon(Icons.toggle_off)
                  : const Icon(Icons.toggle_on),
            ),
          ],
          title: const Text('Список студентов'),
          bottom: TabBar(tabs: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.people, size: 40),
                Text(' List'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.star, size: 40),
                Text(' Activist'),
              ],
            ),
          ]),
        ),
        body: FutureBuilder<List<Student>>(
          future: studentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else {
              students = snapshot.data!;
              return TabBarView(children: [
                showStudents(students),
                showStudents(
                  students.where((student) => student.isActivist).toList(),
                ),
              ]);
            }
          },
        ),
      ),
    );
  }

  Widget showStudents(List<Student> students) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        return ListTile(
          key: ValueKey(students[index].name),
          // leading: !isToggle
          //     ? Image.asset('assets/images/nophoto.jpg')
          //     : Image.network(students[index].imageUrl),
          leading: Image.network(students[index].imageUrl),

          // leading: CachedNetworkImage(
          //   fit: BoxFit.cover,
          //   height: 50,
          //   width: 50,
          //   imageUrl: students[index].imageUrl,
          //   placeholder: (context, url) => const CircularProgressIndicator(),
          //   errorWidget: (context, url, error) => const Icon(Icons.error),
          // ),cl
          title: Text(students[index].name),
          subtitle: Text('Средний балл: ${students[index].averageScore}'),
          trailing: IconButton(
            icon: Icon(
                students[index].isActivist ? Icons.star : Icons.star_border),
            iconSize: 30,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: ((context) {
                  return SizedBox(
                    height: 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                              'Вы уверены что хотите изменить статус студента?'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await widget.repository
                                      .toggleActivistStatus(students[index]);
                                  setState(() {});
                                },
                                child: const Text('Yes'),
                              ),
                              const SizedBox(
                                width: 50,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('No'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        );
      },
    );
  }
}
