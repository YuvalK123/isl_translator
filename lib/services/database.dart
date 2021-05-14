import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isl_translator/models/video.dart';

class DatabaseService {

  final String uid;

  DatabaseService({ this.uid });

  // collection reference
  final CollectionReference videosCollection =
  Firestore.instance.collection('videosUrls');




  Future updateVideo(String key, String url, String desc) async {
    print("inserting $key, $url, $desc");
    return await videosCollection.document(key).setData({
      "title": key,
      "url": url,
      "description": desc
    });
  }

  Future deleteVideo(String key) async {
    print("deleting $key");
    return await videosCollection.document(key).delete();
  }

  List<Vid> _videoFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) =>
        Vid(title: doc.data['title'] ?? 'no title available',
            url: doc.data['url'] ?? 'no url available',
            desc: doc.data['description'] ?? 'no desc available')
    ).toList();
  }

  Stream<List<Vid>> get vids {
    Stream<List<Vid>> x = videosCollection.snapshots().map(_videoFromSnapshot);
    print("x is $x");
    // print(x.forEach((element) => element.toString()));
    return x;
  }

}
