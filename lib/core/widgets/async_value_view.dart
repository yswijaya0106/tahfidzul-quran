import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../error/app_exception.dart';

/// Renders the loading / error / unauthorized / data states for any
/// [AsyncValue], per CLAUDE.md: "Implement loading, empty, error, retry,
/// offline, and unauthorized states for every remote screen."
class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) data;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context)? empty;
  final bool Function(T data)? isEmpty;

  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.empty,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _ErrorView(error: error, onRetry: onRetry),
      data: (value) {
        if (empty != null && isEmpty != null && isEmpty!(value)) {
          return empty!(context);
        }
        return data(context, value);
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  const _ErrorView({required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final currentError = error;
    final exception = currentError is AppException
        ? currentError
        : AppException.unknown(currentError.toString());

    if (exception.isUnauthenticated) {
      return _MessageView(
        icon: Icons.lock_outline,
        title: 'Sesi berakhir',
        message: 'Silakan masuk kembali untuk melanjutkan.',
        actionLabel: 'Ke halaman masuk',
        onAction: () => context.goToLogin(),
      );
    }

    if (exception.isForbidden) {
      return const _MessageView(
        icon: Icons.block,
        title: 'Akses dibatasi',
        message: 'Anda tidak memiliki izin untuk melihat ini.',
      );
    }

    if (exception.code == 'NETWORK_ERROR') {
      return _MessageView(
        icon: Icons.wifi_off,
        title: 'Sepertinya Anda sedang offline',
        message: 'Periksa koneksi Anda dan coba lagi.',
        actionLabel: onRetry != null ? 'Coba lagi' : null,
        onAction: onRetry,
      );
    }

    return _MessageView(
      icon: Icons.error_outline,
      title: 'Terjadi kesalahan',
      message: exception.message,
      actionLabel: onRetry != null ? 'Coba lagi' : null,
      onAction: onRetry,
    );
  }
}

class _MessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              semanticsLabel: message,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

extension GoToLoginExtension on BuildContext {
  void goToLogin() => go('/login');
}
