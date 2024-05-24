class Student {
  int id=0;
  String name="";
  Student(this.id, this.name);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
    };
    return map;
  }

  Student.fromMap(Map<dynamic, dynamic> map) {
    id = map['id'];
    name = map['name'];
  }
}