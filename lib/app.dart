import 'package:flatirons_challenge/repository/upload_repository.dart';
import 'package:flatirons_challenge/ui/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/upload/upload_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => UploadRepository(),
      child: BlocProvider(
        create: (c) => UploadBloc(c.read<UploadRepository>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
          home: const HomePage(),
        ),
      ),
    );
  }
}