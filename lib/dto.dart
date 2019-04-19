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

class Version {
  String resolution;
  String target;
  String url;
  String magnet;
  String size;

  Version({this.resolution, this.target, this.url, this.magnet, this.size});

  factory Version.fromJson(Map<String, dynamic> json) {
    return Version(
        resolution: json['resolution'],
        target: json['target'],
        url: json['url'],
        magnet: json['magnet'],
        size: json['size']
    );
  }
}
