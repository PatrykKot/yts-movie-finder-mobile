import 'package:flutter/material.dart';
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
  final _query = TextEditingController();
  final movieService = MovieService();

  var _loading = false;

  _search() {
    var query = _query.text.trim();

    if (!_loading && query.isNotEmpty) {
      setState(() {
        _loading = true;
      });

      movieService.fetchMovies(query).then((newMovies) => {
            setState(() {
              _loading = false;
              _movies.clear();
              _movies.addAll(newMovies);
            })
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _query,
            decoration: InputDecoration(labelText: "Enter title"),
          ),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.search), onPressed: _search)
          ],
        ),
        body: buildBody());
  }

  Widget buildBody() {
    if (_loading) {
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
            itemExtent: 130,
            children: _movies
                .map((movie) => ListTile(
                      title: Text(movie.title),
                      subtitle: Text(movie.year),
                        leading: Image.network(
                          movie.img,
                          fit: BoxFit.fill,
                        ),
                    ))
                .toList())
      ]);
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }
}
