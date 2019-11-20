import 'Movie.dart';

const _TRACKERS = [
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
    var trackersQuery = _TRACKERS
        .map((tracker) => Uri.encodeComponent(tracker))
        .map((tracker) => "tr=$tracker")
        .join("&");

    return "magnet:?xt=urn:btih:$hash&dn=${Uri.encodeComponent(movie.title)}&$trackersQuery";
  }
}
