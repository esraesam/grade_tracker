import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grade_tracker/ViewModel/PdfViewModel.dart';
import 'package:provider/provider.dart';
import 'package:grade_tracker/Utils/navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => UploadPdfViewModel(), // Provide your ViewModel here
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
      home:
          NavigationScreen(), // Or any other initial screen you want to display
    );
  }
}
