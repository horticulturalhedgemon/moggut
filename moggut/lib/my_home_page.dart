import 'package:english_words/english_words.dart';
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
    future: appState.fetchPrefs(), // async work
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
                      if (value == appState.entryList.length-1) {
                        appState.createNewPage();
                      }
                      selectedIndex = value;
                      });
                  },
                  backgroundColor:Theme.of(context).colorScheme.inversePrimary,
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

