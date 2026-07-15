import 'package:vitta/app/data/diet/diet_repository.dart';

class RemoveRecentSearchUseCase {
  RemoveRecentSearchUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<List<String>> call({required String query}) => _dietRepository.removeRecentSearch(query: query);
}
