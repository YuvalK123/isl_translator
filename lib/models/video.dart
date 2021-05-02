
class Vid {

  String title;
  String url;
  String desc;

  Vid({this.title, this.url, this.desc});

  @override
  String toString(){
    return "title: ${this.title}, url: ${this.url}, desc: ${this.desc}";
  }
}