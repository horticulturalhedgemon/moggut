import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'entry_page.dart';
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
  List<List> entryList = [["day 1","prompt 1", "file1"],["day 2","prompt 2", "file2"],["day 3","prompt 3", "file3"]];

}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    Widget page;

    page = EntryPage(day: appState.entryList[selectedIndex][0], prompt: appState.entryList[selectedIndex][1], fileId: appState.entryList[selectedIndex][2],);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: appState.entryList.map((e) {
                    return NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text(e[0]),
                    );
                  }).toList(),
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    print('new index selected: $value');
                    setState(() {
                      selectedIndex = value;
                      });
                  },
                  backgroundColor:Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

