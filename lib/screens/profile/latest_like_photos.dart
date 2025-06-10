import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/services/photo_manager_service/photo_manager_api.dart';

import '../../models/user.dart';
import '../../services/photo_store_service/photo_store_api.dart';
import '../../services/user_manager_service/user_api.dart';
import '../../utils/functions.dart';

class LatestLikePhotos extends StatefulWidget {
  const LatestLikePhotos({super.key});

  @override
  State<LatestLikePhotos> createState() => _LatestLikePhotosState();
}

class _LatestLikePhotosState extends State<LatestLikePhotos> {
  List<Photo> latestLikePhotos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      latestLikePhotos.addAll(await PhotoManagerApi().getLikePhotos());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (latestLikePhotos.isEmpty) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            // boxShadow: [BoxShadow(blurRadius: 1, spreadRadius: 0.5, color: Colors.grey)],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "좋아요 누른 사진이 없습니다.",
              style: TextStyle(fontSize: 11, color: Colors.grey, fontFamily: "NotoSansKR", fontWeight: FontWeight.w400),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left : 8.0),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height * 0.25,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
          ),
          itemCount: latestLikePhotos.length,
          itemBuilder: (context, idx) {
            return _getLikePhotoTile(context, idx);
          },
        ),
      ),
    );
  }

  Widget _getLikePhotoTile(BuildContext context, int idx) {
    return FutureBuilder(
      future: PhotoStoreApi().downloadPhoto(photoId: latestLikePhotos[idx].photoId, scale: 0.3),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Icon(Icons.error, size: 100, color: Colors.red);
        }
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: () async {
              User? user = await UserManagerApi().getUserByUserId(userId: latestLikePhotos[idx].userId!);
              BoxFit fit = await determineFit(snapshot.data!);
              Get.toNamed("/photo", arguments: {
                "user": user!,
                "photo": latestLikePhotos[idx],
                "data": snapshot.data!,
                "fit": fit,
              });
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
