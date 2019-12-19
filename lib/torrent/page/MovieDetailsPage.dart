import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yts_movie_finder/torrent/dto/Movie.dart';
import 'package:yts_movie_finder/torrent/dto/Torrent.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;

  MovieDetailsPage({this.movie});

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  onDownloadClick() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              children: _buildDialogList(widget.movie),
              title: Text("Choose version"));
        });
  }

  List<Widget> _buildDialogList(Movie movie) {
    return movie.torrents.map((torrent) {
      return SimpleDialogOption(
          child: Text("${torrent.quality} ${torrent.type}: ${torrent.size}"),
          onPressed: () => _launch(torrent));
    }).toList();
  }

  _launch(Torrent torrent) async {
    var magnet = torrent.magnet;
    if (await canLaunch(magnet)) {
      await launch(magnet);
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(
          'You have no torrent clients installed',
          style: TextStyle(color: Colors.white),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.movie.title} (${widget.movie.year})'),
      ),
      body: Container(
        child: SizedBox.expand(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text("Watch trailer"),
                onPressed: () {
                  launch(
                      'https://www.youtube.com/watch?v=${widget.movie.youTubeTrailerCode}');
                },
              ),
              RaisedButton(
                child: Text("IMDB"),
                onPressed: () {
                  launch('https://www.imdb.com/title/${widget.movie.imdbCode}');
                },
              ),
              RaisedButton(
                child: Text('Google'),
                onPressed: () {
                  launch(
                      'http://www.google.com/#q=${Uri.encodeQueryComponent(widget.movie.title + ' ' + widget.movie.year.toString())}');
                },
              ),
              RaisedButton(child: Text('Download'), onPressed: onDownloadClick)
            ],
          ),
        ),
        decoration: BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.dstATop),
                image: NetworkImage(widget.movie.largeCoverImage))),
      ),
    );
  }
}
