import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/models/note.dart';

class NoteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  NoteService(this.userId);

  // Fetch notes
  getNotes(userID) {
    return _db
            .collection('users')
            .doc(userID)
            .collection('notes')
            .snapshots()
            .map(
              (snapshot) => snapshot.docs
                  .map((doc) => Note.fromFirestore(doc.data()))
                  .toList(),
            ) ??
        null;
  }

  AddNote(Note note, User? uid) async {
    _db
        .collection('users')
        .doc(uid!.uid)
        .collection('notes')
        .doc(note.id.toString())
        .set(note.toFirestore());
  }

  UpdateNote(Note note, User? uid) {
    _db
        .collection('users')
        .doc(uid!.uid)
        .collection('notes')
        .doc(note.id.toString())
        .update(note.toFirestore());
  }
  // Add or update a note

  // Delete a note
  Future<void> deleteNoteById(int id) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notes')
        .doc(id.toString())
        .delete();
  }
}
