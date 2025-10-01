import 'package:flutter/material.dart';
import 'package:hospital_frontend/models/doctor.dart';
import 'package:provider/provider.dart';

import 'config/router.dart';
import 'providers/auth_provider.dart';
import 'providers/doctor_list_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/doctor_panel_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthProvider _authProvider;
  late AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _appRouter = AppRouter(authProvider: _authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => DoctorListProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => DoctorPanelProvider()),
      ],
      child: MaterialApp.router(
        routerConfig: _appRouter.router,
        title: 'Hospital App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            )
          )
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

