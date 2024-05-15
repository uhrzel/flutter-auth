import 'dart:convert';
import 'package:flutterauth/contact.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutterauth/main.dart';
import 'package:flutterauth/welcome.dart';
import 'package:flutterauth/home.dart';

class AboutScreen extends StatefulWidget {
  final String email;

  AboutScreen({required this.email});

  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  List<Map<String, dynamic>> usersData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
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
                      future: fetchUserData(widget.email), // Fetch user data
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
              // Navigate to Home screen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(email: widget.email)),
              );
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
            _buildListTile('About Us', Icons.info, 16, () {
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
                    builder: (context) => ContactScreen(
                          email: widget.email,
                        )),
              );
              // Navigate to Task screen
            }),
            /*     _buildListTile('Settings', Icons.settings, 16, () {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Us',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Welcome! Our app prioritizes secure authentication and streamlined user registration. With robust features, we ensure your data safety while providing seamless access to our services, enhancing productivity and efficiency.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Our Team',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/gojo.jpg'),
              ),
              title: Text('Gojo Satoru'),
              subtitle: Text('Lead Developer'),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/yuki.jpg'),
              ),
              title: Text('Yuki Tsukumo'),
              subtitle: Text('UI/UX Designer'),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/toji.jfif'),
              ),
              title: Text('Toji Zenin'),
              subtitle: Text('Backend Developer'),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/images/yuta.jpeg'),
              ),
              title: Text('Yuta Okkutso'),
              subtitle: Text('Front End Developer'),
            ),
            SizedBox(height: 20),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text('contact@gmail.com'),
              onTap: () {
                // Implement email functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text('+1234567890'),
              onTap: () {
                // Implement phone functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserData(widget.email);
    fetchUsersData();
  }

  Future<void> fetchUsersData() async {
    final url = 'https://flutter-auth.devbackyard.com/get_users.php';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        usersData = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load users data');
    }
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
