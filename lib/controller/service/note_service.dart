import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:note_app/models/note.dart';

class NoteService {
  final String uid;
  final CollectionReference _noteCollection;

  NoteService(this.uid)
      : _noteCollection = FirebaseFirestore.instance
            .collection('notes')
            .doc(uid)
            .collection('userNotes');

  Stream<List<Note>> getNotes() {
    return _noteCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Note.fromDocument(doc)).toList();
    });
  }

  Future<void> addOrUpdateNote(Note note) async {
    await _noteCollection.doc(note.id.toString()).set(note.toMap());
  }

  Future<void> deleteNoteById(int noteId) async {
    await _noteCollection.doc(noteId.toString()).delete();
  }
}
