import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutterauth/main.dart';
import 'package:http/http.dart' as http;

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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
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
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          height: 300,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: emailController,
                                decoration: InputDecoration(labelText: 'Email'),
                              ),
                              TextField(
                                controller: passwordController,
                                decoration:
                                    InputDecoration(labelText: 'Password'),
                                obscureText: true,
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  createUser();
                                },
                                child: Text('Create User'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createUser() async {
    final url = 'http://192.168.254.159:8080/auth/create.php';
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
                ElevatedButton(
                  onPressed: () {
                    editUser(user['id'], editEmailController.text,
                        editPasswordController.text);
                  },
                  child: Text('Save Changes'),
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
    final url = 'http://192.168.254.159:8080/auth/delete.php';
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
    final url = 'http://192.168.254.159:8080/auth/edit.php';
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
  }

  Future<void> fetchUserData(String email) async {
    final url = 'http://192.168.254.159:8080/auth/user_data.php';
    final response = await http.get(Uri.parse('$url?email=$email'));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        usersData = responseData['users'];
      });
    } else {
      // Handle error
    }
  }
}
