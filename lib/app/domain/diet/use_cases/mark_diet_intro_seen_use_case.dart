import 'package:vitta/app/data/diet/diet_repository.dart';

class MarkDietIntroSeenUseCase {
  MarkDietIntroSeenUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  Future<void> call() => _dietRepository.markIntroSeen();
}
