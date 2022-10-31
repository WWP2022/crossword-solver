import 'dart:io';

import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class CrosswordScrapper {
  // Scrap data from hasladokrzyzowek.com site
  static Future<List<String>> findPossibleAnswers_1(
      String searchMeaning, int length) async {
    final body = {
      "do": "crossword",
      "desc": searchMeaning.replaceAll(" ", "+"),
      "letters": length.toString()
    };

    final postResponse = await http.post(
        Uri.parse(
            'https://hasladokrzyzowek.com/krzyzowka/${"-" * length}/${searchMeaning.replaceAll(" ", "+")}/'),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.acceptHeader: "application/xhtml+xml"
        },
        body: body);

    final getResponse =
        await http.get(Uri.parse(postResponse.headers['location']!));

    BeautifulSoup bs = BeautifulSoup(getResponse.body);

    var possibleAnswers = bs
        .findAll('td', attrs: {'class': 'puzzal-name'})
        .map((x) => x.getText().toUpperCase())
        .toSet()
        .toList();

    return possibleAnswers;
  }

  // Scrap data from krzyzowki123.pl site
  static Future<List<String>> findPossibleAnswers_3(
      String searchMeaning, int length) async {
    final body = {
      "searchMeaning": searchMeaning,
      "searchCrossword": length.toString()
    };

    final postResponse = await http.post(
        Uri.parse('https://krzyzowki123.pl/searchForm'),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body);

    final getResponse = await http.get(Uri.parse(
        'https://krzyzowki123.pl${postResponse.headers['location']!}'));

    final BeautifulSoup bs = BeautifulSoup(getResponse.body);

    var possibleAnswers = bs
        .findAll('td', attrs: {'class': 'pre'})
        .map((x) => x.getText().toUpperCase())
        .toSet()
        .toList();

    return possibleAnswers;
  }

  // Scrap data from szarada.net site
  static Future<List<String>> findPossibleAnswers_2(
      String searchMeaning, int length) async {
    final body = {'search': searchMeaning, 'letters': length.toString()};

    final response = await http.get(
        Uri.https('szarada.net', '/slownik/wyszukiwarka-okreslen/', body),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});

    BeautifulSoup bs = BeautifulSoup(response.body);

    var possibleAnswers_1 = [];

    for (var element in bs.findAll('td', attrs: {'class': 'checks'})) {
      var possibleAnswer =
          element.findAll('span').map((e) => e.text).join().toUpperCase();
      if (possibleAnswer.length == length) {
        possibleAnswers_1.add(possibleAnswer);
      }
    }

    var possibleAnswers_2 = bs.findAll('span',
        attrs: {'class': 'answer'}).map((e) => e.getText().toUpperCase());

    return List.from(possibleAnswers_1)..addAll(possibleAnswers_2);
  }

  // Scrap data from sites
  static Future<List<String>> findPossibleAnswers(
      String searchMeaning, int length) async {
    // var possibleAnswers_1 = await findPossibleAnswers_1(searchMeaning, length);
    var possibleAnswers_2 = await findPossibleAnswers_2(searchMeaning, length);
    var possibleAnswers_3 = await findPossibleAnswers_3(searchMeaning, length);

    var possibleAnswers = Set<String>.from(possibleAnswers_2)
      ..addAll(possibleAnswers_3);

    debugPrint(
        'definition: $searchMeaning, possible answers: $possibleAnswers');
    return possibleAnswers.toList();
  }
}
