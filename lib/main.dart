import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/config/firebase_config.dart';
import 'core/providers/theme_provider.dart';

// auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/presentation/providers/auth_notifier.dart';

// inventory
import 'features/inventory/data/datasources/inventory_firestore_datasource.dart';
import 'features/inventory/data/repositories/inventory_repository_impl.dart';
import 'features/inventory/domain/usecases/checkout_usecase.dart';
import 'features/inventory/domain/usecases/create_product_usecase.dart';
import 'features/inventory/domain/usecases/delete_product_and_logs_usecase.dart';
import 'features/inventory/domain/usecases/get_product_detail_usecase.dart';
import 'features/inventory/domain/usecases/get_product_logs_usecase.dart';
import 'features/inventory/domain/usecases/get_products_usecase.dart';
import 'features/inventory/domain/usecases/return_usecase.dart';
import 'features/inventory/domain/usecases/search_products_usecase.dart';
import 'features/inventory/domain/usecases/update_product_usecase.dart';
import 'features/inventory/presentation/providers/inventory_list_notifier.dart';
import 'features/inventory/presentation/providers/product_editor_notifier.dart';
import 'features/inventory/presentation/providers/product_usage_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseConfig.initialize();

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final authRemoteDataSource = AuthRemoteDataSource(
    firebaseAuth: firebaseAuth,
    firestore: firestore,
  );
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);
  final loginUseCase = LoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);

  final inventoryDataSource = InventoryFirestoreDataSource(firestore);
  final inventoryRepository = InventoryRepositoryImpl(inventoryDataSource);

  final searchProductsUseCase = SearchProductsUseCase();
  final getProductsUseCase = GetProductsUseCase(inventoryRepository);
  final getProductDetailUseCase = GetProductDetailUseCase(inventoryRepository);
  final createProductUseCase = CreateProductUseCase(inventoryRepository);
  final updateProductUseCase = UpdateProductUseCase(inventoryRepository);
  final deleteProductAndLogsUseCase =
  DeleteProductAndLogsUseCase(inventoryRepository);
  final checkoutUseCase = CheckoutUseCase(inventoryRepository);
  final returnUseCase = ReturnUseCase(inventoryRepository);
  final getProductLogsUseCase = GetProductLogsUseCase(inventoryRepository);

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
          )..init(),
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
      child: const MyApp(),
    ),
  );
}