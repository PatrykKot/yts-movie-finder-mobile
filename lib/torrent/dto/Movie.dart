import 'Torrent.dart';

class Movie {
  String smallCoverImage;
  int year;
  String title;
  List<Torrent> torrents;

  Movie({this.smallCoverImage, this.year, this.title, this.torrents});

  factory Movie.fromJson(Map<String, dynamic> json) {
    var jsonTorrents = json['torrents'] as List;

    var movie = Movie(
        smallCoverImage: json['small_cover_image'],
        year: json['year'],
        title: json['title'],
        torrents: jsonTorrents
            .map((torrentJson) => Torrent.fromJson(torrentJson))
            .toList());
    movie.torrents.forEach((torrent) => torrent.movie = movie);
    return movie;
  }
}