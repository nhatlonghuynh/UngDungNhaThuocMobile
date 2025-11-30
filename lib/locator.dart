import 'package:get_it/get_it.dart';
import 'package:nhathuoc_mobilee/api/productapi.dart';
import 'package:nhathuoc_mobilee/api/categoryapi.dart';
import 'package:nhathuoc_mobilee/service/productservice.dart';

final locator = GetIt.instance;

void setupLocator() {
  // 1. Repositories
  locator.registerLazySingleton<ProductRepository>(() => ProductRepository());
  locator.registerLazySingleton<DanhMucRepository>(() => DanhMucRepository());

  // 2. Services
  // Inject Repository vào Service
  locator.registerLazySingleton<ProductService>(
    () => ProductService(repo: locator<ProductRepository>()),
  );
}
