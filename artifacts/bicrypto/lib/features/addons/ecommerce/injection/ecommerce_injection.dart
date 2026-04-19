import 'package:get_it/get_it.dart';
import '../data/datasources/ecommerce_remote_data_source.dart';
import '../data/datasources/ecommerce_local_datasource.dart';
import '../data/repositories/ecommerce_repository_impl.dart';
import '../domain/repositories/ecommerce_repository.dart';
import '../domain/usecases/get_categories_usecase.dart';
import '../domain/usecases/get_products_usecase.dart';
import '../presentation/bloc/shop/shop_bloc.dart';

final sl = GetIt.instance;

void initEcommerceDependencies() {
  // Data sources
  sl.registerLazySingleton<EcommerceRemoteDataSource>(
    () => EcommerceRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<EcommerceLocalDataSource>(
    () => EcommerceLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<EcommerceRepository>(
    () => EcommerceRepositoryImpl(sl(), sl(), sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => ShopBloc(sl(), sl()));
}
