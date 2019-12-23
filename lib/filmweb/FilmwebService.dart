import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:yts_movie_finder/torrent/dto/Movie.dart';

class FilmwebService {
  Future<String> fetchUrl(Movie movie) async {
    final response = await http.get(Uri.https(
        'google.com', 'search', {"q": '${movie.title} ${movie.year} Filmweb'}));
    if (response.statusCode == 200)
      try {
        final body = response.body;
        var document = parse(body);
        final url = document
            .getElementsByTagName('div')
            .where((item) => item.text.endsWith('- Filmweb'))
            .first
            .parent
            .attributes['href'];

        final uri = Uri.parse('https://google.com$url');
        final parameters = uri.queryParameters;
        return parameters['q'];
      } catch (ex) {
        return null;
      }
    else {
      return null;
    }
  }
}
