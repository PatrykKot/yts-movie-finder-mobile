import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yts_movie_finder/torrent/dto/MovieResponse.dart';

const _BASE_URL = "yts.am";

class MovieService {
  Future<MovieResponse> fetchMovies(String query) async {
    var url = Uri.https(_BASE_URL, "/api/v2/list_movies.json", {
      "limit": 50.toString(),
      "query_term": query,
      "sort_by": "year",
      "order_by": "desc"
    });
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return MovieResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "Failed to load movies. Status code ${response.statusCode}");
    }
  }
}
