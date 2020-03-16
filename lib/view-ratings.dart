import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ViewRatingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = "All Ratings";

    return MaterialApp(
      title: appTitle,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ViewRating(),
    );
  }
}

class ViewRating extends StatelessWidget {
  static final fullStar = Icon(
    Icons.star,
    color: Colors.orangeAccent[500],
  );
  static final halfStar = Icon(
    Icons.star_half,
    color: Colors.orangeAccent[500],
  );
  static final starBorder = Icon(
    Icons.star_border,
    color: Colors.orange,
  );
  static final starRow = Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[fullStar, fullStar, fullStar, halfStar, starBorder],
  );

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('reviews').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Reviews',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 25),
              ),
            )
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(5.0),
              child: _displayStars(snapshot),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('${snapshot.length} reviews'),
            ),
          ],
        ),
        Column(
          children: _buildListTiles(context, snapshot),
        )
      ],
    );
  }

  List<Widget> _buildListTiles(
      BuildContext context, List<DocumentSnapshot> snapshot) {
    return (snapshot.map((data) => _buildListItem(context, data)).toList());
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    return _buildCard('imagePath', record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reviews',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  Card _buildCard(String path, Record record) {
    return Card(
      child: ListTile(
        leading: FlutterLogo(
          size: 72.0,
        ),
        title: Row(
          children: <Widget>[
            SmoothStarRating(
              allowHalfRating: false,
              starCount: 5,
              rating: record.rating.toDouble(),
              size: 20.0,
              filledIconData: Icons.star,
              halfFilledIconData: Icons.star_border,
              color: Colors.orangeAccent,
              borderColor: Colors.orange,
              spacing: 0.0,
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text(
                DateTime.parse(record.dateTime.toDate().toString())
                    .toString()
                    .split(' ')[0],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        subtitle: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(record.review),
        ),
        isThreeLine: true,
      ),
    );
  }

  double _calcAverageReview(List<DocumentSnapshot> snapshot) {
    double sum = 0;

    for (var i = 0; i < snapshot.length; i++) {
      Record record = Record.fromSnapshot(snapshot[i]);
      sum += record.rating.toDouble();
    }

    return sum / snapshot.length;
  }

  Widget _displayStars(List<DocumentSnapshot> snapshot) {
    return SmoothStarRating(
      allowHalfRating: true,
      starCount: 5,
      rating: _calcAverageReview(snapshot),
      size: 20.0,
      filledIconData: Icons.star,
      halfFilledIconData: Icons.star_half,
      color: Colors.orangeAccent,
      borderColor: Colors.orange,
      spacing: 0.0,
    );
  }
}

class Record {
  String review;
  num rating;
  Timestamp dateTime;
  String date;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['review'] != null),
        assert(map['rating'] != null),
        review = map['review'],
        rating = map['rating'],
        dateTime = map['date'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$review:>";
}
