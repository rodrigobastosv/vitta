import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';

class VTPage<C extends PresentationCubit<S, P>, S, P> extends StatelessWidget {
  const VTPage({required this.builder, this.onPresentation, this.cubitParam, super.key});

  final Widget Function(BuildContext context, C cubit, S state) builder;
  final void Function(BuildContext context, P event)? onPresentation;

  /// Handed to `G<C>(param1: ...)` for a cubit registered with
  /// `registerFactoryParam`, so a page whose cubit needs a runtime argument
  /// (the recipe being edited, say) still resolves it here rather than taking a
  /// `create:` callback.
  final Object? cubitParam;

  @override
  Widget build(BuildContext context) => BlocProvider<C>(
    create: (_) => G<C>(param1: cubitParam),
    child: BlocPresentationListener<C, P>(
      listener: (context, event) {
        onPresentation?.call(context, event);
      },
      child: _VTPageOnInit<C, S, P>(builder: builder),
    ),
  );
}

class _VTPageOnInit<C extends PresentationCubit<S, P>, S, P> extends StatefulWidget {
  const _VTPageOnInit({required this.builder});

  final Widget Function(BuildContext context, C cubit, S state) builder;

  @override
  State<_VTPageOnInit<C, S, P>> createState() => _VTPageOnInitState<C, S, P>();
}

class _VTPageOnInitState<C extends PresentationCubit<S, P>, S, P> extends State<_VTPageOnInit<C, S, P>> {
  @override
  void initState() {
    super.initState();
    context.read<C>().onInit();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<C, S>(builder: (context, state) => widget.builder(context, context.read<C>(), state));
}
