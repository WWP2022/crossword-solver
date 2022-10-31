import 'package:crossword_solver/model/direction.dart';
import 'package:tuple/tuple.dart';

import '../solveCrossword/crossword_scrapper.dart';

class CrosswordNode {
  String definition;
  Tuple2<int, int> positionOfDefinition;
  Direction direction;
  Tuple2<int, int> solutionStartPosition;
  int length;
  String solution;
  List<String> possibleAnswers;

  CrosswordNode(
      {required this.definition,
      required this.positionOfDefinition,
      required this.direction,
      required this.solutionStartPosition,
      required this.length})
      : solution = "*" * length,
        possibleAnswers = [];

  scrapPossibleAnswers() async {
    possibleAnswers =
        await CrosswordScrapper.findPossibleAnswers(definition, length);
  }
}
