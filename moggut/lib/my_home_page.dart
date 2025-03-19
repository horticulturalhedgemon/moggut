import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'entry_page.dart';
import 'main.dart';
import 'dart:io';
import "dart:convert";

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
                              destinations: appState.entryList.map((e) {
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
       }

