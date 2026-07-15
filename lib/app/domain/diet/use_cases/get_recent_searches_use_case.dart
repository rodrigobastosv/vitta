import 'package:vitta/app/data/diet/diet_repository.dart';

class GetRecentSearchesUseCase {
  GetRecentSearchesUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  List<String> call() => _dietRepository.getRecentSearches();
}
