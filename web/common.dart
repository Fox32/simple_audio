library common;
import 'dart:html';
import 'package:simple_audio/simple_audio.dart';

String getDemoBaseURL() {
  String location = window.location.href;
  int slashIndex = location.lastIndexOf('/');
  if (slashIndex < 0) {
    return '/';
  } else {
    return location.substring(0, slashIndex);
  }
}

class ClipTable {
  AudioManager _manager;
  // Table or Div
  ClipTable(this._manager);

  void _removeDead() {
  }

  void _addNew() {
  }

  void refresh() {
    _removeDead();
    _addNew();
  }
}

class SourceTable {
  AudioManager _manager;
  // Table or Div
  SourceTable(this._manager);

  void _removeDead() {
  }

  void _addNew() {
  }

  void refresh() {
    _removeDead();
    _addNew();
  }
}