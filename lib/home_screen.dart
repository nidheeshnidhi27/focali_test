import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String accessToken;
  const HomeScreen({super.key, required this.accessToken});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(context);
  }

  Future<void> _fetchData(context) async {
    final response = await http.get(
      Uri.parse(
          'https://focali-uat.azurewebsites.net/api/app/projectdetail/withOutDetails?maxResultCount=500&filter=(%20status%20eq%201%20)&onlyActive=true'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _items = data['items'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch data.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Project No: ${item['projectNo']}'),
                              Text('Port Name: ${item['portName']}'),
                              Text('Type of Call: ${item['typeOfCallName']}'),
                              Text('Vessel Name: ${item['vesselName']}'),
                              Text('Customer Name: ${item['customerName']}'),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: item['status'] == 1
                                ? Colors.blue.shade800
                                : Colors.green.shade700,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item['status'] == 1
                                    ? Icons.access_time
                                    : Icons.check,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                item['status'] == 1 ? 'In Progress' : 'Done',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
