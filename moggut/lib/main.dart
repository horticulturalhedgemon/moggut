import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_home_page.dart';
import 'package:flutter_quill/flutter_quill.dart';
import "dart:convert";
import 'dart:async';
import 'dart:io';

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
  int dayCount = 3;
  List<List> entryList = [["day 1","prompt 1", "files/file1.txt"],["day 2","prompt 2", "files/file2.txt"],["day 3","prompt 3", "files/file3.txt"],["new entry"]];
  QuillController controller = QuillController.basic();

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
    entryList.insert(entryList.length-1,["day $dayCount","prompt $dayCount", "files/file$dayCount.txt"]);
    //json encode to bypass format errror: control character in string
    var file = await File("files/file$dayCount.txt").writeAsString(jsonEncode([{"insert":"\n"}]));
    print('file length: ${file.length()}');
  }
    @override
  void dispose() {
    controller.dispose();
    super.dispose();
}
}

