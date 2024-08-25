import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:indian_universities/models/details.dart';

class FireStoreDataBase {
  final _db = FirebaseFirestore.instance;

  static const UNIVERSITY_COLLECTION = "universities";
  static const FAVOURITE_COLLECTION = "favourites";
  static const USER_COLLECTION = "users";

  // Future<Details?> _unidetails(CollectionReference collectionref, String docId) async {
  //   await collectionRef.doc(docId).get().then((value) {
  //         value.
  //   });
  // }

  late final universityRef;
  late final favouriteref;

  FireStoreDataBase() {
    universityRef = _db
        .collection(UNIVERSITY_COLLECTION)
        .orderBy("University_Name")
        .withConverter(
          fromFirestore: Details.fromFirestore,
          toFirestore: (Details detail, options) => detail.toFirestore(),
        );

    var userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return;
    }
    favouriteref = _db
        .collection(USER_COLLECTION)
        .doc(userId)
        .collection(FAVOURITE_COLLECTION)
        .withConverter(
          fromFirestore: Details.fromFirestore,
          toFirestore: (Details detail, options) => detail.toFirestore(),
        );
  }

  Future addFavourite(Details detail) async {
    try {
      await favouriteref.doc(detail.docId).set(detail);
    } catch (e) {
      debugPrint("Error - $e");
    }
  }

  Future removeFavourite(Details detail) async {
    try {
      await favouriteref.doc(detail.docId).delete();
    } catch (e) {
      debugPrint("Error - $e");
    }
  }

  Future<List<Details>> getData() async {
    try {
      List<Details> universityList = [];

      await universityRef.limit(25).get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          universityList.add(result.data());
        }
      });

      return universityList;
    } catch (e) {
      debugPrint("Error - $e");
      return [];
    }
  }

  Future<List<Details>> getNextData(Details lastVisible, limit) async {
    try {
      List<Details> universityList = [];
      await universityRef
          .startAfter([lastVisible.toFirestore()])
          .limit(limit)
          .get()
          .then((querySnapshot) {
            for (var result in querySnapshot.docs) {
              universityList.add(result.data());
            }
          });
      return universityList;
    } catch (e) {
      debugPrint("Error - $e");
      return [];
    }
  }

  Future<List<Details>> getFavouriteData() async {
    try {
      List<Details> favList = [];
      await FireStoreDataBase().favouriteref.get().then((querySnapshot) {
        for (var result in querySnapshot.docs) {
          favList.add(result.data());
        }
      });
      return favList;
    } catch (e) {
      debugPrint("Error - $e");
      return [];
    }
  }
}


