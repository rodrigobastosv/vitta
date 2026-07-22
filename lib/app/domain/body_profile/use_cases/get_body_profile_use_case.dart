import 'package:vitta/app/data/body_profile/body_profile_repository.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';

class GetBodyProfileUseCase {
  GetBodyProfileUseCase({required this._bodyProfileRepository});

  final BodyProfileRepository _bodyProfileRepository;

  BodyProfile call() => _bodyProfileRepository.getProfile();
}
