
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
enum VideoType {ANIMATION, LIVE}

class UserModel {

  final String uid;
  final String username;
  final int age;
  final String gender;
  VideoType videoType;
  String videoTypeStr;
  Gender genderModel;
  final bool emailVerified;
  //
  // Gender get genderModel{
  //   return _gender;
  // }

  UserModel({ this.uid, this.username, this.age, this.gender,
    this.videoType, this.videoTypeStr, this.emailVerified }){
    this.videoType = this.videoTypeStr == VideoType.ANIMATION.toString() ? VideoType.ANIMATION : VideoType.LIVE;
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
    return "$uid, username: $username, age: ${age.toString()}, "
        "gender: $gender $genderModel} type: ${this.videoType.toString()}, "
        "emailVeified $emailVerified";
  }

}