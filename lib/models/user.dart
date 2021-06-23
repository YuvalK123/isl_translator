
// class UserModel {
//
//   final String uid;
//   final String username;
//   final int age;
//   final String gender;
//
//   UserModel({ this.uid, this.username, this.age, this.gender });
//
//   @override
//   String toString(){
//     return "$uid, username: $username, age: ${age.toString()}, gender: $gender";
//   }
//
// }

enum Gender {MALE, FEMALE, OTHER}

class UserModel {

  final String uid;
  final String username;
  final int age;
  final String gender;
  Gender genderModel;
  String ImgURL = "....";
  //
  // Gender get genderModel{
  //   return _gender;
  // }

  UserModel({ this.uid, this.username, this.age, this.gender }){
    switch (gender){
      case 'f':
        this.genderModel = Gender.FEMALE;
        break;
      case 'm':
        this.genderModel = Gender.MALE;
        break;
      default:
        this.genderModel = Gender.OTHER;
    }
  }

  @override
  String toString(){
    return "$uid, username: $username, age: ${age.toString()}, gender: $gender $genderModel}";
  }

}