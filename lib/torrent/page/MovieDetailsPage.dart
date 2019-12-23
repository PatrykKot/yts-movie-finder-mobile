import 'package:flutter/material.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yts_movie_finder/filmweb/FilmwebService.dart';
import 'package:yts_movie_finder/torrent/dto/Movie.dart';
import 'package:yts_movie_finder/torrent/dto/Torrent.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie movie;

  MovieDetailsPage({this.movie});

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  var loading = false;

  final filmwebService = FilmwebService();
  final scaffoldKey = GlobalKey<ScaffoldState>();

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
      body: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: <Widget>[
                ProgressiveImage.assetNetwork(
                    placeholder: 'assets/black.png',
                    thumbnail: widget.movie.smallCoverImage,
                    image: widget.movie.largeCoverImage,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height),
                Container(
                  color: Colors.black.withOpacity(0.85),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Transform.scale(
                              scale: 0.8,
                              child: ProgressiveImage.assetNetwork(
                                  placeholder: 'assets/black.png',
                                  thumbnail: widget.movie.smallCoverImage,
                                  image: widget.movie.largeCoverImage,
                                  width: 230,
                                  height: 345),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    widget.movie.title,
                                    style: TextStyle(fontSize: 26),
                                  ),
                                  Text(
                                    widget.movie.year.toString(),
                                    style: TextStyle(
                                        fontSize: 17, color: Colors.white60),
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                                          .map((index) {
                                        if (widget.movie.rating > index) {
                                          return Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                            size: 15,
                                          );
                                        } else {
                                          return Icon(
                                            Icons.star_border,
                                            size: 15,
                                          );
                                        }
                                      }).toList()),
                                  Divider(),
                                  Container(
                                    height: 160,
                                    child: SingleChildScrollView(
                                      child: Text(
                                        widget.movie.description,
                                        textAlign: TextAlign.justify,
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          InkWell(
                            child: Image.asset('assets/ytLogo.png', scale: 60),
                            onTap: () => launch(
                                'https://www.youtube.com/watch?v=${widget.movie.youTubeTrailerCode}'),
                          ),
                          InkWell(
                            child:
                                Image.asset('assets/imdbLogo.png', scale: 12),
                            onTap: () => launch(
                                'https://www.imdb.com/title/${widget.movie.imdbCode}'),
                          ),
                          InkWell(
                              child: Image.asset('assets/filmwebLogo.png',
                                  scale: 2.7),
                              onTap: () async {
                                setState(() {
                                  loading = true;
                                });
                                final url =
                                    await filmwebService.fetchUrl(widget.movie);
                                if (url != null) {
                                  launch(url);
                                } else {
                                  scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      'Nie znaleziono w serwisie Filmweb',
                                    ),
                                    duration: Duration(seconds: 1),
                                  ));
                                }

                                setState(() {
                                  loading = false;
                                });
                              }),
                          InkWell(
                            child:
                                Image.asset('assets/googleLogo.png', scale: 26),
                            onTap: () => launch(
                                'http://www.google.com/#q=${Uri.encodeQueryComponent(widget.movie.title + ' ' + widget.movie.year.toString())}'),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Divider(),
                      ...widget.movie.torrents.map((torrent) {
                        return ListTile(
                          onTap: () {
                            _launch(torrent);
                          },
                          leading: torrent.type == 'bluray'
                              ? Image.asset('assets/bluRayLogo.png', scale: 30)
                              : Text(
                                  'WEB',
                                  style: TextStyle(fontSize: 28),
                                ),
                          trailing: Text(
                            '${torrent.quality} (${torrent.size})',
                            style:
                                TextStyle(fontSize: 20, color: Colors.white70),
                          ),
                        );
                      }).toList()
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
