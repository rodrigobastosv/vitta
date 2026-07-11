import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VTPage<C extends StateStreamable<S>, S> extends StatelessWidget {
  const VTPage({required this.builder, super.key});

  final Widget Function(BuildContext context, C cubit, S state) builder;

  @override
  Widget build(BuildContext context) => BlocBuilder<C, S>(builder: (context, state) => builder(context, context.read<C>(), state));
}
