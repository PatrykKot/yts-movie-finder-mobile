import 'Movie.dart';

class MovieData {
  int limit;
  int count;
  List<Movie> movies;

  MovieData({this.limit, this.count, this.movies});

  factory MovieData.fromJson(Map<String, dynamic> json) {
    var jsonMovies = json['movies'] as List;
    if (jsonMovies == null) {
      jsonMovies = [];
    }

    return MovieData(
        limit: json['limit'],
        count: json['movie_count'],
        movies:
        jsonMovies.map((movieJson) => Movie.fromJson(movieJson)).toList());
  }
}