import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:file_picker/file_picker.dart';
import 'service/database.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool today = true, tomorrow = false, nextWeek = false;
  Stream<QuerySnapshot>? todoStream;
  TextEditingController todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
  }

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  Future<void> getOnTheLoad() async {
    final stream = await DatabaseMethod().getAllWork(
        today ? "Today" : tomorrow ? "Tomorrow" : "Next Week");
    setState(() {
      todoStream = stream;
    });
  }

  Widget allWork() {
    return StreamBuilder<QuerySnapshot>(
      stream: todoStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data!.docs[index];
              Map<String, dynamic>? data =
              ds.data() as Map<String, dynamic>?;

              if (data?.containsKey('Yes') ?? false) {
                bool? value = data?['Yes'] as bool?;
                return CheckboxListTile(
                  activeColor: Color(0xff279cfb),
                  title: Text(
                    data?['Work'] ?? "",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w400),
                  ),
                  value: value ?? false,
                  onChanged: (newValue) async {
                    String id = ds.id;
                    String day =
                    today ? "Today" : tomorrow ? "Tomorrow" : "Next Week";
                    await DatabaseMethod()
                        .updateIfTicked(id, day, newValue!);
                    setState(() {
                      // Update UI here if needed
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              } else {
                return ListTile(
                  title: Text(
                    data?['Work'] ?? "",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.0,
                        fontWeight: FontWeight.w400),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () async {
                      // Retrieve download URL from Firestore
                      String downloadURL = data?['DownloadURL'];

                      if (downloadURL != null && downloadURL.isNotEmpty) {
                        // Open download link in the default browser
                        if (await canLaunch(downloadURL)) {
                          await launch(downloadURL);
                        } else {
                          // Handle case where the URL cannot be launched
                          print('Could not launch $downloadURL');
                        }
                      } else {
                        // Handle case where download URL is not available
                        print("Download URL not found");
                      }
                    },
                  ),
                );
              }
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> openBox() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.cancel),
                    ),
                    SizedBox(width: 30.0),
                    Text(
                      'Add the work TODO',
                      style: TextStyle(color: Color(0xff008080)),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Text("Add text"),
                SizedBox(height: 10.0),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black38,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: todoController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Text ",
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    String id = randomAlphaNumeric(10);
                    Map<String, dynamic> userTodo = {
                      "Work": todoController.text,
                      "Id": id,
                      "Yes": false,
                    };
                    String day =
                    today ? "Today" : tomorrow ? "Tomorrow" : "Next Week";
                    await DatabaseMethod().addWork(userTodo, day);
                    Navigator.pop(context);
                  },
                  child: Text("Add"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                    await FilePicker.platform.pickFiles();
                    if (result != null) {
                      File file = File(result.files.single.path!);
                      String fileName = "your_file_name";
                      try {
                        String downloadURL = await DatabaseMethod()
                            .uploadFile(file, fileName);
                        print(
                            "File uploaded successfully. Download URL: $downloadURL");
                      } catch (e) {
                        print("Error uploading file: $e");
                      }
                    } else {
                      // User canceled the file picker
                    }
                  },
                  child: Text("Upload File"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: openBox,
        child: Icon(
          Icons.add,
          color: Color(0XFF249fff),
          size: 30.0,
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(top: 90.0, left: 30.0),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue,
              Color(0xFF13D8CA),
              Color(0xFF3dffe3),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello\nIkram",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Good Morning",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        today = true;
                        tomorrow = false;
                        nextWeek = false;
                        getOnTheLoad();
                      });
                    },
                    child: Text(
                      "Today",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: today ? Colors.blue : Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        today = false;
                        tomorrow = true;
                        nextWeek = false;
                        getOnTheLoad();
                      });
                    },
                    child: Text(
                      "Tomorrow",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: tomorrow ? Colors.blue : Colors.grey,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        today = false;
                        tomorrow = false;
                        nextWeek = true;
                        getOnTheLoad();
                      });
                    },
                    child: Text(
                      "Next Week",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: nextWeek ? Colors.blue : Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              allWork(),
            ],
          ),
        ),
      ),
    );
  }
}
