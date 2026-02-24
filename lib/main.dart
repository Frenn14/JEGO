import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app.dart';
import 'core/config/firebase_config.dart';
import 'core/providers/theme_provider.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⚠️ 보안 주의:
  // firebase_config.dart 는 Git에 올리지 말고(.gitignore) 템플릿(example)로 관리 권장
  await FirebaseConfig.initialize();

  // Firebase singletons
  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // ===== Auth DI =====
  final authRemoteDataSource = AuthRemoteDataSource(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);
  final loginUseCase = LoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  // ===== Inventory DI =====
  final inventoryDs = InventoryFirestoreDataSource(firestore);
  final inventoryRepo = InventoryRepositoryImpl(inventoryDs);

  final searchProductsUseCase = SearchProductsUseCase();
  final getProductsUseCase = GetProductsUseCase(inventoryRepo);
  final getProductDetailUseCase = GetProductDetailUseCase(inventoryRepo);
  final createProductUseCase = CreateProductUseCase(inventoryRepo);
  final updateProductUseCase = UpdateProductUseCase(inventoryRepo);
  final deleteProductAndLogsUseCase = DeleteProductAndLogsUseCase(inventoryRepo);
  final checkoutUseCase = CheckoutUseCase(inventoryRepo);
  final returnUseCase = ReturnUseCase(inventoryRepo);
  final getProductLogsUseCase = GetProductLogsUseCase(inventoryRepo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),

        ChangeNotifierProvider<AuthNotifier>(
          create: (_) => AuthNotifier(
            loginUseCase: loginUseCase,
            logoutUseCase: logoutUseCase,
          )..init(), // ✅ 앱 시작 시 로그인 상태/role 로드
        ),

        ChangeNotifierProvider<InventoryListNotifier>(
          create: (_) => InventoryListNotifier(
            getProductsUseCase: getProductsUseCase,
            searchProductsUseCase: searchProductsUseCase,
          ),
        ),

        ChangeNotifierProvider<ProductEditorNotifier>(
          create: (_) => ProductEditorNotifier(
            getDetailUseCase: getProductDetailUseCase,
            createProductUseCase: createProductUseCase,
            updateProductUseCase: updateProductUseCase,
            deleteProductAndLogsUseCase: deleteProductAndLogsUseCase,
          ),
        ),

        ChangeNotifierProvider<ProductUsageNotifier>(
          create: (_) => ProductUsageNotifier(
            getDetailUseCase: getProductDetailUseCase,
            getLogsUseCase: getProductLogsUseCase,
            checkoutUseCase: checkoutUseCase,
            returnUseCase: returnUseCase,
          ),
        ),
      ],
      child: const App(),
    ),
  );
}