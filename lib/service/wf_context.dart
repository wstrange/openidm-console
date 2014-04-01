
part of oi_service;

int wfid = 0;

class WFContext {

  Map<String,dynamic> variables = {};

  var created = new DateTime.now();


  int id;

  WFContext() {
    id = wfid;
    ++wfid;
  }

  String toString() => "$id variables=$variables created=$created";

}