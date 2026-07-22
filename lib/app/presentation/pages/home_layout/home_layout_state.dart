import 'package:equatable/equatable.dart';
import 'package:vitta/app/domain/home/entities/home_layout.dart';

class HomeLayoutState extends Equatable {
  const HomeLayoutState({required this.layout});

  final HomeLayout layout;

  HomeLayoutState copyWith({HomeLayout? layout}) => HomeLayoutState(layout: layout ?? this.layout);

  @override
  List<Object?> get props => [layout];
}
