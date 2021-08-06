
/// user genders possibilities
enum Gender {MALE, FEMALE, OTHER}
/// the 2 types of video types
enum VideoType {ANIMATION, LIVE}

class UserModel {

  final String uid;
  final String username;
  final int age;
  VideoType videoType;
  Gender genderModel;
  final bool emailVerified;

  UserModel({
    this.uid, this.username, this.age, gender, videoTypeStr, this.emailVerified }){
    this.videoType = (videoTypeStr == VideoType.ANIMATION.toString()) ? VideoType.ANIMATION : VideoType.LIVE;
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
        "gender: $genderModel} type: ${this.videoType.toString()}, "
        "emailVeified $emailVerified";
  }

}