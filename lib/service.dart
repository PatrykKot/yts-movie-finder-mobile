import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:yts_finder_mobile/dto.dart';

const baseUrl = "samoloty.szczecin.pl:8080";

class MovieService {
  Future<List<Movie>> fetchMovies(String query) async {
    var url = Uri.http(baseUrl, "/movie/find", {"query": query}).toString();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies. Code ${response.statusCode}');
    }
  }
}

class VersionService {
  Future<List<Version>> fetchVersion(Movie movie) async {
    var url =
        Uri.http(baseUrl, "/version/url/find", {"url": movie.url}).toString();
    var response = await http.get(url);

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((json) => Version.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load versions. Code ${response.statusCode}');
    }
  }
}
