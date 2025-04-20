
import 'dart:typed_data';

class ComfyuiResponse{
  Uint8List original;
  Uint8List result;

  ComfyuiResponse({required this.result, required this.original});
}