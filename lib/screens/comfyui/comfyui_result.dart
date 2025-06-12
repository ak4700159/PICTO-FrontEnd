import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:picto_frontend/screens/comfyui/comfyui_view_model.dart';
import 'package:picto_frontend/utils/functions.dart';

class ComfyuiResult extends StatefulWidget {
  final Uint8List originalImage;
  final Uint8List upscaledImage;

  const ComfyuiResult({
    super.key,
    required this.originalImage,
    required this.upscaledImage,
  });

  @override
  State<ComfyuiResult> createState() => _ComfyuiResultState();
}

class _ComfyuiResultState extends State<ComfyuiResult> with TickerProviderStateMixin {
  late AnimationController _splitController;
  late AnimationController _scaleController;

  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _splitController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _splitController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _splitController.forward();

    // 끝났을 때 확대 애니메이션 실행
    _splitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scaleController.forward().then((_) {
          _scaleController.reverse(); // 원래대로 축소
        });
      }
    });
  }

  @override
  void dispose() {
    _splitController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double fullWidth = MediaQuery.of(context).size.width * 0.9;
    return SizedBox(
      width: fullWidth,
      height: fullWidth,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 업스케일링 이미지 + 확대 애니메이션
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: GestureDetector(
                    onTap: () async {
                      // final comfyuiViewModel = Get.find<ComfyuiViewModel>();
                      // comfyuiViewModel.reset();
                      final fit = await determineFit(widget.upscaledImage);
                      Get.toNamed('/comfyui/photo', arguments: {
                        "fit": fit,
                        "data": widget.upscaledImage,
                      });
                    },
                    child: Image.memory(
                      widget.upscaledImage,
                      fit: BoxFit.cover,
                      width: fullWidth,
                      height: fullWidth,
                    ),
                  ),
                );
              },
            ),

            // 원본 이미지
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                double visibleWidth = -1 * fullWidth * (_progressAnimation.value - 1.0);
                return Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: SizedBox(
                      width: fullWidth - visibleWidth,
                      height: fullWidth,
                      child: OverflowBox(
                        maxWidth: fullWidth,
                        maxHeight: fullWidth,
                        alignment: Alignment.centerRight,
                        child: Opacity(
                          opacity: 0.9,
                          child: Image.memory(
                            widget.originalImage,
                            fit: BoxFit.cover,
                            width: fullWidth,
                            height: fullWidth,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // 중앙선
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                double lineX = fullWidth * (1 - _progressAnimation.value) - 1;
                return Positioned(
                  left: lineX,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Colors.white.withOpacity(0.8),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
