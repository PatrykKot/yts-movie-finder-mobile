import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yts_movie_finder/torrent/dto/Movie.dart';
import 'package:yts_movie_finder/torrent/dto/Torrent.dart';
import 'package:yts_movie_finder/torrent/service/MovieService.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Movie> _movies = [];
  final movieService = MovieService();

  final searchQueryController = new TextEditingController();
  Timer searchDebounce;
  var movieLoading = false;
  var lastSearchQuery;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    searchQueryController.addListener(_onQueryChanged);

    _search('');
  }

  @override
  void dispose() {
    searchQueryController.removeListener(_onQueryChanged);
    searchQueryController.dispose();
    super.dispose();
  }

  _onQueryChanged() {
    if (searchDebounce?.isActive ?? false) {
      searchDebounce.cancel();
    }

    searchDebounce = Timer(const Duration(milliseconds: 800), () {
      _search(searchQueryController.text);
    });
  }

  _search(String value) async {
    var query = value.trim();

    if (!movieLoading && lastSearchQuery != query) {
      lastSearchQuery = query;

      setState(() {
        movieLoading = true;
      });

      try {
        final response = await movieService.fetchMovies(query);

        setState(() {
          _movies.clear();
          _movies.addAll(response.data.movies);
        });
      } on Exception catch (ex) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            ex.toString(),
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          movieLoading = false;
        });
      }
    }
  }

  _showTorrents(Movie movie) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
              children: _buildDialogList(movie), title: Text("Choose version"));
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
          title: TextField(
            controller: searchQueryController,
            decoration: InputDecoration(labelText: "Enter title"),
          ),
        ),
        body: body);
  }

  Widget get body {
    if (movieLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[CircularProgressIndicator()],
        ),
      );
    } else if (_movies.isEmpty) {
      return Center(
        child: Text("No movies found"),
      );
    } else {
      return Stack(children: <Widget>[
        ListView(
            children: _movies
                .map((movie) => ListTile(
                      title: Text(movie.title),
                      subtitle: Text(movie.year.toString()),
                      leading: Image.network(
                        movie.smallCoverImage,
                      ),
                      onTap: () => _showTorrents(movie),
                    ))
                .toList())
      ]);
    }
  }
}
