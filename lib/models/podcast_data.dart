import 'package:podcast_app/firestore_database_maanger/sqlite_manager.dart';

class PodcastData {
  final String? name;
  final String? image;
  final String? description;
  final String? album;
  final String? episodes;
  final String? releaseDate;
  final String? whenAdded;
  final String? duration;
  bool isSelected;

  PodcastData(
      {this.name,
      this.image,
      this.description,
      this.album,
      this.episodes,
      this.releaseDate,
      this.whenAdded,
      this.duration,
      this.isSelected = false});
}

class EpisodeData {
  final String? day;
  final String? episodeName;
  final String? releaseDate;
  final String? duration;
  bool isPlay;
  bool isFavorite;
  bool isDownloaded;

  EpisodeData({
    this.day,
    this.episodeName,
    this.releaseDate,
    this.duration,
    this.isPlay = false,
    this.isFavorite = false,
    this.isDownloaded = false,
  });
}

/*
{
  artwork: 40hadith,
  speakers: Mufti Hussain Kamani,
  title: 40 Ahadith of Imam Nawawi, 
  updated: 1635327591136, 
  feedUrl: http://feeds.feedburner.com/Qalam40Ahadith
}
*/
class Series {
  String? id = "";
  String? artwork = "";
  String? speaker = "";
  String? title = "";
  int? updated = 0;
  String? feedUrl = "";

  String type = "Qalam";
  int episodeCount = 20;
  String releaseDate = "25 Apr";
  String episodeDuration = "14 Min";
  int likeCount = 2230;
  bool isSelected = false;

  Series.initFromJson(Map<String, dynamic> json) {
    id = json['title'] ; //TODO: Need to udpate Id key with correct name. Using title as unique id, as not getting any id from firestore
    artwork = json['artwork'];
    speaker = json["speakers"];
    title = json["title"];
    updated = json["updated"];
    feedUrl = json["feedUrl"];
  }

  String get description {
    return [speaker, title].join(", ");
  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      SeriesTable.title: title,
      SeriesTable.artwork: artwork,
      SeriesTable.feedUrl: feedUrl,
      SeriesTable.speekers: speaker,
      SeriesTable.updated: updated
    };

    return map;
  }
}

class Episode {
  String? id = "";
  String? category = "";
  String? content = "";
  String? contentSnippet = "";
  var _duration = "";
  String? image = "";
  String? keywords = "";
  String? shortTitle = "";
  String? speaker = "";
  String? streamUrl = "";
  String? subtitle = "";
  String? title = "";
  String? type = "";
  int? updated = 0;
  bool isSelected = false;
  var releaseDate = "28 Apr";

String? downloadFilePath = "";
var downloaded = false;

  String get duration {
    print(_duration);
    var totalSeconds = int.parse(_duration, onError: (v) {
      return 0;
    });
    if (totalSeconds.isNaN) return "00:00";
    var d = Duration(seconds: totalSeconds);
    var ts = d.toString();
    List<String> parts = d.toString().split(':');
    var seconds = double.parse(parts[2]);
    var time =
        '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}';
    return time;
  }

  Episode.initFromJson(Map<String, dynamic> json) {
    id = json['title'];  //TODO: Need to udpate Id key with correct name. Using title as unique id, as not getting any id from firestore
    category = json['category'];
    content = json["content"];
    contentSnippet = json["contentSnippet"];
    _duration = json["duration"].toString();
    image = json["image"];
    keywords = json["keywords"];
    shortTitle = json["shortTitle"];
    speaker = json["speaker"];
    streamUrl = json["streamUrl"];
    subtitle = json["subtitle"];
    title = json["title"];
    type = json["type"];
    updated = json["updated"];
    if(json['isFavourite'] != null) {
      isSelected = json['isFavourite'] == 1;
    }
    
    if(json['downloadFileName'] != null) {
      downloadFilePath = json['downloadFileName'];
    }
    if(json['downloaded'] != null) {
      downloaded = json['downloaded'] == 1;
    }

  }

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      EpisodeTable.category: category,
      EpisodeTable.content: content,
      EpisodeTable.contentSnippet: contentSnippet,
      EpisodeTable.duration: _duration,
      EpisodeTable.image: image,
      EpisodeTable.keywords: keywords,
      EpisodeTable.shortTitle: shortTitle,
      EpisodeTable.speaker: speaker,
      EpisodeTable.streamUrl: streamUrl,
      EpisodeTable.subtitle: subtitle,
      EpisodeTable.title: title,
      EpisodeTable.type: type,
      EpisodeTable.updated: updated,
      EpisodeTable.isFav: isSelected,
      EpisodeTable.downloaded: downloaded,
      EpisodeTable.downloadFileName: downloadFilePath,
    };

    return map;
  }
}




  String  mediaPlayerTimeString(int duration) {
    var totalSeconds = duration;
    if (totalSeconds.isNaN) return "00:00";
    var d = Duration(seconds: totalSeconds);
    List<String> parts = d.toString().split(':');
    var seconds = double.parse(parts[2]);
    var time =
        '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}';
    return time;
  }
