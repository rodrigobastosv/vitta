import 'package:vitta/app/data/body_profile/body_profile_repository.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';

class SaveBodyProfileUseCase {
  SaveBodyProfileUseCase({required this._bodyProfileRepository});

  final BodyProfileRepository _bodyProfileRepository;

  Future<void> call(BodyProfile profile) => _bodyProfileRepository.saveProfile(profile);
}
