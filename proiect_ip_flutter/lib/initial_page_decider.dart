import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proiect_ip_flutter/error_page.dart';
import 'package:proiect_ip_flutter/log_in_page.dart';
import 'package:proiect_ip_flutter/provider.dart';
import 'home_page.dart';

class InitialPageDecider extends ConsumerWidget {
  const InitialPageDecider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _authState = ref.watch(authStateProvider);
    return _authState.when(
        data: (data) {
          if (data != null) return const HomePage();
          return const LogInPage();
        },
        loading: () => const CircularProgressIndicator(),
        error: (e, trace) => const ErrorPage());
  }
}
