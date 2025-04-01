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
  var selectedIndex = 0;
  dynamic appState;

  @override
  void initState() {
    super.initState();
    MyAppState.startBackend();
    _state = SchedulerBinding.instance.lifecycleState;
    _listener = AppLifecycleListener(
        // This fires for each state change. Callbacks above fire only for
        // specific state transitions.
        onShow: () => print("shown"),
        onInactive: () => print("inactive"),
        onHide: () => MyAppState.quitBackend(),
        onResume: () => print("resumed")
      );
    }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<MyAppState>();
    Widget page;
    return FutureBuilder<List>(
    future: appState.fetchEntries(), // async work
    builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
       switch (snapshot.connectionState) {
         case ConnectionState.waiting: return Text('Loading....');
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
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
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
                          onPressed: () => appState.saveEntry(appState.controller,appState.entryList[selectedIndex][2]),
                          child: Text('Save')),
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
              Expanded(
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

