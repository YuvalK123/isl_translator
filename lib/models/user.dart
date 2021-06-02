
class UserModel {

  final String uid;
  final String userName;
  final int age;
  final String gender;

  UserModel({ this.uid, this.userName, this.age, this.gender });

  @override
  String toString(){
    return "$uid, username: $userName, age: ${age.toString()}, gender: $gender";
  }

}