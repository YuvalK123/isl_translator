import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;

  DatabaseService( { this.uid } );

  // collection reference
  final CollectionReference videosCollection =
    Firestore.instance.collection('videosUrls');

  Future updateVideo(String key, String url, String desc) async {
    print("$key, $url, $desc");
    return await videosCollection.document(key).setData({
      "title" : key,
      "url" : url,
      "description" : desc
    });
  }

  Future deleteVideo(String key) async{
    print("deleting $key");
    return await videosCollection.document(key).delete();
  }
}