import 'package:flutter/material.dart';

import 'core/lumio_controller.dart';
import 'data/firebase_lumio_repository.dart';
import 'features/lumio_app.dart';

void main() {
  final repository = FirebaseLumioRepository();
  final controller = LumioController(repository: repository);
  runApp(LumioApp(controller: controller));
}
