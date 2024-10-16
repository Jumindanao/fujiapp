import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UnitsFetcher extends StatefulWidget {
  @override
  _UnitsFetcherState createState() => _UnitsFetcherState();
}

class _UnitsFetcherState extends State<UnitsFetcher> {
  List<Map<String, dynamic>> units = []; // Store fetched units
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUnits();
  }

  Future<void> _fetchUnits() async {
    final response = await Supabase.instance.client
        .from('UnitsTable')
        .select('CourseID, Title, UnitOrder');

    // Extract data from response
    final List<dynamic>? data = response as List<dynamic>?;

    if (data != null && data.isNotEmpty) {
      // Convert dynamic data to List<Map<String, dynamic>>
      units = List<Map<String, dynamic>>.from(data);
    } else {
      print('No units found.');
    }

    setState(() {
      isLoading = false; // Update loading state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Units List'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : units.isNotEmpty
              ? ListView.builder(
                  itemCount: units.length,
                  itemBuilder: (context, index) {
                    final unit = units[index];
                    return ListTile(
                      title: Text(unit['Title']),
                      subtitle: Text('Unit Order: ${unit['UnitOrder']}'),
                    );
                  },
                )
              : Center(child: Text('No units available')),
    );
  }
}
