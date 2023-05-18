import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/sql_helper.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Map<String, dynamic>> _contactList = [];

// ignore: unused_field
  bool _isLoading = true;

  void _refreshContacts() async {
    // get the contacts
    final data = await SQLHelper.getItemsSorted('name', 'ASC');
    setState(() {
      _contactList = data;
      _isLoading = false;
    });
  }

  // update memory image
  void _updateMemoryImage(Uint8List bytes) {
    setState(() {
      _photo = bytes;
    });
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  Uint8List _photo = Uint8List(0);

  Future<void> _updateContact(int id) async {
    // update the contact
    await SQLHelper.updateItem(
      id,
      _nameController.text,
      _phoneController.text,
      _emailController.text,
      _addressController.text,
      base64Encode(_photo),
    );
  }

  Future<void> _createContact() async {
    // create the contact
    await SQLHelper.createItem(
      _nameController.text,
      _phoneController.text,
      _emailController.text,
      _addressController.text,
      base64Encode(_photo),
    );
  }

  Future<void> _deleteContact(int id) async {
    // delete the contact
    await SQLHelper.deleteItem(id);
  }

  Future<void> _searchContact(String keyword) async {
    // search the contact
    await SQLHelper.searchItems(keyword);
  }

  @override
  void initState() {
    super.initState();
    _refreshContacts();
    debugPrint(
        "Number of items at start: ${_contactList.length}"); // Check the number of items in the list at the start
  }

  Future<dynamic> _showDialogBox(int? id, int index) {
    if (id != null) {
      final existingContactList =
          _contactList.firstWhere((element) => element['id'] == id);
      _nameController.text = existingContactList['name'];
      _phoneController.text = existingContactList['phone'];
      _emailController.text = existingContactList['email'];
      _addressController.text = existingContactList['address'];
      _photo = base64Decode(existingContactList['photo']);
    } else {
      _nameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _addressController.clear();
      _photo = Uint8List(0);
    }

    return showDialog(
      context: context,
      builder: (context) {
        // this rebuilds the dialog box with the new data
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            Uint8List photo = _photo;
            return AlertDialog(
                title: Text(id != null
                    ? _contactList[index]['name']
                    : 'Add New Contact'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          photo.isNotEmpty
                              ? CircleAvatar(
                                  // circle image of the contact
                                  radius: 40,
                                  backgroundImage: MemoryImage(photo),
                                )
                              : CircleAvatar(
                                  radius: 40,
                                  child: Text(id != null
                                      ? _contactList[index]['name'][0]
                                      : ''),
                                ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  final pickedFile =
                                      await ImagePicker().pickImage(
                                    source: ImageSource.gallery,
                                  );
                                  if (pickedFile != null) {
                                    photo = await File(pickedFile.path)
                                        .readAsBytes();
                                    setState(() {
                                      _photo = photo;
                                      debugPrint('State update Triggered');
                                    });
                                  }
                                },
                                child: const Text('Change Photo'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _photo = Uint8List(0);
                                  });
                                },
                                child: const Text('Remove Photo'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                      ),
                      TextField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                        ),
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (id != null) {
                        _updateContact(id);
                      } else {
                        _createContact();
                      }
                      _refreshContacts();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  ),
                ]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List Screen'),
        actions: [
          IconButton(
            onPressed: () {
              _showDialogBox(null, 0);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                // SEARCH BAR NOT FUCTIONING, BACKSPACE DOES NOT WORK >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                // Fix the Search Bar and the Backspace >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: TextField(
                //     decoration: const InputDecoration(
                //       labelText: 'Search',
                //       prefixIcon: Icon(Icons.search),
                //       border: OutlineInputBorder(),
                //     ),
                //     onChanged: (value) {
                //       _searchContact(value);
                //       // build the list of contacts based on the search keyword
                //       setState(() {
                //         _contactList = _contactList;
                //       });
                //     },
                //   ),
                // ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _contactList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(_contactList[index]['name']),
                          subtitle: Text(_contactList[index]['phone']),
                          leading: CircleAvatarWidget(
                            contactList: _contactList,
                            index: index,
                            radius: 20,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteContact(_contactList[index]['id']);
                              _refreshContacts();
                            },
                          ),
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(_contactList[index]['name']),
                              content: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      child: CircleAvatarWidget(
                                        contactList: _contactList,
                                        index: index,
                                        radius: 40,
                                      ),
                                    ),
                                    const Divider(),
                                    ContactDetailsWidget(
                                        contactList: _contactList,
                                        index: index),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    _showDialogBox(
                                        _contactList[index]['id'], index);
                                  },
                                  child: const Text('Edit'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class CircleAvatarWidget extends StatelessWidget {
  const CircleAvatarWidget({
    super.key,
    required List<Map<String, dynamic>> contactList,
    required this.index,
    required this.radius,
  }) : _contactList = contactList;

  // get radius from the parent widget
  final double radius;

  final int index;

  final List<Map<String, dynamic>> _contactList;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      // if radius is not set, the default value is 20
      radius: radius,
      backgroundImage: _contactList[index]['photo'] == ""
          ? null
          : MemoryImage(base64Decode(_contactList[index]['photo'])),
      child: _contactList[index]['photo'] == ""
          ? Text(_contactList[index]['name'][0])
          : null,
    );
  }
}

class ContactDetailsWidget extends StatelessWidget {
  const ContactDetailsWidget({
    super.key,
    required List<Map<String, dynamic>> contactList,
    required this.index,
  }) : _contactList = contactList;

  final List<Map<String, dynamic>> _contactList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {
        0: const FlexColumnWidth(0.3),
        1: const FlexColumnWidth(0.7),
      },
      children: [
        TableRow(
          children: [
            const TableCell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text('Name:'),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(_contactList[index]['name']),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const TableCell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text('Phone:'),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(_contactList[index]['phone']),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const TableCell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text('Email:'),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(_contactList[index]['email']),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const TableCell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Text('Address:'),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(_contactList[index]['address']),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
