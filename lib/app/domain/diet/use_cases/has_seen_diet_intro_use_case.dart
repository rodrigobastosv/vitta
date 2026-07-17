import 'package:vitta/app/data/diet/diet_repository.dart';

class HasSeenDietIntroUseCase {
  HasSeenDietIntroUseCase({required this._dietRepository});

  final DietRepository _dietRepository;

  bool call() => _dietRepository.hasSeenIntro();
}
