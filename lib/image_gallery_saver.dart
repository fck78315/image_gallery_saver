import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;

import 'package:flutter/services.dart';

/// Signature of callbacks that have no arguments and return no data.
typedef FileCallback = Future<File> Function();

class ImageGallerySaver {
  static const MethodChannel _channel =
      const MethodChannel('image_gallery_saver');

  /// save image to Gallery
  /// imageBytes can't null
  static Future save(Uint8List imageBytes) async {
    assert(imageBytes != null);
    final result =
        await _channel.invokeMethod('saveImageToGallery', imageBytes);
    return result;
  }

  /// 保存视频到相册
  static Future scanFile(String filepath) async {
    assert(filepath != null);
    final result =
        await _channel.invokeMethod('scanFile', {"filepath": filepath});
    return result;
  }

  //获取相册的路径
  static Future<String> getDcimPath() async {
    return await _channel.invokeMethod('getDcimPath', {});
  }

  //把文件视频直接存储到 相册
  static Future<bool> saveVideo(
      String basename, FileCallback downloadfile) async {
    //得到临时文件
    File tmpfile = await downloadfile();

    String savePath;
    String dic = await ImageGallerySaver.getDcimPath();
    String dic_path = path.dirname(dic);
    //常规的路径
    final String dirPath = '${dic_path}/DCIM/Camera/';
    //1:判断中文名字的路径存在
    final String dirPath_fuckvivo = '${dic_path}/相机/';
    if (Directory(dirPath_fuckvivo).existsSync()) {
      savePath = dirPath_fuckvivo + basename;
    } else if (Directory(dirPath).existsSync()) {
      //2:判断正常的路径存在
      savePath = dirPath + basename;
    } else {
      print("什么狗屁手机?");
      return false;
    }

    tmpfile.copySync(savePath);
    if (File(savePath).existsSync()) {
      tmpfile.deleteSync();
    }
    ImageGallerySaver.scanFile(savePath);
    return true;
  }
}
