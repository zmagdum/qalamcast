import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:podcast_app/models/podcast_data.dart';

class FireStoreManager {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  CollectionReference get categoryCollection =>
      _firestore.collection('categories');
  CollectionReference get episodeCollection =>
      _firestore.collection('episodes');

  List<Series> categories = [];

  Future<List<Series>> fetchCategories() async {
    await Firebase.initializeApp();
    var collection = await categoryCollection.get();

    var categories =
        collection.docs.map((e) => Series.initFromJson(e.data() as Map<String, dynamic>)).toList();
    this.categories = categories;
    return categories;
  }

  List<Series> filterCategories(String text) {
    var term = text.toLowerCase();

    return this
        .categories
        .where((e) =>
            e.title!.toLowerCase().contains(term) ||
            e.speaker!.toLowerCase().contains(term))
        .toList();
  }

  Future<List<Episode>> getEpisodesFor(Series series) async {
    await Firebase.initializeApp();
    var collection = await episodeCollection
        .where('category', isEqualTo: series.title)
        .get();

    var episodes =
        collection.docs.map((e) => Episode.initFromJson(e.data() as Map<String, dynamic>)).toList();

    return episodes;
  }
}
