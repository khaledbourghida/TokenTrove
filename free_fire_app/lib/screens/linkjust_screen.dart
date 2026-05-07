import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:free_fire_app/screens/tokens_screen.dart';

class LinkJustScreen extends StatefulWidget {
  const LinkJustScreen({super.key});

  @override
  State<LinkJustScreen> createState() => _LinkJustScreenState();
}

class _LinkJustScreenState extends State<LinkJustScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String _lang = 'en';
  bool loading = false;
  bool beingLaunche = false;
  Map<String, dynamic>? isTaskDone;
  Map<String, dynamic>? urls;

  void fetchData() async {
    setState(() {
      loading = true;
    });

    final idToken = await user!.getIdToken();

    print('idToken = ${idToken} ===========');

    final uid = user!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final urlDoc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('shortedUrl')
        .get();

    final data = doc.data();
    final urlData = urlDoc.data();

    final String lang = data?['settings']?['language'] ?? 'en';

    setState(() {
      _lang = lang;
      isTaskDone = data?['taskState'];
      urls = urlData?['url'];
      loading = false;
    });
  }

  void launcheUrl(String url, bool isDone) async {
    if (isDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tr('alreadydone')),
          backgroundColor: Color(0xFFFF4500),
        ),
      );
      return;
    } else {
      setState(() {
        beingLaunche = true;
      });
    }
  }

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final secondary = Color(0xFF1E90FF);
    final background = Color(0xFF1C1C1C);
    final textColor = Color(0xFFF0F0F0);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: secondary))
          : ListView(
              children: [
                SizedBox(height: 60),
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isTaskDone!['link1']
                                  ? Colors.green
                                  : Colors.red,
                              border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: isTaskDone!['link1']
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_tr('task')} 1',
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      205,
                                      204,
                                      204,
                                    ),
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  taskInfo(3),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontFamily: 'Roboco',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TokensScreen(),
                                ),
                              );
                            },
                            child: Icon(
                              _lang == 'ar'
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              size: 50,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 1,
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isTaskDone!['link2']
                                  ? Colors.green
                                  : Colors.red,
                              border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: isTaskDone!['link2']
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_tr('task')} 2',
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      205,
                                      204,
                                      204,
                                    ),
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  taskInfo(6),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontFamily: 'Roboco',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TokensScreen(),
                                ),
                              );
                            },
                            child: Icon(
                              _lang == 'ar'
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              size: 50,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 1,
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isTaskDone!['link3']
                                  ? Colors.green
                                  : Colors.red,
                              border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: isTaskDone!['link3']
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_tr('task')} 3',
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      205,
                                      204,
                                      204,
                                    ),
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  taskInfo(6),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontFamily: 'Roboco',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TokensScreen(),
                                ),
                              );
                            },
                            child: Icon(
                              _lang == 'ar'
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              size: 50,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 1,
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isTaskDone!['link4']
                                  ? Colors.green
                                  : Colors.red,
                              border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: isTaskDone!['link4']
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_tr('task')} 4',
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      205,
                                      204,
                                      204,
                                    ),
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  taskInfo(10),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontFamily: 'Roboco',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TokensScreen(),
                                ),
                              );
                            },
                            child: Icon(
                              _lang == 'ar'
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              size: 50,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 1,
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 20),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isTaskDone!['link5']
                                  ? Colors.green
                                  : Colors.red,
                              border: Border.all(width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: isTaskDone!['link5']
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_tr('task')} 5',
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      205,
                                      204,
                                      204,
                                    ),
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  taskInfo(10),
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                    fontFamily: 'Roboco',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TokensScreen(),
                                ),
                              );
                            },
                            child: Icon(
                              _lang == 'ar'
                                  ? Icons.chevron_left
                                  : Icons.chevron_right,
                              size: 50,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 1,
                      margin: EdgeInsets.symmetric(horizontal: 50),
                      color: Colors.grey[700],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
    );
  }

  String _tr(String key) {
    final isAr = _lang == 'ar';
    switch (key) {
      case 'task':
        return isAr ? '' : 'Task';
      case 'alreadydone':
        return isAr ? '' : 'You are already do this task';
      default:
        return key;
    }
  }

  String taskInfo(int token) {
    final isAr = _lang == 'ar';
    return isAr ? '' : 'you wil get ${token} tokens';
  }
}
