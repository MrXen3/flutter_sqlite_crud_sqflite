import 'package:flutter/material.dart';
import 'package:sqlite_crud/db/database_helper.dart';
import 'package:sqlite_crud/ui/widgets/button.dart';
import 'package:url_launcher/url_launcher.dart';

const darkBlueColor = Color.fromARGB(255, 34, 35, 36);

class SecondRoute extends StatefulWidget {
  const SecondRoute({Key? key}) : super(key: key);

  @override
  State<SecondRoute> createState() => _SecondRoute();
}

class _SecondRoute extends State<SecondRoute> {
  @override
  initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
  }

  List<dynamic> _contacts = [];
  String? _searchString;
  bool isVisible = false;
  bool isEmpty = false;

  static late DatabaseHelper _dbHelper;
  static final _formKey1 = GlobalKey<FormState>();
  static final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ThemeData(
      primaryColor: darkBlueColor,
    );
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: darkBlueColor,
        title: const Text('Search For Contacts'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              child: Form(
                key: _formKey1,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _searchCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Search By Name'),
                      validator: (val) =>
                          (val!.length == 0 ? 'This Field is Required' : null),
                      onSaved: (val) => setState(() => _searchString = val),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10.0),
                      child: MyButton(
                        label: 'Submit',
                        onTap: () {
                          _search();
                          // isVisible = !isVisible;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Visibility(
              visible: isVisible,
              child: _onSearch(),
            ),
            Visibility(
              child: _emptyCard(),
              visible: isEmpty,
            ),
          ],
        ),
      ),
    );
  }

  _emptyCard() {
    return const Center(
      
      child: ListTile(
                leading: Icon(Icons.not_interested),
                title: Text('Empty Search'),
                subtitle: Text('no Contacts Found'),
              ),
    );
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: <Widget>[
            //     TextButton(
            //       child: const Text('BUY TICKETS'),
            //       onPressed: () {/* ... */},
            //     ),
            //     const SizedBox(width: 8),
            //     TextButton(
            //       child: const Text('LISTEN'),
            //       onPressed: () {/* ... */},
            //     ),
            //     const SizedBox(width: 8),
            //   ],
            // );
  }

  _onSearch() {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.account_circle,
                      color: darkBlueColor, size: 40.0),
                  title: Text(
                    (_contacts[index].name!),
                    style: const TextStyle(
                        color: darkBlueColor, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_contacts[index].mobile!),
                  trailing: IconButton(
                      onPressed: () {
                        launch('tel: ${_contacts[index].mobile!}');
                      },
                      icon: const Icon(Icons.call_outlined,
                          color: darkBlueColor)),
                  onTap: () {
                    launch('tel: ${_contacts[index].mobile!}');
                  },
                ),
                const Divider(
                  height: 5.0,
                )
              ],
            );
          },
          itemCount: _contacts.length,
        ),
      ),
    );
  }

  void _search() async {
    var form1 = _formKey1.currentState;
    if (form1!.validate()) {
      form1.save();
      List<dynamic> x = await _dbHelper.getContact(_searchString!);
      if (x.isNotEmpty) {
        isVisible = true;
        isEmpty=false;
        
        setState(() {
          _contacts = x;
          _formKey1.currentState?.reset();
          _searchCtrl.clear();
        });
      }
      else{
        isEmpty=true;
      }
    }
  }
}
