import 'package:flutter/material.dart';
import 'package:flutterauth/about.dart';
import 'package:flutterauth/contact.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutterauth/main.dart';
import 'package:flutterauth/home.dart';

class HomeScreen extends StatefulWidget {
  final String email;

  HomeScreen({required this.email});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalUsers = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.email);
    fetchtotalUser(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 10),
                    FutureBuilder<Map<String, dynamic>>(
                      future: fetchUserData(widget.email),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text(
                            'Error loading user data',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          );
                        } else {
                          final userEmail = snapshot.data?['email'];
                          final firstname = snapshot.data?['first_name'];
                          final lastname = snapshot.data?['last_name'];
                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blueAccent[100],
                                      radius: 30,
                                      backgroundImage:
                                          AssetImage('assets/images/user.png'),
                                    ),
                                    /*   Text(
                                      '$firstname $lastname',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ), */
                                    SizedBox(height: 5),
                                    Text(
                                      '$userEmail',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildListTile('Home', Icons.home, 16, () {
              Navigator.pop(context);
            }),
            _buildListTile('Users', Icons.person_add_alt, 16, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MainMenuScreen(email: widget.email)),
              );
              // Navigate to Attendance screen
            }),
            _buildListTile('About us', Icons.info, 16, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AboutScreen(email: widget.email)),
              );
              // Navigate to Attendance screen
            }),
            _buildListTile('Contact', Icons.contacts, 16, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContactScreen(email: widget.email)),
              );
              // Navigate to Task screen
            }),
            /*   _buildListTile('Settings', Icons.settings, 16, () {
              Navigator.pop(context);
              /*    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => OrganizationScreen(
                  userId: userId,
                )),
      ); */
              // Navigate to Organization screen
            }), */
            _buildListTile('Logout', Icons.exit_to_app, 16, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            }),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to My Screen',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Logged in as: ${widget.email}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Users',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '$_totalUsers',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> fetchUserData(String email) async {
    final url = 'https://flutter-auth.devbackyard.com/user_data.php';
    final response = await http.get(Uri.parse('$url?email=$email'));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['users'].first; // Assuming only one user is returned
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> fetchtotalUser(String email) async {
    final url = 'https://flutter-auth.devbackyard.com/get_users.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as List;
      print(responseData); // Print the response data for debugging
      setState(() {
        _totalUsers = responseData.length;
      });
    } else {
      print(response.body); // Print the response body in case of error
      throw Exception('Failed to load user data');
    }
  }

  Widget _buildListTile(
      String title, IconData iconData, double fontSize, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(
            iconData,
            color: Colors.black,
          ), // Add the icon as the leading widget
          title: Text(
            title,
            style: TextStyle(fontSize: fontSize), // Set the font size
          ), // Display the title without Center widget
          onTap: onTap,
        ),
      ),
    );
  }
}
