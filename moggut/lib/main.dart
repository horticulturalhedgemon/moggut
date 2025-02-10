import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_home_page.dart';
import 'package:flutter_quill/flutter_quill.dart';
import "dart:convert";
import 'dart:async';
import 'dart:io';
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
  int dayCount = 0;
  List entryList = [];
  QuillController controller = QuillController.basic();

  //loads entryList from file at app start (and maybe each build?).
  Future<List> fetchPrefs() async {
    //only run the first time
    if (entryList.isNotEmpty) {
      return entryList;
    }
    print("fetchPrefs activated");
    String contents = await File("files/entry_list.txt").readAsString();
    final json = jsonDecode(contents);
    entryList = json.map((e) => List<String>.from(e)).toList();
    dayCount = entryList.length-1;
    return entryList;
}

  void saveEntry(QuillController controller, String filename) async {
    //should only work on desktop
    final json = jsonEncode(controller.document.toDelta().toJson());
    //static access uses class name, nonstatic access uses widget
    var file = await File(filename).writeAsString(json);
    print('file length: ${file.length()}');
  }

  void retrieveEntry(QuillController controller, String filename) async {
    File(filename).readAsString().then((contents) {
    final json = jsonDecode(contents);
    controller.document = Document.fromJson(json);
    });
  }

  void createNewPage() async {
    dayCount += 1;
    var returnPrompt = 'prompt $dayCount';
    final response = await http.get(Uri.parse('http://127.0.0.1:5000'));
      if (response.statusCode == 200) {
        var responseBody = response.body;
        returnPrompt = '$responseBody $dayCount';
      }

    entryList.insert(entryList.length-1,["day $dayCount",returnPrompt, "files/file$dayCount.txt"]);
    //json encode to bypass format errror: control character in string
    var file = await File("files/file$dayCount.txt").writeAsString(jsonEncode([{"insert":"\n"}]));
    print('file length: ${file.length()}');
    file = await File("files/entry_list.txt").writeAsString(jsonEncode(entryList));
    print('file length: ${file.length()}');
  }
    @override
  void dispose() {
    controller.dispose();
    super.dispose();
}
}

