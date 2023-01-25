import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../main.dart';
import '../../res/globals.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Book Mark")),
        body: ListView.separated(
            separatorBuilder: (context, index) => Column(
                  children: const [
                    Divider(thickness: 5, color: Color(0xff345B63)),
                    SizedBox(height: 20)
                  ],
                ),
            itemCount: Globals.all_uri.length,
            itemBuilder: (context, i) {
              int item = i;
              item = ++item;
              return ListTile(
                leading: CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xffA5C9CA),
                  child: Text(
                    "${item}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: GestureDetector(
                  onTap: () {
                    inAppWebViewController.loadUrl(
                        urlRequest: URLRequest(
                            url: Uri.parse("${Globals.all_uri[i]}")));
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "${Globals.all_uri[i]}",
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        Globals.all_uri.remove(Globals.all_uri[i]);
                      });
                    },
                    icon: const Icon(Icons.delete)),
              );
            }));
  }
}
