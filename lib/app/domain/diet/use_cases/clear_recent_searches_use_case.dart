import 'package:vitta/app/data/diet/diet_repository.dart';

class ClearRecentSearchesUseCase {
  ClearRecentSearchesUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<List<String>> call() => _dietRepository.clearRecentSearches();
}
