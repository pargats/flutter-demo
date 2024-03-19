import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/article.dart';
import 'package:flutter_demo/firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(colorScheme: const ColorScheme.dark()),
      title: 'Basic News',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Query articles = db
        .collection('articles')
        .orderBy('timestamp', descending: true)
        .withConverter<Article>(
          fromFirestore: Article.fromFirestore,
          toFirestore: (Article a, _) => a.toFirestore(),
        );

    return FutureBuilder<QuerySnapshot>(
      future: articles.get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No articles were available");
        }
        var articles =
            snapshot.data!.docs.map((e) => e.data() as Article).toList();
        var count = articles.length;
        return Scaffold(
            body: Center(
                child: ListView.builder(
          itemCount: count,
          itemBuilder: (BuildContext context, int index) {
            final item = articles[index];
            return Container(
              margin: EdgeInsets.fromLTRB(
                  16, 8.0, 16, index == count - 1 ? 48.0 : 8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () => launchUrlString(item.url),
                child: Row(
                  children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.headline,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                            DateFormat.MMMMd()
                                .add_jm()
                                .format(item.timestamp.toDate()),
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 8),
                      ],
                    )),
                    Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(item.imageUrl),
                            ))),
                  ],
                  //
                ),
              ),
            );
          },
        )));
      },
    );
  }
}
