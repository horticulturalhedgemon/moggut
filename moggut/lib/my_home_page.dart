import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'entry_page.dart';
import 'main.dart';
import 'dart:io';
import "dart:convert";

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AppLifecycleState? _state;
  late final AppLifecycleListener _listener;
  int selectedIndex = 0;
  dynamic appState;
  Widget page = Spacer();
  @override
  void initState() {
    super.initState();
    _state = SchedulerBinding.instance.lifecycleState;
    _listener = AppLifecycleListener(
        // This fires for each state change. Callbacks above fire only for
        // specific state transitions.
        onShow: () => print("shown"),
        onInactive: () => print("inactive"),
        onDetach: () => {
          print("detached"),
          MyAppState.quitBackend()
          },
        onResume: () => print("resumed")
      );
    }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<MyAppState>();
    MyAppState.dartLogger.w("hey");
    return FutureBuilder<List>(
    future: appState.fetchEntries(), // async work
    builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
       switch (snapshot.connectionState) {
         case ConnectionState.waiting: return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: IntrinsicWidth(
                child: Column(
                  //mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              extended: constraints.maxWidth >= 600,
                              onDestinationSelected: (value) {
                              print('new index selected: $value');
                              setState(() {
                                selectedIndex = value;
                                });
                              },
                              destinations: appState.entryList.map<NavigationRailDestination>((e) {
                                return NavigationRailDestination(
                                  icon: Icon(Icons.library_books_outlined),
                                  label: Text(e[0]),
                                );
                              }).toList(),
                              selectedIndex: appState.entryList.isNotEmpty ? selectedIndex : null,
                              backgroundColor:Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      child: Row(
                        children: [
                          Spacer(),
                          ElevatedButton(
                          onPressed: () => MyAppState.startBackend(),
                          child: Text('Start Backend')),
                          ElevatedButton(
                          onPressed: () => appState.saveEntry(appState.controller,appState.entryList[selectedIndex][2]),
                          child: Text('Save')),
                          ElevatedButton(
                          onPressed: () => MyAppState.quitBackend(),
                          child: Text('Quit Backend')),
                          Spacer()
                          ]
                        )
                    ),
                    SizedBox(
                      height:10,
                      child: Container (color:Theme.of(context).colorScheme.inversePrimary)
                    )
                  ],
                )
              ),
              ),
              Flexible(
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
         default:
           if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
           }
           else {
            page = EntryPage(day: appState.entryList[selectedIndex][0], prompt: appState.entryList[selectedIndex][1], filename: appState.entryList[selectedIndex][2],);
          return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: IntrinsicWidth(
                child: Column(
                  //mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              extended: constraints.maxWidth >= 600,
                              destinations: appState.entryList.map<NavigationRailDestination>((e) {
                                return NavigationRailDestination(
                                  icon: Icon(Icons.library_books_outlined),
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
                        ),
                      ),
                    ),
                    Container(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      child: Row(
                        children: [
                          Spacer(),
                          ElevatedButton(
                          onPressed: () => MyAppState.startBackend(),
                          child: Text('Start Backend')),
                          ElevatedButton(
                          onPressed: () => appState.saveEntry(appState.controller,appState.entryList[selectedIndex][2]),
                          child: Text('Save')),
                          ElevatedButton(
                          onPressed: () => MyAppState.quitBackend(),
                          child: Text('Quit Backend')),
                          Spacer()
                          ]
                        )
                    ),
                    SizedBox(
                      height:10,
                      child: Container (color:Theme.of(context).colorScheme.inversePrimary)
                    )
                  ],
                )
              ),
              ),
              Flexible(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page
                ),
              ),
            ],
          ),
        );
      }
    );}
    
          }
  }
  );
        }
    @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }
       }

