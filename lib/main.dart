import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:ott_platform/res/globals.dart';
import 'package:ott_platform/views/screens/bookmark_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: const Color(0xff345B63),
        primary: const Color(0xff345B63),
        onSecondary: const Color(0xffffffff),
      )),
      routes: {
        '/': (context) => const home(),
        'bookmark': (context) => const BookmarkPage(),
      },
    ),
  );
}

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

late InAppWebViewController inAppWebViewController;
late PullToRefreshController pullToRefreshController;
bool isback = false;
bool isforwer = false;
int select = 0;
int onselect = 0;
double _progress = 0;

class _homeState extends State<home> {
  @override
  void initState() {
    super.initState();
    pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (Platform.isAndroid) {
          await inAppWebViewController.reload();
        } else {
          Uri? uri = await inAppWebViewController.getUrl();
          await inAppWebViewController.loadUrl(
              urlRequest: URLRequest(url: uri));
        }
      },
      options: PullToRefreshOptions(color: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: const Color(0xff345B63),
          title: const Text("OTT Platform", style: TextStyle(fontSize: 15)),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () async {
                  await inAppWebViewController.loadUrl(
                      urlRequest: URLRequest(
                          url: Uri.parse("${Globals.all_websites[0]['uri']}")));
                },
                icon: const Icon(Icons.home)),
            (isback == true)
                ? IconButton(
                    onPressed: () async {
                      select = 0;
                      onselect = 0;
                      if (await inAppWebViewController.canGoBack()) {
                        await inAppWebViewController.goBack();
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios))
                : Container(),
            IconButton(
                onPressed: () async {
                  if (Platform.isIOS) {
                    Uri? uri = await inAppWebViewController.getUrl();
                    await inAppWebViewController.loadUrl(
                        urlRequest: URLRequest(url: uri));
                  } else {
                    await inAppWebViewController.reload();
                  }
                },
                icon: const Icon(Icons.refresh)),
            (isforwer == true)
                ? IconButton(
                    onPressed: () async {
                      if (await inAppWebViewController.canGoForward()) {
                        await inAppWebViewController.goForward();
                      }
                    },
                    icon: const Icon(Icons.arrow_forward_ios_sharp))
                : Container(),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Expanded(
                  child: Container(
                width: double.infinity,
                color: const Color(0xff345B63),
                alignment: Alignment.center,
                child: const Text(
                  "\n\n\nOTT's websites",
                  style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold,color: Colors.white,),
                ),
              )),
              const SizedBox(height: 10),
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFffffff),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Column(
                      children: const [
                        Divider(thickness: 5, color: Color(0xff345B63),),
                        SizedBox(height: 3)
                      ],
                    ),
                    itemCount: Globals.all_websites.length,
                    itemBuilder: (context, i) => InkWell(
                      onTap: () {
                        setState(() {
                          select = i;

                          inAppWebViewController.loadUrl(
                              urlRequest: URLRequest(
                                  url: Uri.parse(
                                      Globals.all_websites[i]['uri'])));
                          Navigator.of(context).pop();
                        });
                      },
                      child: Container(
                        height: 100,
                        alignment: Alignment.center,
                        child: Text(
                          "${Globals.all_websites[i]['name']}",
                          style: TextStyle(
                              color:
                                  (select == i) ? Colors.blue : Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text("Search"),
                            content: TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
                              onChanged: (val) {
                                inAppWebViewController.loadUrl(
                                    urlRequest: URLRequest(
                                        url: Uri.parse(
                                            "https://www.google.co.in/search?q=$val")));
                              },
                            ),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("save"))
                            ],
                          ));
                },
                child: const Icon(Icons.search)),
            const SizedBox(width: 10),
            FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  Uri? uri = await inAppWebViewController.getUrl();
                  Globals.all_uri.add(uri.toString());
                },
                child: const Icon(Icons.bookmark_add)),
            const SizedBox(width: 10),
            FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  Navigator.of(context).pushNamed('bookmark');
                },
                child: const Icon(Icons.bookmark)),
            const SizedBox(width: 10),
            FloatingActionButton(
                heroTag: null,
                onPressed: () async {
                  await inAppWebViewController.stopLoading();
                },
                child: const Icon(Icons.cancel)),
          ],
        ),
        body: Column(
          children: [
            _progress < 1
                ? SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      value: _progress,
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 5),
            Container(
                height: height * 0.87,
                child: InAppWebView(
                  initialOptions: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                          useHybridComposition: true)),
                  pullToRefreshController: pullToRefreshController,
                  initialUrlRequest: URLRequest(
                      url: Uri.parse("${Globals.all_websites[0]['uri']}")),
                  onWebViewCreated: (val) async {
                    inAppWebViewController = val;
                  },
                  onProgressChanged: (controller, i) async {
                    setState(() {
                      _progress = i / 100;
                    });
                    iscanback();

                    if (await inAppWebViewController.canGoForward()) {
                      setState(() {
                        isforwer = true;
                      });
                    } else {
                      setState(() {
                        isforwer = false;
                      });
                    }
                  },
                  onLoadStop: (context, uri) async {
                    await pullToRefreshController.endRefreshing();
                  },
                ))
          ],
        ));
  }

  iscanback() async {
    if (await inAppWebViewController.canGoBack()) {
      setState(() {
        isback = true;
      });
    } else {
      setState(() {
        isback = false;
      });
    }
  }
}
