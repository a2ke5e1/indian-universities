import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

class UniversityLoader {
  bool loading = false;
  List<List<dynamic>>? _cachedData;

  Future<List<List<dynamic>>> loadUniversityDetails() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    loading = true;
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/A3-Inc/indian-universities/main/indian_universities_2024.csv'));

    if (response.statusCode == 200) {
      final csvData = response.body;
      final List<List<dynamic>> data =
          const CsvToListConverter().convert(csvData);

      // Sort the data by university name
      data.sort((a, b) => a[1].toString().compareTo(b[1].toString()));

      // Remove the header row
      data.removeAt(0);

      _cachedData = data;
      loading = false;
      return data;
    } else {
      loading = false;
      throw Exception('Failed to load university details');
    }
  }
}
