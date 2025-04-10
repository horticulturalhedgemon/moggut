import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_home_page.dart';
import 'package:flutter_quill/flutter_quill.dart';
import "dart:convert";
import 'dart:io';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

void main() {
  //MyAppState.startBackend();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true, 
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 48, 52, 34),brightness: (DateTime.now().hour > 17 ? Brightness.dark : Brightness.light)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  static var fileOut = FileOutput(file: File('logs.txt'));
  static var dartLogger = Logger(output: fileOut);
  List entryList = [];
  QuillController controller = QuillController.basic();

  //run backend if not already running
  static Future<void> startBackend() async {
    if (await backendRunning()) {
      dartLogger.t("startBackend: Backend already running.");
    }
    else {
      Process.run('python', ['python/runIndex.py']);
      while(!await backendRunning()) {
        await Future.delayed(const Duration(milliseconds: 2));
      }
      dartLogger.t("startBackend: Backend started.");
    }
  }

  //if backend is running, kill backend (while loop in case of multiple instances).
  static Future<void> quitBackend() async {
    while (await backendRunning()) {
      http.post(Uri.parse('http://127.0.0.1:5000/api/quit')).then((response) {
        print(response.body);
        dartLogger.t('quitBackend: Backend shutdown.');
        }).catchError((error) {
      dartLogger.t('quitBackend: Error during backend shutdown: $error');
      });
    }
  }

  //check if backend running
  static Future<bool> backendRunning() async {
    try {
      await http.get(Uri.parse('http://127.0.0.1:5000/api/ping'));
      return true;
    }
    catch (e) {
      return false;
    }
  }

  //gets list of entries from file
  Future<List> fetchEntries() async {
    if (entryList.isNotEmpty) {
      dartLogger.t("fetchEntries: entryList found.");
      return entryList;
    }
    dartLogger.t("FE: awaiting backend");
    //if not running, await run
    await startBackend();
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/entry'));
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      entryList = responseBody;
      dartLogger.t("fetchEntries: entries fetched.");
    }
    else {
      dartLogger.e('fetchEntries: http call failed, status code ${response.statusCode.toString()}');
    }
    return entryList;
}

  //save current entry from controller to file
  void saveEntry(QuillController controller, String fileId) async {
    //should only work on desktop
    await startBackend();
    final jsonEntry = jsonEncode(controller.document.toDelta().toJson());
    final response = await http.put(Uri.parse('http://127.0.0.1:5000/api/entry/$fileId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEntry);
    if (response.statusCode == 200) {
      dartLogger.t('saveEntry: Success!');
    }
    else {
      dartLogger.e('saveEntry: http call failed, status code ${response.statusCode.toString()}');
    }
  }

  //get entry and load to controller
  Future<void> retrieveEntry(QuillController controller, String fileId) async {
    await startBackend();
    final dynamic response = await http.get(Uri.parse('http://127.0.0.1:5000/api/entry/$fileId'));
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        controller.document = Document.fromJson(responseBody);
        dartLogger.t('retrieveEntry: Success!');
      }
      else {
        dartLogger.e('retrieveEntry: http call failed, status code ${response.statusCode.toString()}');
      }
  }

  //check for new pages and add entries if necessary
  //if success, update entryList with new data
  void updateEntries() async {
    await startBackend();
    final response = await http.post(Uri.parse('http://127.0.0.1:5000/api/entry'));
      if (response.statusCode == 200) {
        var responseBody = response.body;
        entryList.insert(entryList.length-1,jsonDecode(responseBody));
        dartLogger.t('updateEntries: Success!');
      }
      else {
        dartLogger.e('updateEntries: http call failed, status code ${response.statusCode.toString()}');
      }
  }
  
}


