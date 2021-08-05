import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: 0.5)
  ),
  focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.pink, width: 2.0)
  ),
  // focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.pink[300], width: 2.0)),
);

