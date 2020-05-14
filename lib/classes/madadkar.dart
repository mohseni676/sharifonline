class madadkarInfo {
  String madadkarName;
  int madadkarId;
  String sipWsUrl;
  String sipUrl;
  String sipDisplayname;
  String sipPassword;
  String sipExtention;

  //String ipAddress;

  madadkarInfo(
      {this.madadkarName,
      this.madadkarId,
      this.sipWsUrl,
      this.sipUrl,
      this.sipDisplayname,
      this.sipPassword,
      this.sipExtention});

  madadkarInfo.fromJson(Map<String, dynamic> json) {
    madadkarName = json['MadadkarName'];
    madadkarId = json['MadadkarId'];
    sipWsUrl = json['SipWsUrl'];
    sipUrl = json['SipUrl'];
    sipDisplayname = json['SipDisplayname'];
    sipPassword = json['SipPassword'];
    sipExtention = json['SipExtention'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MadadkarName'] = this.madadkarName;
    data['MadadkarId'] = this.madadkarId;
    data['SipWsUrl'] = this.sipWsUrl;
    data['SipUrl'] = this.sipUrl;
    data['SipDisplayname'] = this.sipDisplayname;
    data['SipPassword'] = this.sipPassword;
    data['SipExtention'] = this.sipExtention;
    return data;
  }
}
