class Movie {
  String title;
  String year;
  String url;
  String img;

  Movie({this.title, this.year, this.url, this.img});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      year: json['year'],
      url: json['url'],
      img: json['img'],
    );
  }
}
