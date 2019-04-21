import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yts_finder_mobile/dto.dart';
import 'package:yts_finder_mobile/service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YTS Movie Finder',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Movie> _movies = [];
  final movieService = MovieService();

  final searchQueryController = new TextEditingController();
  Timer searchDebounce;
  var movieLoading = false;
  var lastSearchQuery = "";

  _onQueryChanged() {
    if (searchDebounce?.isActive ?? false) {
      searchDebounce.cancel();
    }

    searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _search(searchQueryController.text);
    });
  }

  _search(String value) {
    var query = value.trim();

    if (!movieLoading && query.isNotEmpty && lastSearchQuery != query) {
      setState(() {
        movieLoading = true;
      });

      movieService.fetchMovies(query).then((response) {
        setState(() {
          lastSearchQuery = query;
          _movies.clear();
          _movies.addAll(response.data.movies);
        });
      }).catchError((error) {
        Fluttertoast.showToast(msg: error.toString());
      }).whenComplete(() {
        setState(() {
          movieLoading = false;
        });
      });
    }
  }

  _showTorrents(Movie movie) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(children: _buildDialogList(movie));
        });
  }

  List<Widget> _buildDialogList(Movie movie) {
    return movie.torrents.map((torrent) {
      return SimpleDialogOption(
          child: Text("${torrent.quality} ${torrent.type}: ${torrent.size}"),
          onPressed: () => _launch(torrent));
    }).toList();
  }

  _launch(Torrent version) async {
    var magnet = version.magnet;
    if (await canLaunch(magnet)) {
      await launch(magnet);
    } else {
      Fluttertoast.showToast(msg: 'Cannot run torrent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: searchQueryController,
            decoration: InputDecoration(labelText: "Enter title"),
          ),
        ),
        body: buildBody());
  }

  Widget buildBody() {
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

  @override
  void initState() {
    super.initState();
    searchQueryController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    searchQueryController.removeListener(_onQueryChanged);
    searchQueryController.dispose();
    super.dispose();
  }
}
