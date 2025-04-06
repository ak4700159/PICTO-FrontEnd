import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String?> fetchAddressFromKakao({
  required double latitude,
  required double longitude,
}) async {
  final dio = Dio();
  final apiKey = dotenv.env['KAKAO_API_KEY'];

  if (apiKey == null) {
    print('[ERROR] Kakao API key is not set in .env');
    return null;
  }

  final url =
      'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$longitude&y=$latitude&input_coord=WGS84';

  try {
    final response = await dio.get(
      url,
      options: Options(
        headers: {
          'Authorization': 'KakaoAK $apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = KakaoLocationResponse.fromJson(response.data);
      final addressName = data.documents.first.address?.addressName;
      return addressName;
    } else {
      print('[ERROR] Kakao API response code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('[ERROR] Failed to fetch Kakao address: $e');
    return null;
  }
}


class KakaoLocationResponse {
  final List<Document> documents;

  KakaoLocationResponse({required this.documents});

  factory KakaoLocationResponse.fromJson(Map<String, dynamic> json) {
    return KakaoLocationResponse(
      documents: (json['documents'] as List<dynamic>)
          .map((doc) => Document.fromJson(doc))
          .toList(),
    );
  }
}

class Document {
  final Address? address;

  Document({this.address});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
    );
  }
}

class Address {
  final String addressName;
  final String region1depthName;
  final String region2depthName;
  final String region3depthName;

  Address({
    required this.addressName,
    required this.region1depthName,
    required this.region2depthName,
    required this.region3depthName,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressName: json['address_name'],
      region1depthName: json['region_1depth_name'],
      region2depthName: json['region_2depth_name'],
      region3depthName: json['region_3depth_name'],
    );
  }
}

