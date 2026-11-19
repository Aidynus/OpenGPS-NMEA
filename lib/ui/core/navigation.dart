import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Goes back one screen. When there is nothing to go back to (for example
/// settings were opened through the password screen with `context.go`),
/// returns to the home screen instead.
void goBackOrHome(BuildContext context) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    router.go('/');
  }
}
