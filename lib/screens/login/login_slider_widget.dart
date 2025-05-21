import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


// 슬라이더 형식 위젯 참고 예제
// 슬라이더 형식 위젯 참고 예제
// 슬라이더 형식 위젯 참고 예제
// 슬라이더 형식 위젯 참고 예제
// 슬라이더 형식 위젯 참고 예제

class LoginSliderWidget extends StatefulWidget {
  const LoginSliderWidget({super.key});

  @override
  State<LoginSliderWidget> createState() => _LoginSliderWidgetState();
}

class _LoginSliderWidgetState extends State<LoginSliderWidget> {
  int _current = 0;

  final CarouselSliderController _controller = CarouselSliderController();

  List imageList = [
    "https://cdn.pixabay.com/photo/2014/04/14/20/11/pink-324175_1280.jpg",
    "https://cdn.pixabay.com/photo/2014/02/27/16/10/flowers-276014_1280.jpg",
    "https://cdn.pixabay.com/photo/2012/03/01/00/55/flowers-19830_1280.jpg",
    "https://cdn.pixabay.com/photo/2015/06/19/20/13/sunset-815270_1280.jpg",
    "https://cdn.pixabay.com/photo/2016/01/08/05/24/sunflower-1127174_1280.jpg",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Slide'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                sliderWidget(),
                sliderIndicator(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text("Welcome to the carousel slide app", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  Widget sliderWidget() {
    return CarouselSlider(
      carouselController: _controller,
      items: imageList.map(
        (imgLink) {
          return Builder(
            builder: (context) {
              return SizedBox(
                // width: MediaQuery.of(context).size.width,
                child: Image(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                    imgLink,
                  ),
                ),
              );
            },
          );
        },
      ).toList(),
      options: CarouselOptions(
        height: 300,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        onPageChanged: (index, reason) {
          setState(() {
            _current = index;
          });
        },
      ),
    );
  }

  Widget sliderIndicator() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imageList.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => _controller.animateToPage(entry.key),
            child: Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(_current == entry.key ? 0.9 : 0.4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
