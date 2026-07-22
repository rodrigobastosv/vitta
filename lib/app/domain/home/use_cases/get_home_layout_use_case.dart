import 'package:vitta/app/data/home/home_repository.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';

class GetHomeLayoutUseCase {
  GetHomeLayoutUseCase({required this._homeRepository});

  final HomeRepository _homeRepository;

  HomeLayout call() => _homeRepository.getHomeLayout();
}
