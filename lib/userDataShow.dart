import 'package:flutter/material.dart';

import 'databaseHelper.dart';

class UserDataShow extends StatefulWidget {
  UserDataShow({super.key, this.list, required this.tableName});
  var list;
  String tableName;

  @override
  State<UserDataShow> createState() => _UserDataShowState();
}

class _UserDataShowState extends State<UserDataShow> {
  var columnName;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    oninitMethod();
  }

  oninitMethod() async {
    columnName =
        await DatabaseHelper.instance.getColumnNamesIndex(widget.tableName);
    setState(() {});

    print('============================ column is ${columnName}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Details Show'),
      ),
      body: ListView.builder(
        itemCount: widget.list.length,
        itemBuilder: (context, index) {
          return buildCard(widget.list[index], columnName);
        },
      ),
    );
  }
}

Widget buildCard(Map<String, dynamic> data, var columnName) {
  return Card(
    margin: EdgeInsets.all(16),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Expanded(
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: columnName.length,
          itemBuilder: (BuildContext context, int index) {
            return Text(
                '${columnName[index]}: ${data['${columnName[index]}']}');
          },
        ),
      ),
    ),
  );
}
