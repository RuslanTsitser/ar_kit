import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final _logger = Logger(
  output: ConsoleOutput(
    truncate: false,
  ),
  printer: PrettyPrinter(
    colors: true,
    printTime: false,
    printEmojis: false,
    noBoxingByDefault: false,
    lineLength: 80,
  ),
);

Logger get _truncateLogger => Logger(
      output: ConsoleOutput(
        truncate: true,
      ),
      printer: PrettyPrinter(
        colors: true,
        printTime: false,
        printEmojis: false,
        noBoxingByDefault: false,
        lineLength: 80,
      ),
    );

bool get _enableLogger => true;

bool get _showBLOC => true;
bool get _showAppRouter => true;
bool get _showRestApi => true;
bool get _showChangeNotifier => true;
bool get _showMetrica => true;
bool get _showAds => true;
bool get _showAbTest => true;
bool get _showLocalStorage => true;
bool get _showLocalisation => true;
bool get _showFirebase => true;
bool get _showLocalNotificationsService => true;
bool get _showDebouncer => false;
bool get _showAdjust => true;

void logData(dynamic data) => _logger.t(data);

void logInfo(dynamic data) => _logger.i(data);

void logError(dynamic data, [dynamic error, StackTrace? stackTrace]) {
  _logger.e(data, error: error, stackTrace: stackTrace);
}

// BLOC logs
void logBlOC(dynamic data) => _showBLOC ? _logger.i(data) : null;
void logErrorBlOC(dynamic data, [dynamic error, StackTrace? stackTrace]) {
  _showBLOC ? _logger.e(data, error: error, stackTrace: stackTrace) : null;
}

// APP ROUTER logs
void logAppRouter(dynamic data) => _showAppRouter ? _logger.i(data) : null;
void logErrorAppRouter(dynamic data, [dynamic error, StackTrace? stackTrace]) {
  _showAppRouter ? _logger.e(data, error: error, stackTrace: stackTrace) : null;
}

// REST API logs
void logRestApi(dynamic data) => _showRestApi ? _truncateLogger.i(data) : null;
void logErrorRestApi(dynamic data, [dynamic error, StackTrace? stackTrace]) {
  _showRestApi ? _logger.e(data, error: error, stackTrace: stackTrace) : null;
}

// Change notifier logs
void logChangeNotifier(dynamic data) => _showChangeNotifier ? _logger.i(data) : null;
void logErrorChangeNotifier(dynamic data, [dynamic error, StackTrace? stackTrace]) {
  _showChangeNotifier ? _logger.e(data, error: error, stackTrace: stackTrace) : null;
}

// Metrica logs
void logMetrica(dynamic data) => _showMetrica ? _logger.i(data) : null;
void logErrorMetrica(dynamic data, [dynamic error, StackTrace? stackTrace]) {
  _showMetrica ? _logger.e(data, error: error, stackTrace: stackTrace) : null;
}

// Ad logs
void logAds(dynamic data) => _showAds ? _logger.i(data) : null;
void logErrorAds(dynamic data, [dynamic error, StackTrace? stackTrace]) {
  _showAds ? _logger.e(data, error: error, stackTrace: stackTrace) : null;
}

// Ad logs
void logAbTest(dynamic data) => _showAbTest ? _logger.i(data) : null;
void logErrorAbTest(dynamic data, [dynamic error, StackTrace? stackTrace]) {
  _showAbTest ? _logger.e(data, error: error, stackTrace: stackTrace) : null;
}

// LocalStorage logs
void logLocalStorage(dynamic data) => _showLocalStorage ? _logger.i(data) : null;
void logErrorLocalStorage(dynamic data, [dynamic error, StackTrace? stackTrace]) {
  _showLocalStorage ? _logger.e(data, error: error, stackTrace: stackTrace) : null;
}

// Localisation logs
void logLocalisation(dynamic data) => _showLocalisation ? _logger.i(data) : null;

// Firebase logs
void logFirebase(dynamic data) => _showFirebase ? _logger.i(data) : null;
void logErrorFirebase(dynamic data, [dynamic error, StackTrace? stackTrace]) {
  _showFirebase ? _logger.e(data, error: error, stackTrace: stackTrace) : null;
}

// Local notifications logs
void logLocalNotifications(dynamic data) => _showLocalNotificationsService ? _logger.i(data) : null;

// delayed or restorable callback logs
void logDebouncer(dynamic data) => _showDebouncer ? _logger.i(data) : null;

// Adjust logs
void logAdjust(dynamic data) => _showAdjust ? _logger.i(data) : null;

class ConsoleOutput extends LogOutput {
  final int lineLength;
  final bool truncate;
  ConsoleOutput({this.lineLength = 80, this.truncate = true});
  @override
  void output(OutputEvent event) {
    List<String> lines = [...event.lines];
    if (lines.length > lineLength && truncate) {
      lines = lines.sublist(0, lineLength);
      lines.add('...');
    }
    if (_enableLogger) {
      if (kIsWeb) {
        for (var element in lines) {
          log(element);
        }
      } else {
        log(lines.join('\n'));
      }
    }
  }
}
