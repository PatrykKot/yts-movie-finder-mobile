import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yts_movie_finder/torrent/dto/Movie.dart';
import 'package:yts_movie_finder/torrent/page/MovieDetailsPage.dart';
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
  final appBarFieldFocus = FocusNode();

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

  _showTorrents(Movie movie) async {
    appBarFieldFocus.unfocus();
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MovieDetailsPage(
              movie: movie,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: TextField(
            focusNode: appBarFieldFocus,
            onSubmitted: (value) {
              _search(value);
            },
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
