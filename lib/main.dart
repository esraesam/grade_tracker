import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grade_tracker/ViewModel/StudentSearchViewModel.dart';
import 'package:grade_tracker/ViewModel/pdf_uploader_viewmodel.dart';
import 'package:grade_tracker/test.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              StudentSearchViewModel(), // Provide your ViewModel here
        ),
        ChangeNotifierProvider(
          create: (_) => PDFUploaderViewModel(), // Provide your ViewModel here
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      home: PDFUploaderPage(), // Set the initial screen to PDFUploaderPage
    );
  }
}
