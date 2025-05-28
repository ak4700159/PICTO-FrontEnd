import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picto_frontend/config/app_config.dart';
import 'package:picto_frontend/models/photo.dart';
import 'package:picto_frontend/services/photo_manager_service/photo_manager_api.dart';

class LikeButton extends StatefulWidget {
  const LikeButton({super.key, required this.photoId, required this.likes});
  final int photoId;
  final int likes;

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  late bool isClicked;
  late int currentLikes;
  late Photo photo;

  bool? isInit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentLikes = widget.likes;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool? val = await PhotoManagerApi().checkPhotoLike(photoId: widget.photoId);
      currentLikes = (await PhotoManagerApi().getPhoto(photoId: widget.photoId))?.likes ?? -1;
      setState(() {
        isInit = val;
        isClicked = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int photoId = widget.photoId;
    return isInit == null
        ? SizedBox(
            height: context.mediaQuery.size.width,
            width: context.mediaQuery.size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Center(
                  child: SizedBox(
                      height: context.mediaQuery.size.width / 10,
                      width: context.mediaQuery.size.width / 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey,
                      )),
                ),
              ],
            ),
          )
        : SizedBox(
            // color: Colors.red,
            height: context.mediaQuery.size.width / 5,
            width: context.mediaQuery.size.width / 5,
            child: Column(
              children: [
                IconButton(
                  onPressed: () async {
                    bool result = await PhotoManagerApi().clickLike(photoId: photoId);
                    if (result) {
                      setState(() {
                        if (isClicked) {
                          currentLikes--;
                        } else {
                          currentLikes++;
                        }
                        isClicked = !isClicked;
                      });
                    }
                  },
                  icon: isClicked
                      ? Icon(
                          Icons.favorite,
                          color: AppConfig.mainColor,
                        )
                      : Icon(
                          Icons.favorite_border,
                          color: Colors.grey,
                        ),
                ),
                Text(
                  '$currentLikes',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "NotoSansKR",
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
  }
}
