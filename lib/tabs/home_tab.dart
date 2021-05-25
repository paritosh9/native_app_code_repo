import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart' as geoc;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';

import 'package:nativeapp/Screens/login_page.dart';
import 'package:nativeapp/Screens/restaurant_page.dart';
import 'package:nativeapp/Widgets/cart_notification.dart';

import '../constants.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  
  final CollectionReference _restaurantsRef =  FirebaseFirestore.instance.collection("restaurants");
  final CollectionReference _categoriesRef =  FirebaseFirestore.instance.collection("food_categories");
  final CollectionReference _offersRef =  FirebaseFirestore.instance.collection("offers");
  final DocumentReference _resLocationRef =  FirebaseFirestore.instance.collection("restaurants").doc("7f2crMYsRVEMo27BwdMx");

  Position position;
  final geo = Geoflutterfire();
  List<FilterCategories> _filterCategories;
  List<String> _filters;

  String userAddress="";

  
  @override
  void initState() {
    super.initState();

    _filters = <String>[];
    _filterCategories = <FilterCategories>[
      const FilterCategories('Pickup'),
      const FilterCategories('Rating: 4.0+'),
      const FilterCategories('Under 30 min'),
      const FilterCategories('Fastest Delivery'),
      const FilterCategories('Vegetarian'),
    ];


  }



  
  queryRestaurants()
  {
    if(_filters.length==0)
    {
      return _restaurantsRef.get();
    }
    else if(_filters.contains('Rating: 4.0+') && _filters.contains('Vegetarian') && _filters.contains('Pickup'))
    {
      return _restaurantsRef.where("ratings",isGreaterThanOrEqualTo: 4.0)
                            .where("cuisine",arrayContains: "Vegetarian")
                            .where("pickupAvailable",isEqualTo: true)
                            .get();

    }
    else if(_filters.contains('Rating: 4.0+') && _filters.contains('Vegetarian'))
    {
      return _restaurantsRef.where("ratings",isGreaterThanOrEqualTo: 4.0)
          .where("cuisine",arrayContains: "Vegetarian")
          .get();

    }
    else if( _filters.contains('Vegetarian') && _filters.contains('Pickup'))
    {
      return _restaurantsRef
          .where("cuisine",arrayContains: "Vegetarian")
          .where("pickupAvailable",isEqualTo: true)
          .get();

    }
    else if(_filters.contains('Rating: 4.0+') && _filters.contains('Pickup'))
    {
      return _restaurantsRef.where("ratings",isGreaterThanOrEqualTo: 4.0)
          .where("pickupAvailable",isEqualTo: true)
          .get();

    }
    else if(_filters.contains('location'))
    {
      double rad = 5;
      //String field = 'position';
      // Create a geoFirePoint
      GeoFirePoint center = geo.point(latitude: position.latitude, longitude: position.longitude);

      Stream<List<DocumentSnapshot>> stream  = geo
          .collection(collectionRef: _restaurantsRef)
          .within(center: center, radius: rad, field: 'location');

      stream.listen((List<DocumentSnapshot> documentList) {
        // doSomething()
        print(documentList.toList());
        documentList.forEach((element) {
          print(element.data());
        });
        return _restaurantsRef.doc().get();
      });


    }
    else if(_filters.contains('Rating: 4.0+'))
    {
      return _restaurantsRef.where("ratings",isGreaterThanOrEqualTo: 4.0).get();
    }
    else if(_filters.contains('Vegetarian'))
    {
      return _restaurantsRef.where("cuisine",arrayContains: "Vegetarian").get();
    }
    else if(_filters.contains('Pickup'))
    {
      return _restaurantsRef.where("pickupAvailable",isEqualTo: true).get();
    }



  }



  Iterable<Widget> get filterCategoryWidgets sync* {
    for (FilterCategories filterCategories in _filterCategories) {
      yield Padding(
        padding: const EdgeInsets.symmetric(horizontal:3.0),
        child: FilterChip(

          label: Text(filterCategories.name),
          selected: _filters.contains(filterCategories.name),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _filters.add(filterCategories.name);
              } else {
                _filters.removeWhere((String name) {
                  return name == filterCategories.name;
                });
              }
            });
          },
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: CartNotification(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Delivery to",
              style: Theme.of(context)
                  .textTheme
                  .subtitle2
                  .copyWith(color: Colors.black45),
            ),
            InkWell(
              onTap: () async {

                print("Location Clicked");
                position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                print(position);
                var addresses = await geoc.Geocoder.local.findAddressesFromCoordinates(new geoc.Coordinates(position.latitude, position.longitude));
                var first = addresses.first;
                print("${first.featureName} : ${first.addressLine}");
                setState(() {
                  userAddress = first.addressLine;
                });

                GeoFirePoint myLocation = geo.point(latitude: 12.973270526676458, longitude: 77.60345723267504);
                _resLocationRef.update({'location': myLocation.data});

                print(myLocation.latitude);
                print(myLocation.longitude);
                print(myLocation.latitude);

                _filters.add("location");



              },

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  Flexible(
                    child: Container(
                      child: Text( userAddress == "" ? "Current Location" : userAddress,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context)
                            .textTheme
                            .headline6
                            .copyWith(fontWeight: FontWeight.bold),

                      ),
                    ),
                  ),

                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.black,
                      size: 25),
                ],
              ),
            ),

          ],
        )

      ),


      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Category",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),

              // Food Categories
              FutureBuilder<QuerySnapshot>(
                future: _categoriesRef.get(),
                builder: (context, snapshot) {
                  return !snapshot.hasData
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                        height: 115,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.docs.length,
                            itemBuilder: (context, index){
                            DocumentSnapshot data = snapshot.data.docs[index];
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2),
                                  margin: EdgeInsets.only( top: 5, bottom: 2, right: 5, left: 8),
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.network(data['imageUrl']),
                                ),
                                Text(data['title'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        .copyWith(fontWeight: FontWeight.bold, color: Colors.black))
                              ],
                            );
                          }),
                    );
                  },
              ),


              Divider(),
