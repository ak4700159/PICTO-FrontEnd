class Notice {
  int noticeId;
  int senderId;
  int folderId;
  int createDatetime;
  String folderName;
  String type;

  Notice(
      {required this.folderId,
      required this.folderName,
      required this.type,
      required this.createDatetime,
      required this.noticeId,
      required this.senderId});

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
        folderId: json["folderId"],
        folderName: json["folderName"],
        type: json["type"],
        createDatetime: json["createDatetime"],
        noticeId: json["noticeId"],
        senderId: json["senderId"]);
  }
}
