import 'package:cloud_firestore/cloud_firestore.dart';

class Details {
  String? University_Type;
  String? State;
  String? Location;
  String? District;
  String? address;
  String? website;
  String? University_Name;
  String? docId;

  Details(
      {required this.University_Type,
      required this.State,
      required this.Location,
      required this.District,
      required this.address,
      required this.website,
      required this.University_Name,
      this.docId});

  factory Details.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return Details(
        University_Type: data?["University_Type"],
        State: data?["State"],
        Location: data?["Location"],
        District: data?["District"],
        address: data?["Address"],
        website: data?["Website"],
        University_Name: data?["University_Name"].toString().toUpperCase(),
        docId: snapshot.id);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (University_Type != null) "University_Type": University_Type,
      if (State != null) "State": State,
      if (Location != null) "Location": Location,
      if (District != null) "District": District,
      if (address != null) "Address": address,
      if (website != null) "Website": website,
      if (University_Name != null) "University_Name": University_Name
    };
  }
}
