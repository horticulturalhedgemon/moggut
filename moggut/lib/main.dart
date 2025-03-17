import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_home_page.dart';
import 'package:flutter_quill/flutter_quill.dart';
import "dart:convert";
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 177, 209, 183)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  
  //day, prompt
  List entryList = [];
  QuillController controller = QuillController.basic();
  //loads entryList from file at app start (and maybe each build?).
  Future<List> fetchEntries() async {
    //only run the first time
    if (entryList.isNotEmpty) {
      return entryList;
    }
    print("fetchPrefs activated");
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/entry'));
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      entryList = responseBody;
    }
    else {
      print('http call failed, status code ${response.statusCode.toString()}');
    }
    return entryList;
    
}

  void saveEntry(QuillController controller, String fileId) async {
    //should only work on desktop
    final jsonEntry = jsonEncode(controller.document.toDelta().toJson());
    final response = await http.put(Uri.parse('http://127.0.0.1:5000/api/entry/$fileId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEntry);
    if (response.statusCode == 200) {
      print('file save success!');
    }
    else {
      print('http call failed, status code ${response.statusCode.toString()}');
    }
  }

  void retrieveEntry(QuillController controller, String fileId) async {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/entry/$fileId'));
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        controller.document = Document.fromJson(responseBody);
      }
      else {
        print('http call failed, status code ${response.statusCode.toString()}');
      }
  }

  //check for new pages and add entries if necessary
  //if success, update entryList with new data
  void updateEntries() async {
    final response = await http.post(Uri.parse('http://127.0.0.1:5000/api/entry'));
      if (response.statusCode == 200) {
        var responseBody = response.body;
        entryList.insert(entryList.length-1,jsonDecode(responseBody));
        print('file save success!');
      }
      else {
        print('http call failed, status code ${response.statusCode.toString()}');
      }
  }

    @override
  void dispose() {
    controller.dispose();
    super.dispose();
}
}

