import 'package:flutter/material.dart';
import 'package:movie_app/screens/into_screen/intro.dart';
import 'core/theme/theme.dart';


void main (){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: IntroScreen.routeName,
      routes: {
        IntroScreen.routeName: (_) => IntroScreen(),


      },
      theme: AppTheme.dark(),

    );
  }
}
