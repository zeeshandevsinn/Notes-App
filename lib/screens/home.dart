import 'dart:developer';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_app/constants/colors.dart';
import 'package:note_app/constants/toast.dart';
import 'package:note_app/controller/firebase/firebaseIntegration.dart';
import 'package:note_app/controller/firebase/firebaseManager.dart';
import 'package:note_app/controller/service/offline_note_helper.dart';
import 'package:note_app/models/note.dart';
import 'package:note_app/screens/edit.dart';

class HomeScreen extends StatefulWidget {
  final email, password;
  const HomeScreen({Key? key, this.email, this.password}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> filteredNotes = []; // Initialize filteredNotes with an empty list
  bool sorted = false;
  late NoteService noteService;
  late OfflineNoteHelper offlineNoteHelper;
  late User? user;
  bool isLoading = true;
  var isonline;
  @override
  void initState() {
    super.initState();

    setState(() {
      isonline = _isOnline();
    });

    if (isonline != null) {
      setState(() {
        user = FirebaseAuth.instance.currentUser;
        noteService = NoteService(user!.uid);
        offlineNoteHelper = OfflineNoteHelper();

        fetchNotes();
      });
    } else {
      setState(() {
        offlineNoteHelper = OfflineNoteHelper();

        fetchNotes();
      });
    }
  }

  fetchNotes() {
    setState(() {
      isLoading = true;
    });
    try {
      if (isonline != null) {
        noteService
            .getNotes(FirebaseAuth.instance.currentUser!.uid)
            .listen((List<Note> data) {
          setState(() {
            sampleNotes = data;
            filteredNotes = sampleNotes;
            isLoading = false;
            offlineNoteHelper.saveNotes(data);
          });

          // Optionally, save to offline storage here if needed
        });
      } else {
        setState(() {
          isLoading = false;
          loadOfflineNotes();
        });
      }
    } catch (e) {
      print('Error fetching notes: $e');
      setState(() {
        isLoading = false;
        loadOfflineNotes();
      });

      // Load offline notes on error
    }
  }

  void loadOfflineNotes() async {
    List<Note> offlineNotes = await offlineNoteHelper.loadNotes();
    setState(() {
      sampleNotes = offlineNotes;
      filteredNotes = sampleNotes;
    });
  }

  Future<bool> _isOnline() async {
    setState(() {
      isLoading = true;
    });
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none ? true : false;
  }

  getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  void onSearchTetChanged(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        // If search text is empty, reset filteredNotes to show all notes
        filteredNotes = sampleNotes;
      } else {
        // Filter notes based on search text
        filteredNotes = sampleNotes
            .where((note) =>
                note.content.toLowerCase().contains(searchText.toLowerCase()) ||
                note.title.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }
      // Sort filtered notes after filtering
      filteredNotes = sortNotesByModifiedTime(filteredNotes);
    });
  }

  List<Note> sortNotesByModifiedTime(List<Note> notes) {
    if (sorted) {
      notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      notes.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
    }
    sorted = !sorted;
    return notes;
  }

  void deleteNote(int index) {
    setState(() {
      Note note = filteredNotes[index];
      noteService.deleteNoteById(note.id);
      filteredNotes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Notes",
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      filteredNotes = sortNotesByModifiedTime(filteredNotes);
                    });
                  },
                  padding: const EdgeInsets.all(0),
                  icon: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(.8),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.sort,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: onSearchTetChanged,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: "Search notes...",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                fillColor: Colors.grey.shade800,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : filteredNotes.isEmpty
                      ? const Center(
                          child: Text(
                            "Here is No Notes Added!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 30),
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            return Container(
                              height: 120,
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 20),
                                color: getRandomColor(),
                                child: ListTile(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            EditScreen(
                                          note: filteredNotes[index],
                                        ),
                                      ),
                                    );

                                    if (result != null) {
                                      setState(() async {
                                        Note updatedNote = Note(
                                          id: filteredNotes[index].id,
                                          title: result[0],
                                          content: result[1],
                                          modifiedTime: DateTime.now(),
                                        );
                                        await noteService.UpdateNote(
                                            updatedNote,
                                            FirebaseAuth.instance.currentUser);
                                        int originalIndex = filteredNotes
                                            .indexOf(filteredNotes[index]);
                                        filteredNotes[originalIndex] =
                                            updatedNote;
                                      });
                                      ToastUtil.showSuccessToast(
                                          "Update Successfully");
                                    }
                                  },
                                  title: RichText(
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      text: '${filteredNotes[index].title}\n',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        height: 1.5,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: filteredNotes[index].content,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: Text(
                                    "Edited: ${DateFormat('EEE MMM d, yyyy h:mm a').format(filteredNotes[index].modifiedTime)}",
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      final result =
                                          await confirmationDialogue(context);
                                      if (result != null && result) {
                                        deleteNote(index);
                                      }
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const EditScreen(),
            ),
          );
          if (result != null) {
            setState(() async {
              Note newNote = Note(
                id: filteredNotes.length + 1,
                title: result[0],
                content: result[1],
                modifiedTime: DateTime.now(),
              );

              await noteService.AddNote(
                  newNote, FirebaseAuth.instance.currentUser);
              ToastUtil.showSuccessToast("Added Succesfully");
              filteredNotes.add(newNote);
            });
          }
        },
        elevation: 10,
        backgroundColor: Colors.grey.shade800,
        child: const Icon(
          Icons.add,
          size: 38,
          color: Colors.white,
        ),
      ),
    );
  }

  confirmationDialogue(context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          icon: Icon(Icons.info, color: Colors.grey),
          title: const Text(
            'Are you sure you want to delete?',
            style: TextStyle(color: Colors.white),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const SizedBox(
                  width: 60,
                  child: Text(
                    'Yes',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const SizedBox(
                  width: 60,
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
