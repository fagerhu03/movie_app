import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movie_app/screens/auth_screen/forget_password_screen.dart';
import 'package:movie_app/screens/auth_screen/login_screen.dart';
import 'package:movie_app/screens/auth_screen/register_screen.dart';
import 'package:movie_app/screens/home_screen/home_screen.dart';
import 'package:movie_app/screens/home_screen/tabs/home_tab.dart';
import 'package:movie_app/screens/into_screen/intro.dart';
import 'package:movie_app/screens/into_screen/onboarding_screen/onboarding_1.dart';
import 'package:movie_app/screens/into_screen/onboarding_screen/onboarding_2.dart';
import 'package:movie_app/screens/into_screen/onboarding_screen/onboarding_3.dart';
import 'package:movie_app/screens/into_screen/onboarding_screen/onboarding_4.dart';
import 'package:movie_app/screens/into_screen/onboarding_screen/onboarding_5.dart';
import 'package:movie_app/screens/movie_details/movie_details_screen.dart';
import 'bootstrap.dart';
import 'core/theme/theme.dart';

void main () async{
  WidgetsFlutterBinding.ensureInitialized();
await bootstrapFirebase();
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: HomeScreen.routeName,
        routes: {
          //intro
          IntroScreen.routeName: (_) => IntroScreen(),
          Onboarding1.routeName: (_) => Onboarding1(),
          Onboarding2.routeName: (_) => Onboarding2(),
          Onboarding3.routeName: (_) => Onboarding3(),
          Onboarding4.routeName: (_) => Onboarding4(),
          Onboarding5.routeName: (_) => Onboarding5(),

          //auth
          LoginScreen.routeName: (_) => LoginScreen(),
          ForgotPasswordScreen.routeName: (_) => ForgotPasswordScreen(),
          RegisterScreen.routeName: (_) => RegisterScreen(),

          //home
          HomeScreen.routeName: (_) => HomeScreen(),
          MovieDetailsScreen.routeName: (ctx) {
            final id = ModalRoute.of(ctx)!.settings.arguments as int;
            return MovieDetailsScreen(movieId: id);},
          //tabs
          HomeTab.routeName: (_) => HomeTab(),

        },
        theme: AppTheme.dark(),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (_, s) {
            if (s.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            return s.data == null ? LoginScreen() : const HomeScreen();
          },
        ),
      ),
    );
  }
}
