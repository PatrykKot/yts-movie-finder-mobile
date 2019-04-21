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

const trackers = [
  'udp://open.demonii.com:1337/announce',
  'udp://tracker.openbittorrent.com:80',
  'udp://tracker.coppersurfer.tk:6969',
  'udp://glotorrents.pw:6969/announce',
  'udp://tracker.opentrackr.org:1337/announce',
  'udp://torrent.gresille.org:80/announce',
  'udp://p4p.arenabg.com:1337',
  'udp://tracker.leechers-paradise.org:6969',
];

class Torrent {
  String hash;
  String size;
  String quality;
  String type;
  Movie movie;

  Torrent({this.hash, this.size, this.quality, this.type});

  factory Torrent.fromJson(Map<String, dynamic> json) {
    return Torrent(
        hash: json['hash'],
        size: json['size'],
        quality: json['quality'],
        type: json['type']);
  }

  String get magnet {
    var trackersQuery = trackers
        .map((tracker) => Uri.encodeComponent(tracker))
        .map((tracker) => "tr=$tracker")
        .join("&");

    return "magnet:?xt=urn:btih:$hash&dn=${Uri.encodeComponent(movie.title)}&$trackersQuery";
  }
}
