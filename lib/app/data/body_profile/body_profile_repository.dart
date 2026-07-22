import 'package:vitta/app/data/body_profile/body_profile_local_datasource.dart';
import 'package:vitta/app/domain/body_profile/entities/body_profile.dart';

class BodyProfileRepository {
  BodyProfileRepository({required this._bodyProfileLocalDataSource});

  final BodyProfileLocalDataSource _bodyProfileLocalDataSource;

  BodyProfile getProfile() => _bodyProfileLocalDataSource.getProfile();

  Future<void> saveProfile(BodyProfile profile) => _bodyProfileLocalDataSource.saveProfile(profile);
}
