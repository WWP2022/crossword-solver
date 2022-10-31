import 'package:flutter/material.dart';

import 'example_crossword_data.dart';
import 'ffi_bridge.dart';

final FFIBridge _ffiBridge = FFIBridge();

class CrosswordSolverWidget extends StatefulWidget {
  const CrosswordSolverWidget({super.key});

  @override
  State<CrosswordSolverWidget> createState() => _CrosswordSolverWidget();
}

class _CrosswordSolverWidget extends State<CrosswordSolverWidget> {
  // Strings to store final data from crossword
  String result1 = _ffiBridge.getNumber().toString();
  String result2 = '';
  String result3 = '';
  String result4 = '';
  String result5 = '';
  String result6 = '';
  String result7 = '';
  String result8 = '';
  String result9 = '';
  String result10 = '';
  String result11 = '';
  String result12 = '';
  String result13 = '';
  String result14 = '';
  String result15 = '';
  String result16 = '';

  bool isLoading = false;

  Future<List<String>> solve() async {
    await crossword.scrapPossibleAnswersForCrossword();

    crossword.solve();

    return crossword.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Solved crossword')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // if isLoading is true show loader
            // else show Column of Texts
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Text(result1,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result2,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result3,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result4,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result5,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result6,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result7,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result8,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result9,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result10,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result11,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result12,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result13,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result14,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result15,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(result16,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.08),
                      MaterialButton(
                        onPressed: () async {
                          // Setting isLoading true to show the loader
                          setState(() {
                            isLoading = true;
                          });

                          // Awaiting for web scraping function
                          // to return list of strings
                          final response = await solve();

                          // Setting the received strings to be
                          // displayed and making isLoading false
                          // to hide the loader
                          setState(() {
                            result1 = response[0];
                            result2 = response[1];
                            result3 = response[2];
                            result4 = response[3];
                            result5 = response[4];
                            result6 = response[5];
                            result7 = response[6];
                            result8 = response[7];
                            result9 = response[8];
                            result10 = response[9];
                            result11 = response[10];
                            result12 = response[11];
                            result13 = response[12];
                            result14 = response[13];
                            result15 = response[14];
                            result16 = response[15];
                            isLoading = false;
                          });
                        },
                        color: Colors.green,
                        child: const Text(
                          'Scrap Data',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
          ],
        )),
      ),
    );
  }
}
