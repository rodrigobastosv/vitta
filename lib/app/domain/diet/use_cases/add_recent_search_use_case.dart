import 'package:vitta/app/data/diet/diet_repository.dart';

class AddRecentSearchUseCase {
  AddRecentSearchUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  /// Returns the updated list, so the caller doesn't have to re-read it to
  /// learn where the query landed after de-duplication and capping.
  Future<List<String>> call({required String query}) => _dietRepository.addRecentSearch(query: query);
}