//              Wrap(
//                children: filterCategoryWidgets.toList(),
//              ),
              //Text('Selected: ${_filters.join(', ')}'),

              // Filter Categories
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                height: 30.0,
                child: ListView(
                  // This next line does the trick.
                  scrollDirection: Axis.horizontal,
                  children: filterCategoryWidgets.toList(),
                ),
              ),


              //Offers Carousel
              FutureBuilder<QuerySnapshot>(
                future: _offersRef.get(),
                builder: (context, snapshot) {
                  List<NetworkImage> offersList = new List<NetworkImage>();
                  if (snapshot.connectionState == ConnectionState.done) {
                    for(int i = 0; i < snapshot.data.docs.length; i++ ) {
                      offersList.add(NetworkImage(snapshot.data.docs[i]['imageUrl']));
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                          height: 150.0,
                          child: Carousel(
                            boxFit: BoxFit.cover,
                            images: offersList,
                            autoplay: true,
                            dotSize: 4.0,
                            indicatorBgPadding: 4.0,
                            animationCurve: Curves.fastOutSlowIn,
                            animationDuration: Duration(milliseconds: 1000),
                          )),
                    );
                  }

                  return Center(child: CircularProgressIndicator());

                },
              ),

              Divider(),
              Text(
                "Fastest Near Me",
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),


              FutureBuilder<QuerySnapshot>(
                future: queryRestaurants(),
                builder: (context, snapshot) {
                  print(snapshot);

                  // Collection Data ready to display
                  if (snapshot.connectionState == ConnectionState.done) {
                    // Display the data inside a list view
                    return Column(

                      children: snapshot.data.docs.map((document) {
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  spreadRadius: 5,
                                  blurRadius: 5,
                                )
                              ]

                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap:(){
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => RestaurantPage(restaurantID: document.id),
                                  ));
                                },
                                child: Container(
                                  height: 150,
                                  margin: EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                      image: DecorationImage(
                                        image: NetworkImage(document.data()['images'][0]),
                                        fit: BoxFit.cover,
                                      )
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      document.data()['Name'],
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.star,
                                      color: Colors.green,
                                    ),
                                    Text(
                                      document.data()['ratings'].toString(),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Text(" ("+document.data()['noOfRatings'].toString()+" Ratings)"),
                                  ],

                                ),

                              ),


                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                                      child: Text(document.data()['cuisine'][0].toString()+", "
                                                  +document.data()['cuisine'][1].toString()+", "
                                                  +document.data()['cuisine'][2].toString(),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text("Rs. 200 for two",
                                          style: TextStyle(fontSize: 12)),

                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                            ],
                          ),


                        );
                      }).toList(),

                    );
                  }

                  // Loading State
                  return Container(
                    child: CircularProgressIndicator(),
                  );
                },
              ),

              SizedBox(height: 50,),


              
            ],
          ),
        ),

      ),
    );

  }
}

class FilterCategories {
  const FilterCategories(this.name);
  final String name;
}


