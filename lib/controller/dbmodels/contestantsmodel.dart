class StudentModel {
  final String id;
  final String studentid;
  final String name;
  final String sex;
  final String school;
  final String region;
  final List<String> guardiancontact;
  final List<String> parentname;
  final String level;
  final String department;
  final String term;
  final String schoolId;
  final String dob;
  final String address;
  final String? email;
  final String phone;
  final String timestamp;
  final String photourl;
  final String status;
  final String yeargroup;
  final String? academicyr;
  final String? promotionstatus;
  final String? promotioncycle;
  final String? nextclass;
  final String? currentclass;
  final String? previousclass;
  final String? promotiondate;

  StudentModel({
    required this.id,
    required this.studentid,
    required this.name,
    required this.sex,
    required this.school,
    required this.region,
    required this.guardiancontact,
    required this.parentname,
    required this.level,
    required this.department,
    required this.term,
    required this.schoolId,
    required this.dob,
    required this.address,
    this.email,
    required this.phone,
    required this.timestamp,
    required this.photourl,
    required this.yeargroup,
    this.status = "active",
    this.academicyr,
    this.promotionstatus ="not",
    this.promotioncycle ="0",
    this.nextclass,
    this.currentclass,
    this.previousclass,
    this.promotiondate ="",
  });

  /// convert to map (all lowercase keys)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentid': studentid,
      'name': name,
      'sex': sex,
      'school': school,
      'region': region,
      'guardiancontact': guardiancontact,
      'parentname': parentname,
      'level': level,
      'department': department,
      'term': term,
      'schoolId': schoolId,
      'dob': dob,
      'address': address,
      'email': email,
      'phone': phone,
      'timestamp': timestamp,
      'photourl': photourl,
      'status': status,
      'yeargroup': yeargroup,
      'academicyr':academicyr,
      'promotionstatus':promotionstatus,
      'promotioncycle':promotioncycle,
      'currentclass':currentclass,
      'previousclass':previousclass,
      'nextclass':nextclass,
      'promotiondate':promotiondate,
    };
  }

  /// create from map (all lowercase keys)
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? '',
      studentid: map['studentid'] ?? '',
      name: map['name'] ?? '',
      sex: map['sex'] ?? '',
      school: map['school'] ?? '',
      region: map['region'] ?? '',
      guardiancontact: List<String>.from(map['guardiancontact'] ?? []),
      parentname: List<String>.from(map['parentname'] ?? []),
      level: map['level'] ?? '',
      department: map['department'] ?? '',
      term: map['term'] ?? '',
      schoolId: map['companyid'] ?? '',
      dob: map['dob'] ?? '',
      address: map['address'] ?? '',
      email: map['email'],
      phone: map['phone'] ?? '',
      timestamp: map['timestamp'] ?? '',
      photourl: map['photourl'] ?? '',
      yeargroup: map['yeargroup'] ?? '',
      status: map['status'] ?? 'active',
      academicyr: map['academicyr'] ?? '',
      promotioncycle: map['promotioncycle'] ?? '',
      promotionstatus: map['promotionstatus'] ?? '',
      currentclass: map['currentclass'] ?? '',
      previousclass: map['previousclass'] ?? '',
      nextclass: map['nextclass'] ?? '',
      promotiondate: map['promotiondate'] ?? '',
    );
  }
}
