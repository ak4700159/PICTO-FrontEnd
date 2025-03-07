import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: context.mediaQuery.size.width,
                height: context.mediaQuery.size.height * 0.3,
                color: Theme.of(context).colorScheme.primaryFixed,
                child: Center(child: Text("test color")),
              )
            ],
          ),
        ],
      ),
    );
  }
}
