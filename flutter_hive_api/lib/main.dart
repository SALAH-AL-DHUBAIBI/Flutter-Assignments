import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/task.dart';
import 'models/category.dart';
import 'controllers/theme_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/auth_controller.dart';
import 'helper/themes.dart';
import 'helper/translations.dart';
import 'helper/routes.dart';
import 'helper/app_pages.dart';
import 'helper/constants.dart';
import 'services/api/todo_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(CategoryAdapter());

  await Hive.openBox<Task>(AppConstants.boxTasks);
  await Hive.openBox<Category>(AppConstants.boxCategories);
  await Hive.openBox(AppConstants.boxSettings);

  // Sync todos from DummyJSON on startup
  try {
    final todoApi = TodoApi();
    final remoteTodos = await todoApi.fetchTodos(limit: 100);
    final tasksBox = Hive.box<Task>(AppConstants.boxTasks);
    // Replace local tasks with remote ones (simple sync)
    await tasksBox.clear();
    for (final t in remoteTodos) {
      tasksBox.put(t.id, t);
    }
    print('Synced ${remoteTodos.length} todos from DummyJSON');
  } catch (e) {
    print('Failed to sync todos: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ThemeController());
    Get.put(LocaleController());
    Get.put(AuthController());

    return Obx(() => GetMaterialApp(
          title: 'Todo App',
          debugShowCheckedModeBanner: false,
          theme: AppThemes.light,
          darkTheme: AppThemes.dark,
          themeMode: Get.find<ThemeController>().themeMode,
          translations: AppTranslations(),
          locale: Get.find<LocaleController>().locale.value,
          fallbackLocale: const Locale('en', 'US'),
          initialRoute: AppRoutes.SPLASH,
          getPages: AppPages.pages,
        ));
  }
}
