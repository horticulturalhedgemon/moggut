import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import "dart:convert";
import 'dart:async';
import 'dart:io';
import 'main.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({
    super.key,
    required this.prompt,
    required this.day,
    required this.filename,
    /*required this.day,
    required this.fileName*/
  });
  final String prompt;
  final String day;
  final String filename;
  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  /*final DateTime day;
  final String fileName;*/

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();
    appState.retrieveEntry(appState.controller,widget.filename);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Day: ${widget.day} Prompt: ${widget.prompt}'),
            ),
            ElevatedButton(onPressed: () => appState.saveEntry(appState.controller,widget.filename), child: Text('Save')),
            QuillSimpleToolbar(
              controller: appState.controller,
              configurations: const QuillSimpleToolbarConfigurations()
              ),
            Expanded(
              child: QuillEditor.basic(
                controller: appState.controller,
                configurations: const QuillEditorConfigurations(),
              ),
            )
          ],
        ),
      ),
    );
  }

}