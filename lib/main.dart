import 'package:flutter/material.dart';
import 'package:sqliteproject/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'SQLITE',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _journals = [];
  List updatedData = [];


  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      debugPrint("_journals,$_journals");
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
      _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['first_name'];
      _descriptionController.text = existingJournal['last_name'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // this will prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Save new journal
                  if (id == null) {
                    await _addItem();
                  }

                  if (id != null) {
                    await _updateItem(id);
                  }

                  // Clear the text fields
                  _titleController.text = '';
                  _descriptionController.text = '';

                  // Close the bottom sheet
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    // await SQLHelper.createItem(
    //     _titleController.text, _descriptionController.text);
    await SQLHelper.fetchDataAndInsertIntoDatabase();
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem( data) async {
    for(var item in data){
      debugPrint("item $item");
      await SQLHelper.updateItem(
          item['id'], item['first_name'], item['last_name']);
    }

    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite Flutter Example'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: () async {
                    await _addItem();
                    setState(() {});
                  },
                  child: const Text('add items')),
              const SizedBox(height: 20),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: ListView.builder(
                              itemCount: _journals.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (e, index) {
                                return Column(
                                  children: [

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${_journals[index]['id']}. '),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.25,
                                          child: TextFormField(
                                            maxLines: 2,
                                            minLines: 1,
                                            keyboardType: TextInputType.url,
                                            onChanged: (newValue) {
                                              setState(() {
                                               _titleController.text = newValue;
                                              });

                                              // updatedData.add({'first_name':newValue,'id':_journals[index]['id'],'last_name':_journals[index]['last_name']});

                                            },

                                            onFieldSubmitted: (value){
                                              updatedData.add({'first_name':value,'id':_journals[index]['id'],'last_name':_journals[index]['last_name']});
                                              debugPrint('updatedData $updatedData');
                                            },

                                            initialValue: _journals[index]['first_name'],
                                            style: const TextStyle(fontSize: 12),
                                            decoration: const InputDecoration(
                                              isDense: true, // important line
                                              contentPadding: EdgeInsets.all(10),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black, width: 1.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black, width: 1.0)),
                                              border: InputBorder.none,
                                              label: Text('Name'),
                                              labelStyle: TextStyle(fontSize: 13),
                                              hintStyle: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.27,
                                          child: TextFormField(
                                            maxLines: 2,
                                            minLines: 1,
                                            keyboardType: TextInputType.url,
                                            onChanged: (value) {
                                              _descriptionController.text = value;
                                              // updateUserName(user['id'], firstNameController.text);
                                              // setState(() {});
                                            },
                                            onFieldSubmitted: (value){
                                              updatedData.add({'first_name':_journals[index]['first_name'],'id':_journals[index]['id'],'last_name':value});

                                              debugPrint('updatedData $updatedData');
                                            },

                                            initialValue: _journals[index]['last_name'],
                                            style: const TextStyle(fontSize: 12),
                                            decoration: const InputDecoration(
                                              isDense: true, // important line
                                              contentPadding: EdgeInsets.all(10),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black, width: 1.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black, width: 1.0)),
                                              border: InputBorder.none,
                                              label: Text('last'),
                                              labelStyle: TextStyle(fontSize: 13),
                                              hintText: "Web Address",
                                              hintStyle: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          child: TextFormField(
                                            maxLines: 2,
                                            minLines: 1,
                                            keyboardType: TextInputType.url,
                                            onChanged: (value) {
                                              // _journals[index]['email'] = value;
                                              // updateUserName(user['id'], firstNameController.text);
                                              // setState(() {});
                                            },
                                            initialValue: _journals[index]['email'],
                                            style: const TextStyle(fontSize: 12),
                                            decoration: const InputDecoration(
                                              isDense: true, // important line
                                              contentPadding: EdgeInsets.all(10),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black, width: 1.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.black, width: 1.0)),
                                              border: InputBorder.none,
                                              label: Text('last'),
                                              labelStyle: TextStyle(fontSize: 13),
                                              hintText: "Web Address",
                                              hintStyle: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }),
                        ),

              ElevatedButton(
                onPressed: () async {
                  _updateItem(updatedData);
                },
                child: const Text('Update User'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('SQL'),
  //     ),
  //     body: _isLoading
  //         ? const Center(
  //       child: CircularProgressIndicator(),
  //     )
  //         : ListView.builder(
  //       itemCount: _journals.length,
  //       itemBuilder: (context, index) => Card(
  //         color: Colors.orange[200],
  //         margin: const EdgeInsets.all(15),
  //         child: ListTile(
  //             title: Text(_journals[index]['first_name']),
  //             subtitle: Text(_journals[index]['last_name']),
  //             trailing: SizedBox(
  //               width: 100,
  //               child: Row(
  //                 children: [
  //                   IconButton(
  //                     icon: const Icon(Icons.edit),
  //                     onPressed: () => _showForm(_journals[index]['id']),
  //                   ),
  //                   IconButton(
  //                     icon: const Icon(Icons.delete),
  //                     onPressed: () =>
  //                         _deleteItem(_journals[index]['id']),
  //                   ),
  //                 ],
  //               ),
  //             )),
  //       ),
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       child: const Icon(Icons.add),
  //       onPressed: () => _showForm(null),
  //     ),
  //   );
  // }
}