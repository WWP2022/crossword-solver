import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../auth/utils/date_time_converter.dart';
import '../../database/crossword_info_repository.dart';
import '../../model/crossword_info.dart';
import 'http_util.dart';

class FetchCrossword {
  static void getMissingCrosswords(String userId) async {
    var response = await HttpUtil.getAllCrosswordsInfo(userId);
    var body = jsonDecode(response.body);

    CrosswordInfoRepository crosswordInfoRepository = CrosswordInfoRepository();

    var existCrosswordsInfo = await crosswordInfoRepository.getAllCrosswordsInfo(userId);
    var existCrosswordsIds = existCrosswordsInfo.map((e) => e.id);

    Directory documentDirectory = await getApplicationDocumentsDirectory();

    for (var crosswordData in body) {
      var crosswordId = crosswordData['crossword_id'];

      if (!existCrosswordsIds.contains(crosswordData['crossword_id'])) {
        var crosswordName = crosswordData['crossword_name'];
        var status = crosswordData['crossword_status'];
        var timestamp =
            const DateTimeConverter().fromJson(crosswordData['timestamp'])!;

        var getSolvedCrosswordResponse =
            await HttpUtil.getSolvedCrossword(userId, crosswordId.toString());

        File solvedImageFile =
            File(join(documentDirectory.path, '$crosswordName.png'));
        solvedImageFile
            .writeAsBytesSync(getSolvedCrosswordResponse.bodyBytes);

        var crosswordInfo = CrosswordInfo(
            id: crosswordId,
            path: solvedImageFile.path,
            crosswordName: crosswordName,
            timestamp: timestamp,
            userId: userId,
            status: status);

        crosswordInfoRepository.insertCrosswordInfo(crosswordInfo);
      }
    }
  }
}
