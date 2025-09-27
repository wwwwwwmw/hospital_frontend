import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/router.dart';
import 'providers/auth_provider.dart';
import 'providers/doctor_provider.dart';

void main() {
  runApp(const MyApp());
}

// Chuyển MyApp thành StatefulWidget để quản lý state của router và provider
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Khai báo các đối tượng sẽ được tạo một lần duy nhất
  late AuthProvider _authProvider;
  late AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    // Tạo AuthProvider và AppRouter một lần duy nhất khi widget được khởi tạo
    _authProvider = AuthProvider()..tryAutoLogin();
    _appRouter = AppRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng MultiProvider để cung cấp các state cho toàn bộ ứng dụng
    return MultiProvider(
      providers: [
        // Dùng .value để cung cấp một instance đã tồn tại của AuthProvider
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
      ],
      // MaterialApp.router sẽ sử dụng router đã được tạo và không thay đổi
      child: MaterialApp.router(
        routerConfig: _appRouter.router,
        title: 'Hospital App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

