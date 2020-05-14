class HamisInfo {
  int hamiMadadkarId;
  int hamiId;
  int madadkarId;
  bool deleted;
  int madadkarCode;
  String madadkarLName;
  String madadkarFName;
  String madadkarPhone;
  String madadkarMobile;
  String madadkarMobile2;
  String hamiCode;
  String hamiLName;
  String hamiFName;
  String hamiMobile1;
  String hamiMobile2;

  HamisInfo(
      {this.hamiMadadkarId,
      this.hamiId,
      this.madadkarId,
      this.deleted,
      this.madadkarCode,
      this.madadkarLName,
      this.madadkarFName,
      this.madadkarPhone,
      this.madadkarMobile,
      this.madadkarMobile2,
      this.hamiCode,
      this.hamiLName,
      this.hamiFName,
      this.hamiMobile1,
      this.hamiMobile2});

  HamisInfo.fromJson(Map<String, dynamic> json) {
    hamiMadadkarId = json['HamiMadadkarId'];
    hamiId = json['HamiId'];
    madadkarId = json['MadadkarId'];
    deleted = json['Deleted'];
    madadkarCode = json['MadadkarCode'];
    madadkarLName = json['MadadkarLName'];
    madadkarFName = json['MadadkarFName'];
    madadkarPhone = json['MadadkarPhone'];
    madadkarMobile = json['MadadkarMobile'];
    madadkarMobile2 = json['MadadkarMobile2'];
    hamiCode = json['HamiCode'];
    hamiLName = json['HamiLName'];
    hamiFName = json['HamiFName'];
    hamiMobile1 = json['HamiMobile1'];
    hamiMobile2 = json['HamiMobile2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['HamiMadadkarId'] = this.hamiMadadkarId;
    data['HamiId'] = this.hamiId;
    data['MadadkarId'] = this.madadkarId;
    data['Deleted'] = this.deleted;
    data['MadadkarCode'] = this.madadkarCode;
    data['MadadkarLName'] = this.madadkarLName;
    data['MadadkarFName'] = this.madadkarFName;
    data['MadadkarPhone'] = this.madadkarPhone;
    data['MadadkarMobile'] = this.madadkarMobile;
    data['MadadkarMobile2'] = this.madadkarMobile2;
    data['HamiCode'] = this.hamiCode;
    data['HamiLName'] = this.hamiLName;
    data['HamiFName'] = this.hamiFName;
    data['HamiMobile1'] = this.hamiMobile1;
    data['HamiMobile2'] = this.hamiMobile2;
    return data;
  }
}
