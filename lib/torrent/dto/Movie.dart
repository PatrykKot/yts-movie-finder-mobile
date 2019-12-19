import 'Torrent.dart';

class Movie {
  int id;
  String imdbCode;
  double rating;
  String description;
  String smallCoverImage;
  int year;
  String title;
  List<Torrent> torrents;
  String youTubeTrailerCode;
  String backgroundImage;
  String largeCoverImage;

  Movie(
      {this.id,
      this.imdbCode,
      this.rating,
      this.description,
      this.youTubeTrailerCode,
      this.backgroundImage,
      this.smallCoverImage,
      this.largeCoverImage,
      this.year,
      this.title,
      this.torrents});

  factory Movie.fromJson(Map<String, dynamic> json) {
    var jsonTorrents = json['torrents'] as List;

    var movie = Movie(
        id: json['id'],
        rating: double.parse(json['rating'].toString()),
        imdbCode: json['imdb_code'],
        description: json['description_full'],
        youTubeTrailerCode: json['yt_trailer_code'],
        backgroundImage: json['background_image'],
        largeCoverImage: json['large_cover_image'],
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
