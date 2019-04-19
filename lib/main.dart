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
  final versionService = VersionService();

  var _movieLoading = false;

  _search(String value) {
    var query = value.trim();

    if (!_movieLoading && query.isNotEmpty) {
      setState(() {
        _movieLoading = true;
      });

      movieService.fetchMovies(query).then((newMovies) {
        setState(() {
          _movies.clear();
          _movies.addAll(newMovies);
        });
      }).catchError((error) {
        Fluttertoast.showToast(msg: error.toString());
      }).whenComplete(() {
        setState(() {
          _movieLoading = false;
        });
      });
    }
  }

  _searchVersion(Movie movie) {
    versionService.fetchVersion(movie).then((versions) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(children: _buildDialogList(versions));
          });
    }).catchError((error) {
      Fluttertoast.showToast(msg: error.toString());
    });
  }

  List<Widget> _buildDialogList(List<Version> versions) {
    return versions.map((version) {
      return SimpleDialogOption(
          child:
              Text("${version.resolution} ${version.target}: ${version.size}"),
          onPressed: () => _launch(version));
    }).toList();
  }

  _launch(Version version) async {
    if (await canLaunch(version.magnet)) {
      await launch(version.magnet);
    } else {
      Fluttertoast.showToast(msg: 'Cannot run torrent');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TextField(
            decoration: InputDecoration(labelText: "Enter title"),
            onSubmitted: _search,
          ),
        ),
        body: buildBody());
  }

  Widget buildBody() {
    if (_movieLoading) {
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
                      subtitle: Text(movie.year),
                      leading: Image.network(
                        movie.img,
                      ),
                      onTap: () => _searchVersion(movie),
                    ))
                .toList())
      ]);
    }
  }
}
