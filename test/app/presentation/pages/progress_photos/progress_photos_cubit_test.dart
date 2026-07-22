import 'dart:typed_data';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitta/app/core/error/result.dart';
import 'package:vitta/app/core/error/vt_error.dart';
import 'package:vitta/app/core/services/image_picker/image_picker_source.dart';
import 'package:vitta/app/core/services/image_picker/picked_image.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_cubit.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_presentation_event.dart';
import 'package:vitta/app/presentation/pages/progress_photos/progress_photos_state.dart';

import '../../../../factories/cubits_factories.dart';
import '../../../../factories/entities/progress_photo_factory.dart';
import '../../../../fixtures/logging_fixture.dart';
import '../../../../mocks/services_mocks.dart';
import '../../../../mocks/use_cases_mocks.dart';

MockGetProgressPhotosUseCase _photosUseCase(List<dynamic> photos) {
  final useCase = MockGetProgressPhotosUseCase();
  when(useCase.call).thenAnswer((_) async => Success(photos.cast()));
  return useCase;
}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(ImagePickerSource.camera);
  });

  blocTest<ProgressPhotosCubit, ProgressPhotosState>(
    'emits the photos when loadPhotos succeeds',
    build: () => CubitsFactories.buildProgressPhotosCubit(getProgressPhotosUseCase: _photosUseCase([ProgressPhotoFactory.build()])),
    act: (cubit) => cubit.loadPhotos(),
    expect: () => [isA<ProgressPhotosState>().having((state) => state.photos.length, 'photos', 1)],
  );

  blocPresentationTest<ProgressPhotosCubit, ProgressPhotosState, ProgressPhotosPresentationEvent>(
    'the first load shows no overlay - the skeleton covers it',
    build: () => CubitsFactories.buildProgressPhotosCubit(getProgressPhotosUseCase: _photosUseCase([])),
    act: (cubit) => cubit.loadPhotos(),
    expectPresentation: () => <ProgressPhotosPresentationEvent>[],
  );

  blocPresentationTest<ProgressPhotosCubit, ProgressPhotosState, ProgressPhotosPresentationEvent>(
    'emits ProgressPhotosError when loadPhotos fails',
    build: () {
      final getProgressPhotosUseCase = MockGetProgressPhotosUseCase();
      when(getProgressPhotosUseCase.call).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
      return CubitsFactories.buildProgressPhotosCubit(getProgressPhotosUseCase: getProgressPhotosUseCase);
    },
    act: (cubit) => cubit.loadPhotos(),
    expectPresentation: () => [isA<ProgressPhotosError>()],
  );

  blocPresentationTest<ProgressPhotosCubit, ProgressPhotosState, ProgressPhotosPresentationEvent>(
    'pickPhoto hands the picked image to the page',
    build: () {
      final imagePickerService = MockImagePickerService();
      when(
        () => imagePickerService.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
        ),
      ).thenAnswer((_) async => PickedImage(path: 'photo.jpg', bytes: Uint8List(3), fileExtension: 'jpg'));
      return CubitsFactories.buildProgressPhotosCubit(imagePickerService: imagePickerService);
    },
    act: (cubit) => cubit.pickPhoto(source: .camera),
    expectPresentation: () => [isA<ProgressPhotoPicked>()],
  );

  blocPresentationTest<ProgressPhotosCubit, ProgressPhotosState, ProgressPhotosPresentationEvent>(
    'a cancelled picker emits nothing',
    build: () {
      final imagePickerService = MockImagePickerService();
      when(
        () => imagePickerService.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
        ),
      ).thenAnswer((_) async => null);
      return CubitsFactories.buildProgressPhotosCubit(imagePickerService: imagePickerService);
    },
    act: (cubit) => cubit.pickPhoto(source: .gallery),
    expectPresentation: () => <ProgressPhotosPresentationEvent>[],
  );

  test('addPhoto reloads the photos and logs an action', () async {
    useMockLog();
    final addProgressPhotoUseCase = MockAddProgressPhotoUseCase();
    when(
      () => addProgressPhotoUseCase(
        bytes: any(named: 'bytes'),
        fileExtension: any(named: 'fileExtension'),
        takenDate: any(named: 'takenDate'),
        pose: .side,
        note: any(named: 'note'),
      ),
    ).thenAnswer((_) async => Success(ProgressPhotoFactory.build()));
    final getProgressPhotosUseCase = _photosUseCase([ProgressPhotoFactory.build()]);
    final cubit = CubitsFactories.buildProgressPhotosCubit(
      addProgressPhotoUseCase: addProgressPhotoUseCase,
      getProgressPhotosUseCase: getProgressPhotosUseCase,
    );

    await cubit.addPhoto(bytes: Uint8List(3), fileExtension: 'jpg', takenDate: DateTime(2026, 7, 18), pose: .side);

    verify(getProgressPhotosUseCase.call).called(1);
    expect(cubit.state.photos, isNotEmpty);
  });

  test('deletePhoto optimistically removes the photo', () async {
    useMockLog();
    final deleteProgressPhotoUseCase = MockDeleteProgressPhotoUseCase();
    when(
      () => deleteProgressPhotoUseCase(
        photoId: 'photo-old',
        storagePath: any(named: 'storagePath'),
      ),
    ).thenAnswer((_) async => const Success(null));
    final cubit = CubitsFactories.buildProgressPhotosCubit(
      deleteProgressPhotoUseCase: deleteProgressPhotoUseCase,
      getProgressPhotosUseCase: _photosUseCase([ProgressPhotoFactory.build(id: 'photo-old'), ProgressPhotoFactory.build(id: 'photo-2')]),
    );
    await cubit.loadPhotos();

    await cubit.deletePhoto(photo: ProgressPhotoFactory.build(id: 'photo-old'));

    expect(cubit.state.photos.map((photo) => photo.id), ['photo-2']);
  });

  test('a failed delete restores the photo', () async {
    useMockLog();
    final deleteProgressPhotoUseCase = MockDeleteProgressPhotoUseCase();
    when(
      () => deleteProgressPhotoUseCase(
        photoId: any(named: 'photoId'),
        storagePath: any(named: 'storagePath'),
      ),
    ).thenAnswer((_) async => const Failure(VTError(message: 'offline')));
    final cubit = CubitsFactories.buildProgressPhotosCubit(
      deleteProgressPhotoUseCase: deleteProgressPhotoUseCase,
      getProgressPhotosUseCase: _photosUseCase([ProgressPhotoFactory.build(id: 'photo-old')]),
    );
    await cubit.loadPhotos();

    await cubit.deletePhoto(photo: ProgressPhotoFactory.build(id: 'photo-old'));

    expect(cubit.state.photos.map((photo) => photo.id), ['photo-old']);
  });

  test('months groups the photos newest month first, one section per day', () {
    final state = ProgressPhotosState(
      photos: [
        ProgressPhotoFactory.build(id: 'a', takenDate: DateTime(2026, 7, 18)),
        ProgressPhotoFactory.build(id: 'b', takenDate: DateTime(2026, 7, 2)),
        ProgressPhotoFactory.build(id: 'c', takenDate: DateTime(2026, 6, 30)),
      ],
    );

    expect(state.months.map((section) => section.month), [DateTime(2026, 7), DateTime(2026, 6)]);
    expect(state.months.first.days.map((day) => day.day), [DateTime(2026, 7, 18), DateTime(2026, 7, 2)]);
  });

  test('a day keeps every shot taken that day, ordered front, side, back', () {
    final state = ProgressPhotosState(
      photos: [
        ProgressPhotoFactory.build(id: 'back', takenDate: DateTime(2026, 7, 18), pose: .back),
        ProgressPhotoFactory.build(id: 'front', takenDate: DateTime(2026, 7, 18)),
        ProgressPhotoFactory.build(id: 'side', takenDate: DateTime(2026, 7, 18), pose: .side),
      ],
    );

    expect(state.months.single.days.single.photos.map((photo) => photo.id), ['front', 'side', 'back']);
  });
}
