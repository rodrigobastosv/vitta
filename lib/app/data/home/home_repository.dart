import 'package:vitta/app/data/home/home_layout_local_datasource.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';

class HomeRepository {
  HomeRepository({required this._homeLayoutLocalDataSource});

  final HomeLayoutLocalDataSource _homeLayoutLocalDataSource;

  HomeLayout getHomeLayout() => _homeLayoutLocalDataSource.getHomeLayout();

  Future<void> saveHomeLayout(HomeLayout layout) => _homeLayoutLocalDataSource.saveHomeLayout(layout);
}
