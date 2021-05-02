import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  // DatabaseService( { this.uid } );

  // collection reference
  final CollectionReference videosCollection =
    Firestore.instance.collection('videosUrls');

  Future updateVideo(String key, String url, String desc) async {
    return await videosCollection.document('K5PJZ8WUsbNqi7tqfxzmbljgPW73').setData({
      "title" : key,
      "url" : url,
      "description" : desc
    });
  }

}