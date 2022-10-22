import 'package:crossword_solver/example_crossword_data.dart';
import 'package:crossword_solver/model/direction.dart';

import 'crossword_node.dart';

class Crossword {
  List<CrosswordNode> nodes;
  int row;
  int col;
  List<String> data;

  Crossword({required this.nodes, required this.row, required this.col})
      : data = List.generate(row, (i) => '.' * col, growable: false) {
    for (var node in nodes) {
      var line = data[node.positionOfDefinition.item1];
      line =
          "${line.substring(0, node.positionOfDefinition.item2)}#${line.substring(node.positionOfDefinition.item2 + 1)}";
      data[node.positionOfDefinition.item1] = line;
    }
  }

  scrapPossibleAnswersForCrossword() async {
    await Future.wait(nodes.map((node) => node.scrapPossibleAnswers()));
  }

  fillCrossword() {
    for (var node in nodes) {
      if (node.possibleAnswers.length == 1) {
        node.solution = node.possibleAnswers.first;
        if (node.direction == Direction.down) {
          for (int i = 0; i < node.solution.length; i++) {
            var line = crossword.data[node.solutionStartPosition.item1 + i];
            line = line.substring(0, node.solutionStartPosition.item2) +
                node.solution[i] +
                line.substring(node.solutionStartPosition.item2 + 1);
            crossword.data[node.solutionStartPosition.item1 + i] = line;
          }
        } else {
          for (int i = 0; i < node.solution.length; i++) {
            var line = crossword.data[node.solutionStartPosition.item1];
            line = line.substring(0, node.solutionStartPosition.item2 + i) +
                node.solution[i] +
                line.substring(node.solutionStartPosition.item2 + i + 1);
            crossword.data[node.solutionStartPosition.item1] = line;
          }
        }
      }
    }
  }

  removeWrongPossibleAnswers() {
    for (var node in nodes) {
      var regex = "";
      if (node.direction == Direction.right) {
        regex = crossword.data[node.solutionStartPosition.item1].substring(
            node.solutionStartPosition.item2,
            node.solutionStartPosition.item2 + node.length);
      } else {
        for (int i = 0; i < node.length; i++) {
          regex = regex +
              crossword.data[node.solutionStartPosition.item1 + i]
                  [node.solutionStartPosition.item2];
        }
      }
      RegExp exp = RegExp("\\b$regex\\b", caseSensitive: false);
      var filtered = node.possibleAnswers
          .where((element) => exp.hasMatch(element))
          .toList();
      node.possibleAnswers = filtered;
    }
  }

  solve() {
    // TODO flaga czy coś przy iteracji się zmieniło
    // TODO dodanie ewentualnie algorytmu z cofaniem
    for (int i = 0; i < 10; i++) {
      fillCrossword();
      removeWrongPossibleAnswers();
    }
  }
}
