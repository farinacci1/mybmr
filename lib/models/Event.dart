class MyEvent {
  String _id;
  DateTime _startDate;
  DateTime _endDate;
  String _title;
  String _description;
  String get id => _id;
  String get description => _description;
  String get title => _title;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  void set id (String id){
    _id = id;
  }
  MyEvent({
    String id,
    String title,
    String description,
    DateTime startDate,
    DateTime endDate,

  })  : _id = id,
        _title = title,
        _description = description,
        _startDate = startDate,
        _endDate = endDate;

  MyEvent.fromJson({Map<String, dynamic> data, String id}) {
    _id = id;
    _startDate = DateTime.fromMillisecondsSinceEpoch( data["startDate"]);
    _endDate = DateTime.fromMillisecondsSinceEpoch( data["endDate"]);
    _title = data["title"];
    _description = data["description"];

  }

  Map<String,dynamic> toJSON() {
    Map<String, dynamic> data = {
      "startDate": _startDate.millisecondsSinceEpoch,
      "endDate": _endDate.millisecondsSinceEpoch,
      "title": _title,
      "description": _description,
    };
    return data;
  }
}
