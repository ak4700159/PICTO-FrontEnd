class LocationMsg {
  LocationMsg(
      {required this.messageType,
      required this.senderId,
      required this.lat,
      required this.lng,
      required this.sendDatetime});

  final String messageType;
  final int senderId;
  final double lat;
  final double lng;
  final int sendDatetime;

  factory LocationMsg.fromJson(Map<String, dynamic> json) => LocationMsg(
        messageType: json["messageType"] as String,
        senderId: json["senderId"] as int,
        lat: json["lat"] as double,
        lng: json["lng"] as double,
        sendDatetime: json["sendDatetime"] as int,
      );

  Map<String, dynamic> toJson() => {
        "messageType": messageType,
        "senderId": senderId,
        "lat": lat,
        "lng": lng,
        "sendDatetime": sendDatetime,
      };
}
