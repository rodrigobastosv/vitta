import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitta/app/core/di/dependencies.dart';
import 'package:vitta/app/core/loading/loading_extensions.dart';
import 'package:vitta/app/presentation/general/presentation_cubit.dart';
import 'package:vitta/app/presentation/general/vt_presentation_event.dart';

class VTPage<C extends PresentationCubit<S, P>, S, P> extends StatelessWidget {
  const VTPage({required this.builder, this.onPresentation, super.key});

  final Widget Function(BuildContext context, C cubit, S state) builder;
  final void Function(BuildContext context, P event)? onPresentation;

  @override
  Widget build(BuildContext context) => BlocProvider<C>(
    create: (_) => G<C>(),
    child: BlocPresentationListener<C, P>(
      listener: (context, event) {
        if (event is LoadingPresentationEvent) {
          event.isLoading ? context.showLoading() : context.hideLoading();
        }
        onPresentation?.call(context, event);
      },
      // A descendant of BlocPresentationListener, so its own initState (where onInit()
      // runs) is guaranteed to fire after the listener has subscribed — calling onInit()
      // any earlier (e.g. from BlocProvider's create:) would emit into a broadcast stream
      // nothing is listening to yet, silently dropping the first presentation event.
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
  Widget build(BuildContext context) =>
      BlocBuilder<C, S>(builder: (context, state) => widget.builder(context, context.read<C>(), state));
}
