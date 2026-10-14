import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ApiContent<T> extends StatefulWidget {
  const ApiContent({super.key, required this.load, required this.builder});
  final Future<T> Function() load;
  final Widget Function(BuildContext, T) builder;
  @override
  State<ApiContent<T>> createState() => _ApiContentState<T>();
}

class _ApiContentState<T> extends State<ApiContent<T>> {
  late Future<T> _future = widget.load();
  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Material(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${snapshot.error}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () {
                    final next = widget.load();
                    setState(() {
                      _future = next;
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }
      return widget.builder(context, snapshot.data as T);
    },
  );
}
