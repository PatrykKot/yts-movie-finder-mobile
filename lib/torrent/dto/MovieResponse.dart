import 'MovieData.dart';

class MovieResponse {
  String status;
  String message;
  MovieData data;

  MovieResponse({this.status, this.message, this.data});

  factory MovieResponse.fromJson(Map<String, dynamic> json) {
    return MovieResponse(
        status: json['status'],
        message: json['message'],
        data: MovieData.fromJson(json['data']));
  }
}
