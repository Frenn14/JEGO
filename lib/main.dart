import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/config/firebase_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app.dart';

// inventory imports
import 'features/inventory/domain/usecases/search_products_usecase.dart';
import 'features/inventory/domain/usecases/get_products_usecase.dart';
import 'features/inventory/domain/usecases/get_product_detail_usecase.dart';
import 'features/inventory/domain/usecases/create_product_usecase.dart';
import 'features/inventory/domain/usecases/update_product_usecase.dart';
import 'features/inventory/domain/usecases/delete_product_and_logs_usecase.dart';
import 'features/inventory/domain/usecases/checkout_usecase.dart';
import 'features/inventory/domain/usecases/return_usecase.dart';
import 'features/inventory/domain/usecases/get_product_logs_usecase.dart';

import 'features/inventory/data/datasources/inventory_firestore_datasource.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';

import 'features/inventory/presentation/providers/inventory_list_notifier.dart';
import 'features/inventory/presentation/providers/product_editor_notifier.dart';
import 'features/inventory/presentation/providers/product_usage_notifier.dart';

// Auth DI imports
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // ✅ Auth: role(isAdmin)까지 읽어야 하므로 firestore 전달 가능한 구조로 맞추기
  final remoteDataSource = AuthRemoteDataSource(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );

  final authRepository = AuthRepositoryImpl(remoteDataSource);

  // inventory
  final ds = InventoryFirestoreDataSource(firestore);
  final repo = InventoryRepositoryImpl(ds);

  // usecases
  final loginUseCase = LoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  final searchProducts = SearchProductsUseCase();
  final getProducts = GetProductsUseCase(repo);
  final getDetail = GetProductDetailUseCase(repo);
  final createProduct = CreateProductUseCase(repo);
  final updateProduct = UpdateProductUseCase(repo);
  final deleteProductAndLogs = DeleteProductAndLogsUseCase(repo);
  final checkout = CheckoutUseCase(repo);
  final returnUc = ReturnUseCase(repo);
  final getLogs = GetProductLogsUseCase(repo);


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(
            loginUseCase: loginUseCase,
            logoutUseCase: logoutUseCase,
          )..init(), // ✅ 앱 시작 시 role 로드
        ),
        ChangeNotifierProvider(
          create: (_) => InventoryListNotifier(
            getProductsUseCase: getProducts,
            searchProductsUseCase: searchProducts,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductEditorNotifier(
            getDetailUseCase: getDetail,
            createProductUseCase: createProduct,
            updateProductUseCase: updateProduct,
            deleteProductAndLogsUseCase: deleteProductAndLogs,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductUsageNotifier(
            getDetailUseCase: getDetail,
            getLogsUseCase: getLogs,
            checkoutUseCase: checkout,
            returnUseCase: returnUc,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggle() {
    _themeMode =
    _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}