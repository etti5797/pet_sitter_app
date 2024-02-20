import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 201, 160, 106)),
        useMaterial3: true,
      ),
            home: HomePage(title: 'Flutter Demo Home Page'),
          );
        }
      }


      class HomePage extends StatelessWidget {
        const HomePage({Key? key, required this.title}) : super(key: key);

        final String title;

        @override
        Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
                title: const Text(
                  'Pet Sitter',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircleAvatar(
                    radius: 180,
                    backgroundImage: NetworkImage('https://cdn.pixabay.com/photo/2019/05/29/14/17/welsh-corgi-pembroke-4237630_1280.jpg'),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'This is a summary of the application. It does XYZ.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Login
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to Sign Up
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ),
          );
        }
      }
