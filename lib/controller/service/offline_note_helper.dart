import 'dart:convert';
import 'package:note_app/models/note.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineNoteHelper {
  static const String _notesKey = 'notes';

  Future<void> saveNotes(List<Note> notes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notesJson =
        notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList(_notesKey, notesJson);
  }

  Future<List<Note>> loadNotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? notesJson = prefs.getStringList(_notesKey);
    if (notesJson != null) {
      return notesJson
          .map((noteJson) => Note.fromJson(jsonDecode(noteJson)))
          .toList();
    }
    return [];
  }
}
