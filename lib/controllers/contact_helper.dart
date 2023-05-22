import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'sql_helper.dart';

class ContactHelper {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  Uint8List _photo = Uint8List(0);

  TextEditingController get nameController => _nameController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get emailController => _emailController;
  TextEditingController get addressController => _addressController;
  Uint8List get photo => _photo;

  set photo(Uint8List value) {
    _photo = value;
  }

  void clearControllers() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _photo = Uint8List(0);
  }

  Future<void> updateContact(int id) async {
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
}
