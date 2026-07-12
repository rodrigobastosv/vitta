import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/presentation/general/loading_presentation_event.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';

class VTPage<C extends PresentationCubit<S>, S> extends StatelessWidget {
  const VTPage({required this.create, required this.builder, super.key});

  final C Function() create;
  final Widget Function(BuildContext context, C cubit, S state) builder;

  @override
  Widget build(BuildContext context) => BlocProvider<C>(
    create: (_) => create(),
    child: BlocPresentationListener<C, LoadingPresentationEvent>(
      listener: (context, event) => switch (event) {
        LoadingPresentationEvent.show => context.showLoading(),
        LoadingPresentationEvent.hide => context.hideLoading(),
      },
      child: BlocBuilder<C, S>(builder: (context, state) => builder(context, context.read<C>(), state)),
    ),
  );
}
