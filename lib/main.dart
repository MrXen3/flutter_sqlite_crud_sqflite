
import 'package:flutter/material.dart';
import 'package:sqlite_crud/models/contact.dart';
import 'package:sqlite_crud/db/database_helper.dart';
import 'package:sqlite_crud/ui/pages/SecondRoute.dart';
import 'package:sqlite_crud/ui/widgets/button.dart';

const darkBlueColor = Color.fromARGB(255, 34, 35, 36);
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phone Book',
      theme: ThemeData(
        primaryColor: darkBlueColor,
      ),
      home: const MyHomePage(title: 'Phone Book'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Contact _contact = Contact();
  List<Contact> _contacts = [];

  late DatabaseHelper _dbHelper;
  final _formKey = GlobalKey<FormState>();

  final _ctrlName = TextEditingController();
  final _ctrlMobile = TextEditingController();

  @override
  initState() {
    super.initState();
    setState(() {
      _dbHelper = DatabaseHelper.instance;
    });
    _refreshContactList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: darkBlueColor,
        title: Center(
            child: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _form(),
            _list(),
            // _search()
          ],
        ),
      ),
    );
  }

  _form() => Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _ctrlName,
                decoration: const InputDecoration(labelText: 'Full Name'),
                onSaved: (val) => setState(() => _contact.name = val),
                validator: (val) =>
                    (val?.length == 0 ? 'This Field is Required' : null),
              ),
              TextFormField(
                controller: _ctrlMobile,
                decoration: const InputDecoration(labelText: 'Mobile'),
                onSaved: (val) => setState(() => _contact.mobile = val),
                validator: (val) => (val!.length < 10
                    ? 'At Least 10 Charachters Required'
                    : null),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 MyButton(
                    label: 'Submit',
                    onTap: () {
                      _onSubmit();
                    },
                  ),
                  MyButton(
                    label: 'Search',
                    onTap: () {
                      _onSearch();
                    },
                  ),
                 ],
              ),
            ],
          ),
        ),
      );

  _onSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SecondRoute()),
    );
  }

  _refreshContactList() async {
    List<Contact> x = await _dbHelper.fetchContacts();
    setState(() {
      _contacts = x;
    });
  }

  void _onSubmit() async {
    var form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      if (_contact.id == null)
        await _dbHelper.insertContact(_contact);
      else
        await _dbHelper.updateContact(_contact);
      _refreshContactList();
      _resetForm();
    }
  }

  _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _ctrlName.clear();
      _ctrlMobile.clear();
      _contact.id = null;
    });
  }

  _list() => Expanded(
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
                      _contacts[index].name!.toUpperCase(),
                      style: const TextStyle(
                          color: darkBlueColor, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_contacts[index].mobile!),
                    trailing: IconButton(
                        onPressed: () async {
                          await _dbHelper.deleteContact(_contacts[index].id!);
                          _resetForm();
                          _refreshContactList();
                        },
                        icon: const Icon(Icons.delete_sweep,
                            color: darkBlueColor)),
                    onTap: () {
                      setState(() {
                        _contact = _contacts[index];
                        _ctrlName.text = _contacts[index].name!;
                        _ctrlMobile.text = _contacts[index].mobile!;
                      });
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
