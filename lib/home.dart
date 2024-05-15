import 'dart:convert';
import 'package:flutterauth/contact.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutterauth/main.dart';
import 'package:flutterauth/welcome.dart';
import 'package:flutterauth/about.dart';

class MainMenuScreen extends StatefulWidget {
  final String email;

  MainMenuScreen({required this.email});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<Map<String, dynamic>> usersData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu'),
        /*   automaticallyImplyLeading: false, */
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
            /*    _buildListTile('Settings', Icons.settings, 16, () {
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
      body: Container(
        padding: EdgeInsets.all(16.0),
        height: MediaQuery.of(context).size.height - kToolbarHeight - 80,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              usersData.isEmpty
                  ? Text('No data available for this user')
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Password')),
                            DataColumn(label: Text('Actions')),
                          ],
                          columnSpacing: 10,
                          dataRowHeight: 50,
                          rows: usersData
                              .map(
                                (user) => DataRow(
                                  cells: [
                                    DataCell(Text(user['id'].toString())),
                                    DataCell(Text(user['email'])),
                                    DataCell(Text('*****')),
                                    DataCell(Container(
                                      width: 100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              showEditModal(user);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              showDeleteConfirmation(
                                                  user['id']);
                                              // Implement delete functionality
                                            },
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 5,
                            child: Container(
                              height: 300,
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: Text(
                                      'Create User',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: emailController,
                                    decoration:
                                        InputDecoration(labelText: 'Email'),
                                  ),
                                  TextField(
                                    controller: passwordController,
                                    decoration:
                                        InputDecoration(labelText: 'Password'),
                                    obscureText: true,
                                  ),
                                  SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        createUser();
                                      },
                                      child: Text('Create User'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text('Create User', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createUser() async {
    final url = 'https://flutter-auth.devbackyard.com/create.php';
    final Map<String, dynamic> data = {
      'email': emailController.text,
      'password': passwordController.text,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        final user = responseData['user'];
        setState(() {
          usersData.add(user);
        });
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('User Created'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Email: ${user['email']}'),
                Text('Password:${user['password']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
        emailController.clear();
        passwordController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create user')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
  }

  void showEditModal(Map<String, dynamic> user) {
    final TextEditingController editEmailController =
        TextEditingController(text: user['email']);
    final TextEditingController editPasswordController =
        TextEditingController(text: user['password']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Container(
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: editEmailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: editPasswordController,
                  decoration: InputDecoration(labelText: 'New Password'),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      editUser(
                        user['id'],
                        editEmailController.text,
                        editPasswordController.text,
                      );
                    },
                    child: Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteConfirmation(int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteUser(userId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteUser(int id) async {
    final url = 'https://flutter-auth.devbackyard.com/delete.php';
    final Map<String, dynamic> data = {
      'id': id,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        setState(() {
          usersData.removeWhere((user) => user['id'] == id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
  }

  Future<void> editUser(int id, String email, String password) async {
    final url = 'https://flutter-auth.devbackyard.com/edit.php';
    final Map<String, dynamic> data = {
      'id': id,
      'email': email,
      'password': password,
    };
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        setState(() {
          final index = usersData.indexWhere((user) => user['id'] == id);
          if (index != -1) {
            usersData[index]['email'] = email;
            usersData[index]['password'] = password;
          }
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User edited successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to edit user')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error: ${response.statusCode}')),
      );
    }
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
