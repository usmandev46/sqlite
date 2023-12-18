import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sizer/sizer.dart';
import 'package:sqflite/sqflite.dart';
import 'package:untitled/createTableNameScreen.dart';
import 'package:untitled/databaseHelper.dart';
import 'package:untitled/getColumnInfoScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (BuildContext context, Orientation orientation,
          DeviceType deviceType) {
        return GetMaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String title = 'Flutter Demo Home Page';

  var _tableName = TextEditingController();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late Future<List<String>> _alltableNames;

  @override
  void initState() {
    super.initState();
    _alltableNames = _databaseHelper.getAllTableNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: 80.h,
                  child: FutureBuilder<List<String>>(
                    future: _alltableNames,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No Tables found.'));
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                Get.to(() => GetColumnInfoScreen(
                                    tableName: snapshot.data![index]));
                              },
                              title: Text(
                                snapshot.data![index],
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  await _databaseHelper
                                      .deleteTable(snapshot.data![index]);
                                  setState(() {
                                    _alltableNames =
                                        _databaseHelper.getAllTableNames();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Table ${snapshot.data![index]} deleted successfully.'),
                                    ),
                                  );
                                },
                                icon: Icon(Icons.delete_outline),
                              ),
                            );
                          },
                        );
                      }
                    },
                  )),
              TextButton(
                  onPressed: () {
                    Get.to(() => CreateTableNameScreen());
                  },
                  child: Text('+  Add Table Name'))
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
                    _tableName.text = ''
                  }
                : null;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Enter Table Name'),
              backgroundColor: Colors.red,
            ));
          }

          // await DatabaseHelper().open();

//           /// INsert Data in Sql
//           // await DatabaseHelper.instance.insertData('John Doe', 25);
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
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
