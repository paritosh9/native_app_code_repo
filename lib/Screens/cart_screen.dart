import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  final DocumentSnapshot document;
  CartScreen({this.document});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context,bool innerBozIsSxrolled){
          return[
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.green,
              elevation: 0.0,
              title: Column(
                children: [
                  Text(
                    widget.document.data()['restaurant_name'],
                    style: TextStyle(fontSize: 16,color: Colors.black),
                  ),

                ],
              ),
            ),
          ];
        },
        body: Center(child: Text('Cart Screen'),),


      )


//
//      Center(
//        child: Text('Cart Screen'),
//      ),
//      SliverAppBar(
//      floating: true,
//      snap: true,
//      backgroundColor: Colors.white,
//      elevation: 0.0,
//      title: Column(
//        children: [
//          Text(
//            widget.document.data()['restaurant_name'],
//            style: TextStyle(fontSize: 16),
//          ),
//
//        ],
//      ),
//    )
    );
  }
}
