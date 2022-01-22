import 'package:podcast_app/models/podcast_data.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDatabaseManager {
  static var shared = SqliteDatabaseManager();

  Database? db;

  Future createTables() async {
    db = await openDatabase('podcastapp.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table ${SeriesTable.tableName} ( 
  ${SeriesTable.id} text, 
  ${SeriesTable.artwork} text,
  ${SeriesTable.feedUrl} text,
  ${SeriesTable.speekers} text,
  ${SeriesTable.title} text,
  ${SeriesTable.updated} integer)
''');

      await db.execute('''
    create table ${EpisodeTable.tableName} (
      ${EpisodeTable.id} text,
      ${EpisodeTable.category} text,
      ${EpisodeTable.content} text,
      ${EpisodeTable.contentSnippet} text,
      ${EpisodeTable.duration} integer,
      ${EpisodeTable.image} text,
      ${EpisodeTable.keywords} text,
      ${EpisodeTable.shortTitle} text,
      ${EpisodeTable.speaker} text,
      ${EpisodeTable.streamUrl} text,
      ${EpisodeTable.subtitle} text,
      ${EpisodeTable.title} text,
      ${EpisodeTable.type} text,
      ${EpisodeTable.isFav} bool,
      ${EpisodeTable.downloaded} bool,
      ${EpisodeTable.downloadFileName} text,
      ${EpisodeTable.updated} integer)
    ''');
    });
  }

  Future<Series> insert(Series series) async {
    var id = await db!.insert(SeriesTable.tableName, series.toMap());
    // update series id
    return series;
  }

  Future<int> delete(Series series) async {
    return await db!.delete(SeriesTable.tableName,
        where: '${SeriesTable.title} = ?', whereArgs: [series.title]);
  }

  Future<List<Series>> getFavouriteSeries([String? searchTerm]) async {
    if (db == null) {
      db = await openDatabase("podcastapp.db");
    }

    List<Map> seriesMaps = [];
    if (searchTerm != null) {
      seriesMaps = await db!
          .rawQuery('SELECT * FROM ${SeriesTable.tableName} WHERE ${SeriesTable.title} = $searchTerm');
    } else {
      seriesMaps = await db!.query(SeriesTable.tableName);
    }

    var series = seriesMaps.map((e) => Series.initFromJson(e as Map<String, dynamic>)).toList();
    return series;
  }

  makeFavOrUnFavSeries(Series series) async {
    if (series.isSelected) {
      print("insert series");

      await insert(series);
    } else {
      print("delete series");
      await delete(series);
    }
  }

  Future<Episode> insertEpisode(Episode episode) async {
    var items = await db!.query(EpisodeTable.tableName, where: '${EpisodeTable.id} = ?', whereArgs: [episode.id]);
      if(items.isEmpty) {
    var id = await db!.insert(EpisodeTable.tableName, episode.toMap());   

    } else {
     await  db!.update(EpisodeTable.tableName, episode.toMap());
    }
    return episode;
  }

  Future deleteEpisode(Episode episode) async {
    return await db!.delete(EpisodeTable.tableName,
        where: '${EpisodeTable.title} = ?', whereArgs: [episode.id]);

  }

  Future<List<Episode>> getAllLocalSavedEpisodes([String? searchTerm]) async {
    if (db == null) {
      db = await openDatabase("podcastapp.db");
    }

    List<Map> episodeMaps = [];
    episodeMaps = await db!.query(EpisodeTable.tableName);
  print(episodeMaps);
    var episodes = episodeMaps.map((e) => Episode.initFromJson(e as Map<String, dynamic>)).toList();
    return episodes;
  }

  Future<List<Episode>> getFavouriteEpisodes([String? searchTerm]) async {
    if (db == null) {
      db = await openDatabase("podcastapp.db");
    }

    List<Map> episodeMaps = [];
    episodeMaps = await db!.rawQuery(
        'SELECT * FROM ${EpisodeTable.tableName} WHERE ${EpisodeTable.isFav} = 1');

    var episode = episodeMaps.map((e) => Episode.initFromJson(e as Map<String, dynamic>)).toList();
    return episode;
  }

Future<List<Episode>> getDownloadedEpisodes([String? searchTerm]) async {
    if (db == null) {
      db = await openDatabase("podcastapp.db");
    }

    List<Map> episodeMaps = [];
    episodeMaps = await db!.rawQuery(
        'SELECT * FROM ${EpisodeTable.tableName} WHERE ${EpisodeTable.downloaded} = 1');

    var episode = episodeMaps.map((e) => Episode.initFromJson(e as Map<String, dynamic>)).toList();
    return episode;
  }
  makeFavOrUnFavEpisode(Episode episode) async {
    if (episode.isSelected) {
      print("insert series");

      await insertEpisode(episode);
    } else {
      print("delete series");
      await deleteEpisode(episode);
    }
  }

  saveDownloadedEpisode(Episode episode) {
    insertEpisode(episode);
  }
}

class SeriesTable {
  static var tableName = "SeriesTable";
  static var id = "seriesId";
  static var artwork = "artwork";
  static var feedUrl = "feedUrl";
  static var speekers = "speekers";
  static var title = "title";
  static var updated = "updated";
}

class EpisodeTable {
  static var tableName = "EpisodeTable";
  static var id = "episodeId";
  static var category = "category";
  static var content = "content";
  static var contentSnippet = "contentSnippet";
  static var duration = "duration";
  static var image = "image";
  static var keywords = "keywords";
  static var shortTitle = "shortTitle";
  static var speaker = "speaker";
  static var streamUrl = "streamUrl";
  static var subtitle = "subtitle";
  static var title = "title";
  static var type = "type";
  static var updated = "updated";
  static var isFav = "isFavourite";
  static var downloaded = "downloaded";
  static var downloadFileName = "downloadFileName";
}
