import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save image to gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PermissionHandler().requestPermissions(<PermissionGroup>[
      PermissionGroup.storage, // 在这里添加需要的权限
    ]);
  }

  Dio dio = new Dio();
  int i = 1;
  double percent = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Save image to gallery"),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.red,
                  child: Center(
                      child: Text(
                    "data@$i",
                    style: TextStyle(fontSize: 18),
                  )),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: RaisedButton(
                  onPressed: _saved,
                  child: Text("保存到相册@$percent%"),
                ),
                height: 50,
              )
            ],
          ),
        ));
  }

  String savePath;
  String urlPath = "https://github.com/fck78315/image_gallery_saver/raw/master/example/%E9%9A%BE%E9%81%93%E4%B8%8D%E6%98%AF%E8%BF%99%E6%9D%A1%E8%A1%97%E6%9C%80%E8%80%80%E7%9C%BC%E7%9A%84%E7%A9%BA%E7%BF%BB%EF%BC%9F.mp4";

  _saved() async {
    //设置文件的名称
    var basename = path.basename(Uri.parse(urlPath).path);
    ImageGallerySaver.saveVideo("houkongfan.mp4", Download);
  }

  Future<File> Download() async {
    //设置文件的名称
    var basename = path.basename(Uri.parse(urlPath).path);
    var tmpfilepath = (await getTemporaryDirectory()).path + "/$basename";
    await dio.download(urlPath, tmpfilepath,
        onReceiveProgress: (int count, int total) {
      print("下载进度: $count/$total,savePath:$tmpfilepath");
      percent = (count / total) * 100;
      setState(() {});
    }).then((e) {
      print("下载完毕");
      setState(() {});
    });
    return File(tmpfilepath);
  }
}
