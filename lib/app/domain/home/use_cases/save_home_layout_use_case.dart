import 'package:vitta/app/data/home/home_repository.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';

class SaveHomeLayoutUseCase {
  SaveHomeLayoutUseCase({required this._homeRepository});

  final HomeRepository _homeRepository;

  Future<void> call({required HomeLayout layout}) => _homeRepository.saveHomeLayout(layout);
}
