import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/logcat_entry.dart';
import '../services/logcat_service.dart';
import 'device_providers.dart';

final logcatServiceProvider = Provider<LogcatService>((ref) {
  final service = LogcatService();
  ref.onDispose(() => service.stopStream());
  return service;
});

class LogcatState {
  final List<LogcatEntry> entries;
  final bool isPaused;
  final String searchQuery;
  final Set<LogLevel> activeLevels;
  final String? activeTag;

  LogcatState({
    this.entries = const [],
    this.isPaused = false,
    this.searchQuery = '',
    this.activeLevels = const {},
    this.activeTag,
  });

  LogcatState copyWith({
    List<LogcatEntry>? entries,
    bool? isPaused,
    String? searchQuery,
    Set<LogLevel>? activeLevels,
    String? activeTag,
  }) {
    return LogcatState(
      entries: entries ?? this.entries,
      isPaused: isPaused ?? this.isPaused,
      searchQuery: searchQuery ?? this.searchQuery,
      activeLevels: activeLevels ?? this.activeLevels,
      activeTag: activeTag ?? this.activeTag,
    );
  }
}

final logcatNotifierProvider = StateNotifierProvider<LogcatNotifier, LogcatState>((ref) {
  final selectedDevice = ref.watch(selectedDeviceProvider);
  final service = ref.watch(logcatServiceProvider);
  return LogcatNotifier(service, selectedDevice?.serial);
});

class LogcatNotifier extends StateNotifier<LogcatState> {
  final LogcatService _service;
  final String? _serial;
  StreamSubscription? _sub;

  static const int maxEntries = 5000;

  LogcatNotifier(this._service, this._serial) : super(LogcatState()) {
    if (_serial != null) {
      _start();
    }
  }

  void _start() {
    _sub?.cancel();
    _sub = _service.startStream(_serial!).listen((entry) {
      if (!state.isPaused) {
        final newEntries = List<LogcatEntry>.from(state.entries)..add(entry);
        if (newEntries.length > maxEntries) {
          newEntries.removeRange(0, newEntries.length - maxEntries);
        }
        state = state.copyWith(entries: newEntries);
      }
    });
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void clear() {
    state = state.copyWith(entries: []);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleLevel(LogLevel level) {
    final newLevels = Set<LogLevel>.from(state.activeLevels);
    if (newLevels.contains(level)) {
      newLevels.remove(level);
    } else {
      newLevels.add(level);
    }
    state = state.copyWith(activeLevels: newLevels);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final filteredLogcatProvider = Provider<List<LogcatEntry>>((ref) {
  final state = ref.watch(logcatNotifierProvider);
  
  if (state.searchQuery.isEmpty && state.activeLevels.isEmpty) {
    return state.entries;
  }

  return state.entries.where((entry) {
    bool matchesSearch = true;
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      matchesSearch = entry.message.toLowerCase().contains(q) || entry.tag.toLowerCase().contains(q);
    }

    bool matchesLevel = true;
    if (state.activeLevels.isNotEmpty) {
      matchesLevel = state.activeLevels.contains(entry.level);
    }

    return matchesSearch && matchesLevel;
  }).toList();
});
