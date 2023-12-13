import 'package:amplify_api/amplify_api.dart';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/ModelProvider.dart';
import 'pages/home_page.dart';
import 'pages/todo_item_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const MyApp());
}

Future<void> _configureAmplify() async {
  try {
    final api = AmplifyAPI(modelProvider: ModelProvider.instance);

    await Amplify.addPlugins([api]);
    // TODO: Add the API details below
    const amplifyconfig = '''{
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "flutter_todo_app": {
                    "endpointType": "GraphQL",
                    "endpoint": "",
                    "region": "",
                    "authorizationType": "API_KEY",
                    "apiKey": ""
                }
            }
        }
    }
}''';
    await Amplify.configure(amplifyconfig);

    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // GoRouter configuration
  static final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/manage-todo-item',
        name: 'manage',
        builder: (context, state) => ToDoItemPage(
          todoItem: state.extra as Todo?,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return child!;
      },
    );
  }
}
