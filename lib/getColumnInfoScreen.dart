import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/databaseHelper.dart';
import 'package:untitled/userDataShow.dart';

class GetColumnInfoScreen extends StatefulWidget {
  GetColumnInfoScreen({super.key, required this.tableName});
  String tableName;
  @override
  State<GetColumnInfoScreen> createState() => _GetColumnInfoScreenState();
}

class _GetColumnInfoScreenState extends State<GetColumnInfoScreen> {
  List<Map<String, dynamic>> data = [];
  List<TextEditingController> controllers = [];
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> rows = {};
  @override
  void initState() {
    super.initState();
    oninitMethod();
  }

  oninitMethod() async {
    data = await DatabaseHelper.instance.fetchColumnsAndValues(tableName: widget.tableName);
    print('--------------- data is availiable ${data.length} ${data}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.tableName),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child:data.isEmpty?Container(
                height: 30.h,
                width: double.infinity,
                color: Colors.grey.withOpacity(0.2),
                child: Center(child: Text('No Data')),): ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Get.to(() => UserDataShow(
                        tableName: widget.tableName,
                            list: data));
                    },
                    title: Text(data[index]['Name'].toString()),
                  );
                },
              ),
            ),
            Expanded(
              child: FutureBuilder<List<String>>(
                future:
                    DatabaseHelper.instance.getColumnNames(widget.tableName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No columns found.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        controllers.add(TextEditingController());
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            // readOnly: index == 0 ? true : false,

                            controller: controllers[index],
                            onChanged: (value) {
                              // For example, if you want to ensure the field is not empty
                              if (value.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('All fields are required'),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.red),
                                );
                              } else {
                                print(
                                    '=============== value ${snapshot.data![index]} is ${controllers[index].text}');
                                rows.addAll({
                                  '${snapshot.data![index]}': '${controllers[index].text}'
                                });
                                // setState(() {
                                //
                                // });
                                print(
                                    '------------------------ value rows is ${rows}');
                              }
                              ;
                            },
                            decoration: InputDecoration(
                                labelText: snapshot.data![index],
                                suffixIcon: const Text('Text',
                                    style: TextStyle(color: Colors.grey))),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            TextButton(
                onPressed: () async {
                  setState(() {});
                  print('------------------------ value rows is ${rows}');
                  if (_formKey.currentState!.validate() == true) {
                    await DatabaseHelper.instance
                        .insertData(tableName: widget.tableName, rows: rows);
                    oninitMethod();
                    controllers.clear();
                    rows.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('All field are requird'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red),
                    );
                  }
                  // data = await DatabaseHelper.instance
                  //     .fetchColumnsAndValues(tableName: widget.tableName);
                },
                child: Text('Save')),
            Container(
              height: 5.h,
              child: TextButton(
                  onPressed: () async {
                    String? result = await showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          tableName: widget.tableName,
                        );
                      },
                    );

                    if (result != null) {
                      print('You typed: $result');
                      // Handle the result as needed
                      setState(() {
                        DatabaseHelper.instance
                            .getColumnNames(widget.tableName);
                      });
                    }
                  },
                  child: Text('+ Add Column')),
            )
          ],
        ),
      ),
    );
  }
}

class CustomDialog extends StatefulWidget {
  CustomDialog({Key? key, required this.tableName}) : super(key: key);
  String tableName;
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Column Name'),
      content: TextField(
        controller: _textFieldController,
        decoration: InputDecoration(hintText: 'Type something...'),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () async {
            await DatabaseHelper.instance
                .addColumnToTable(widget.tableName, _textFieldController.text, 'TEXT');

            Navigator.of(context).pop(_textFieldController.text);
          },
          child: Text('Save'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
