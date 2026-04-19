import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// A service that exposes a global [NavigatorState] so that non-widget
/// classes (e.g. deep-link & notification handlers) can trigger navigation
/// without needing a [BuildContext].
@lazySingleton
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static Future<T?> navigateTo<T extends Object?>(String routeName,
      {Object? arguments}) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return null;
    return navigator.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> push<T extends Object?>(Route<T> route) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return null;
    return navigator.push<T>(route);
  }

  static void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  static void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
      String routeName,
      {Object? arguments,
      TO? result}) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return null;
    return navigator.pushReplacementNamed<T, TO>(routeName,
        arguments: arguments, result: result);
  }

  static Future<T?> pushAndRemoveUntil<T extends Object?>(
      String routeName, String untilRouteName,
      {Object? arguments}) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return null;
    return navigator.pushNamedAndRemoveUntil<T>(
        routeName, ModalRoute.withName(untilRouteName),
        arguments: arguments);
  }

  bool canPop() => navigatorKey.currentState?.canPop() ?? false;
}
