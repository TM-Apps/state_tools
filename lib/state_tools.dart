// A light and simple State Manager for Flutter Apps.
// ignore: unnecessary_library_name
library state_tools;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:hive_ce/hive.dart';
// ignore: implementation_imports
import 'package:hive_ce/src/hive_impl.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

part 'src/state_cipher.dart';
part 'src/state_notifier.dart';
part 'src/state_storage.dart';
part 'src/state_utils.dart';
part 'src/state_widgets.dart';
