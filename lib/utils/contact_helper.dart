import 'dart:typed_data';

import 'package:flutter/material.dart';

class ContactHelper {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  Uint8List _photo = Uint8List(0);
}
