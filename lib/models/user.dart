
class UserModel {

  final String uid;
  final String username;
  final int age;
  final String gender;

  UserModel({ this.uid, this.username, this.age, this.gender });

  @override
  String toString(){
    return "$uid, username: $username, age: ${age.toString()}, gender: $gender";
  }

}