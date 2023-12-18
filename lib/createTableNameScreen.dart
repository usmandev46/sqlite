import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled/main.dart';

import 'databaseHelper.dart';

class CreateTableNameScreen extends StatefulWidget {
  const CreateTableNameScreen({super.key});

  @override
  State<CreateTableNameScreen> createState() => _CreateTableNameScreenState();
}

class _CreateTableNameScreenState extends State<CreateTableNameScreen> {
  var _tableName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Table Name"),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                  controller: _tableName,
                  decoration: const InputDecoration(labelText: 'Table Name')),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_tableName.text.isNotEmpty) {
            var dbHelp = DatabaseHelper.instance;
            bool res = await dbHelp.createTable(
              _tableName.text,
            );

            res
                ? {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Table ${_tableName.text} Successfully Created'),
                      backgroundColor: Colors.green,
                    )),
                    _tableName.text = '',
                    Get.offAll(() => MyHomePage())
                  }
                : null;
          } else {
            // await DatabaseHelper.instance.insertData(tableName: 'student');
            List<Map<String, dynamic>> data =
                await DatabaseHelper.instance.fetchDatas('student');
            print('Fetched Data: ----- $data');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Enter Table Name'),
              backgroundColor: Colors.red,
            ));
          }

          // await DatabaseHelper().open();

//           /// INsert Data in Sql

//           // print('Data inserted into the database.');
//
//           /// updata data in Sql
//           await DatabaseHelper.instance.updateData(2,'Bilal',23);
//          /// Delete data in Sql
//           // await DatabaseHelper.instance.deleteData(4);
//
// /// Fetch data from Sql
//           List<Map<String, dynamic>> data = await DatabaseHelper.instance.fetchData();
//           print('Fetched Data: $data');

          final dataToInsert = {
            'column1': 'value1',
            'column2': 'value2',
            'column3': 'value3',
            'column4': 'value4',
          };
          final dataColumn = [
            'column1',
            'column2',
            'column3',
            'column4',
          ];

          // final dbHelper = DynamicDatabaseHelper.instance;

          // Create a table dynamically with columns
//           await dbHelper.createTable('bilal', dataColumn);
//           await dbHelper.insertData('bilal', dataToInsert);
//           // Close the database when done
//           // await dbHelper.close();
//
//           /// Fetch data from Sql
//           List<Map<String, dynamic>> data = await dbHelper.fetchData('bilal');
//           print('Fetched Data: $data');
        },
        tooltip: 'Increment',
        child: const Icon(Icons.save),
      ),
    );
  }
}
