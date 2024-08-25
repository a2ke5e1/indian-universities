import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;
import 'package:indian_universities/models/details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UniversityLoader {
  bool loading = false;
  List<Details>? _cachedData;

  Future<List<Details>> loadUniversityDetails() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    final prefs = await SharedPreferences.getInstance();
    final cachedCsvData = prefs.getString('cached_university_data');

    List<List<dynamic>> cleanData(List<List<dynamic>> data) {
      // Remove empty rows
      data.removeWhere((row) => row[1].toString().isEmpty);

      // Remove the header row
      data.removeAt(0);

      // Sort the data by university name
      data.sort((a, b) => a[1].toString().compareTo(b[1].toString()));

      return data;
    }

    if (cachedCsvData != null) {
      final List<List<dynamic>> csvData =
          const CsvToListConverter().convert(cachedCsvData);

      _cachedData = _convertToDetailsList(cleanData(csvData));
      return _cachedData!;
    }

    loading = true;
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/A3-Inc/indian-universities/main/indian_universities_2024.csv'));

    if (response.statusCode == 200) {
      final csvData = response.body;
      final List<List<dynamic>> data =
          const CsvToListConverter().convert(csvData);

      _cachedData = _convertToDetailsList(cleanData(data));

      // Save the data to SharedPreferences
      await prefs.setString('cached_university_data', csvData);

      loading = false;
      return _cachedData!;
    } else {
      loading = false;
      throw Exception('Failed to load university details');
    }
  }

  Map<String, List<Details>> getUniversitiesByState(
      List<Details> universities) {
    final Map<String, List<Details>> universitiesByState = {};

    for (final university in universities) {
      if (universitiesByState.containsKey(university.State)) {
        universitiesByState[university.State]!.add(university);
      } else {
        universitiesByState[university.State ?? "Others"] = [university];
      }
    }

    return universitiesByState;
  }

  Map<String, List<Details>> getUniversitiesByType(
      List<Details> universities) {
    final Map<String, List<Details>> universitiesByState = {};

    for (final university in universities) {
      if (universitiesByState.containsKey(university.University_Type)) {
        universitiesByState[university.University_Type]!.add(university);
      } else {
        universitiesByState[university.University_Type ?? "Others"] = [university];
      }
    }

    return universitiesByState;
  }

  List<Details> _convertToDetailsList(List<List<dynamic>> csvData) {
    return csvData.map((row) {
      return Details(
        University_Type: row[5].toString(),
        State: row[2].toString(),
        Location: row[7].toString(),
        District: row[3].toString(),
        address: row[8].toString(),
        website: row[4].toString(),
        University_Name: row[1].toString(),
        docId: row[0].toString(),
      );
    }).toList();
  }
}
