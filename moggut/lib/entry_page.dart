import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import "dart:convert";
import 'dart:async';
import 'dart:io';

class EntryPage extends StatefulWidget {
  const EntryPage({
    super.key,
    required this.prompt,
    required this.day,
    required this.fileId,
    /*required this.day,
    required this.fileName*/
  });
  final String prompt;
  final String day;
  final String fileId;
  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  /*final DateTime day;
  final String fileName;*/
  QuillController _controller = QuillController.basic();
  @override
  void initState() {
    super.initState();

  }
  void saveEntry() async {
    //should only work on desktop
    final json = jsonEncode(_controller.document.toDelta().toJson());
    //static access uses class name, nonstatic access uses widget
    final filename = 'files/${widget.fileId}.txt';
    var file = await File(filename).writeAsString(json);
    print('file length: ${file.length()}');
  }
  void retrieveEntry(String) async {
    final filename = 'files/${widget.fileId}.txt';
    File(filename).readAsString().then((contents) {
    final json = jsonDecode(contents);
    _controller.document = Document.fromJson(json);
    });
    
  }
  @override
  Widget build(BuildContext context) {
    retrieveEntry(widget.fileId);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Day: ${widget.day} Prompt: ${widget.prompt}'),
            ),
            ElevatedButton(onPressed: () => saveEntry(), child: Text('Save')),
            QuillSimpleToolbar(
              controller: _controller,
              configurations: const QuillSimpleToolbarConfigurations()
              ),
            Expanded(
              child: QuillEditor.basic(
                controller: _controller,
                configurations: const QuillEditorConfigurations(),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
}}