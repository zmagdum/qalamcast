import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podcast_app/firestore_database_maanger/sqlite_manager.dart';
import 'package:podcast_app/models/podcast_data.dart';

class DownloadManager {
  static var shared = DownloadManager._init();

  DownloadManager._init();

  List<Downloader> currentDownloads = [];

  donwloadCourse(Episode episode,
      {Function? onProgress,
      Function? onError,
      Function? onDone,
      }) async {
    Downloader downloader;
    var fileName = "course_${episode.title}.mp3";

    downloader = Downloader(
      fileUrl: episode.streamUrl,
      identifier: episode.id.toString(),
      fileName: fileName,
    );

    addListners(episode, downloader, onProgress, onError, onDone);

    downloader.startDownloading();

    currentDownloads.add(downloader);
  }

  bool isDownloading(Episode? course) {
    var downloader = currentDownloads.singleWhereOrNull(
        (download) => download.identifier == course!.id.toString());

    return (downloader != null && downloader.isDownloading);
  }


  addListners(
    Episode episode,
    Downloader downloader,
    Function? onProgress,
    Function? onError,
    Function? onDone,
  ) {

    downloader.progressHandler = (progress) {
      // print(progress);
      downloader.currentProgress = progress;
      onProgress!(progress);
    };
    downloader.onError = (e) {
      print(e.toString());

      onError!(errorMessageFrom(e));
      removeDownloader(downloader);
    };

    downloader.onCompletion = (file) async {
      print("=============== download completed ============= ");
      print(file);
      File fl = file;
      episode.downloadFilePath = fl.path;
      episode.downloaded = true;
      SqliteDatabaseManager.shared.saveDownloadedEpisode(episode);
      onDone!(file);

      removeDownloader(downloader);
    };
  }

  Downloader? downloaderFor(Episode course) {
    var downloader = currentDownloads.singleWhereOrNull(
        (download) => download.identifier == course.id.toString());

    return downloader;
  }

  removeDownloader(Downloader downloader) {
    currentDownloads.remove(downloader);
  }
}

class Downloader {
  var fileUrl; // 
  var progressHandler; // return current progress
  var onCompletion; //  return a file
  var onError; //  return an error

  var identifier;
  var sequenceId;
  String? fileName = "";

  var isDownloading = false;
  var isUnzippingFile = false;
  var currentProgress = 0.0;

  Downloader({
    this.fileUrl,
    this.identifier,
    this.sequenceId,
    this.progressHandler,
    this.onError,
    this.onCompletion,
    this.fileName,
  });

  double? progress = 0;

  String? get urlString {
    return fileUrl;
  }

  var dio = Dio();
  void startDownloading() async {
    progress = null;
    var dirName = "podcastapp";

    final savePath = await createDirectory(dirName) + "/$fileName";

    isDownloading = true;
    print(urlString);
    dio.download(urlString!, savePath, 
        onReceiveProgress: (receive, total) {
      progress = (receive / total);
      print(progress);
      progressHandler(progress);
    }).then((response) {
      print("completed");
      isDownloading = false;
      var file = File(savePath);
      // await file.writeAsBytes(bytes);
      onCompletion(file);
    }).catchError((e) {
      isDownloading = false;
      if (e is DioError) {
        if (e.response != null && e.response!.data != null) {
          if (e.response!.data is Map) {
            var message = e.response!.data['messsage'] ?? "";
            e.error = message;
          }
        }
        onError(e.error);
      } else {
        onError(e);
      }
    });
  }
  
}



Future<bool> fileExist(String filename) async {
  var file = await getFilePath(filename);
  
   return file.exists();
}

Future<File> getFilePath(String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  return File("${dir.path}/$filename");
}

Future<String> getDirPath(String name) async {
  final dir = await getApplicationDocumentsDirectory();
  return "${dir.path}/$name";
}

createDirectory(String name) async {
  final dir = await getApplicationDocumentsDirectory();
  var path = "${dir.path}/$name";
  if (await Directory(path).exists()) {
  } else {
    Directory(path).create();
  }
  return path;
}




Future<String> courseLaunchPathFor(String courseId) async {
  var dir = await getApplicationDocumentsDirectory();
  var path = "${dir.path}/Courses" + "/course_$courseId" + "/index.html";

  return path;
}





 String errorMessageFrom(dynamic error) {
    switch (error.runtimeType) {
      case SocketException:
        return "Internet connection not available, check your connection and try again";
        break;
      case HandshakeException:
        return error.message ?? error.toString();
        break;
      default:
        if (error is String) return error;
        return error.message ?? error.toString();
        break;
    }
  }