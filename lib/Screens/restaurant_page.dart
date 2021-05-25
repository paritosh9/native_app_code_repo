import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:nativeapp/Services/cart_services.dart';
import 'package:nativeapp/Widgets/cart_notification.dart';
import 'package:nativeapp/Widgets/counter.dart';


class RestaurantPage extends StatefulWidget {
  final String restaurantID;
  RestaurantPage({this.restaurantID});

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {

  final CollectionReference _restaurantsRef =  FirebaseFirestore.instance.collection("restaurants");
  final CollectionReference _restaurantMenu =  FirebaseFirestore.instance.collection("food_products");
  CartServices _cart = CartServices();
  User user = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  Map _cartItems=new Map();

  @override
  void initState() {
    // TODO: implement initState
    //getCartData(); // when opening restaurant page check for items in cart
    super.initState();

  }


  getCartData()async{
    final cartSnapshot = await _cart.cart.doc(user.uid).collection('cart_products').get();
    var cartItems = new Map();
    for(int i = 0; i < cartSnapshot.docs.length; i++ ) {
      cartItems[cartSnapshot.docs[i]['menu_id']] = cartSnapshot.docs[i]['quantity'].toString();
    }
    print(cartItems);

    if(cartSnapshot.docs.length == 0)
    {
      setState(() {
        _loading = false;
      });
    }
    else{
      setState(() {
        _cartItems = cartItems;
        print(_cartItems);
        _loading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    var primary = Color(0xFF00954d);
    var textFieldColor = Colors.grey.withOpacity(0.15);
    var size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: _restaurantsRef.doc(widget.restaurantID).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container(
              child: Center(
                child: Text("Error: ${snapshot.error}"),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> documentData = snapshot.data.data();
            String restaurantName = documentData['Name'];
            String restaurantImage = documentData['images'][0];
            String restaurantCuisines = documentData['cuisine'][0].toString()+", " +documentData['cuisine'][1].toString()+", " +documentData['cuisine'][2].toString();
            String restaurantRatings = documentData['ratings'].toString();
            String restaurantNoOfRatings = "("+documentData['noOfRatings'].toString()+" Ratings)";
            String restaurantAddress = documentData["address"];

            print(restaurantName);

            return Scaffold(
              floatingActionButton: CartNotification(),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: size.width,
                              height: 200,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(restaurantImage), fit: BoxFit.cover)),
                            ),
                            SafeArea(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white, shape: BoxShape.circle),
                                      child: Center(
                                        child: Icon(
                                          Icons.arrow_back,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  IconButton(
                                    icon: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white, shape: BoxShape.circle),
                                      child: Center(
                                        child: Icon(
                                          Icons.favorite_border,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {},
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurantName,
                                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: size.width - 30,
                                    child: Text(
                                      restaurantCuisines,
                                      style: TextStyle(fontSize: 14, height: 1.3),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          color: textFieldColor,
                                          borderRadius: BorderRadius.circular(3)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Icon(
                                          Icons.hourglass_empty,
                                          color: primary,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: textFieldColor,
                                          borderRadius: BorderRadius.circular(3)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          "40-50 Min",
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: textFieldColor,
                                          borderRadius: BorderRadius.circular(3)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              restaurantRatings,
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 3,
                                            ),
                                            Icon(
                                              Icons.star,
                                              color: primary,
                                              size: 17,
                                            ),
                                            Text(
                                              restaurantNoOfRatings,
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Divider(
                                color: Colors.black.withOpacity(0.3),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Store Info",
                                //style: customContent,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: (size.width) * 0.80,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.black,
                                          size: 16,
                                        ),

                                        SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          width: size.width-100,
                                          child: Text(
                                            restaurantAddress,
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "More Info",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(
                                height: 15,
                              ),
                              Divider(
                                color: Colors.black.withOpacity(0.3),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Menu',
                                    style: TextStyle(
                                        fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Icon(
                                    Icons.search,
                                    size: 25,
                                  )
                                ],
                              ),
                              SizedBox(height: 20),

                            ],
                          ),
                        ),






                        FutureBuilder<QuerySnapshot>(

                            future: _restaurantMenu.where("restaurant_id",isEqualTo: widget.restaurantID).get(),
                            builder: (context, snapshot) {
                              if(snapshot.hasError)
                                {
                                  print(snapshot.error);
                                }
                              if (snapshot.connectionState == ConnectionState.done) {
                                // Display the data inside a list view
                                print(snapshot);
                                return Column(
                                          children: snapshot.data.docs.map((document) {
                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 20,left: 15, right: 15),
                                            child: Row(
                                              children: [
                                                Container(
                                                    width: (size.width - 30) * 0.6,
                                                    child:
                                                    Row(
                                                      children: <Widget>[
                                                        Image(
                                                          image: AssetImage(
                                                              "assets/images/food_symbol_veg.png"
                                                          ),
                                                          width: 22.0,
                                                          height: 22.0,
                                                        ),
                                                        SizedBox(width:10),
                                                        Container(
                                                          width: size.width-200,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                            children: [
                                                              Container(
                                                                child: Text(
                                                                  document.data()['menu_name'],
                                                                  style: TextStyle(
                                                                      fontSize: 16,
                                                                      height: 1.5,
                                                                      fontWeight: FontWeight.w600),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                document.data()['category'][0],
                                                                style: TextStyle(
                                                                    height: 1.3,
                                                                    fontWeight: FontWeight.w300),
                                                              ),
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Text(
                                                                "Rs. "+document.data()['price'].toString(),
                                                                style: TextStyle(
                                                                    height: 1.3,
                                                                    fontWeight: FontWeight.w500),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                                SizedBox(
                                                  width: 15,
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    height: 155,
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 20, top: 10, bottom: 10),
                                                      child: Column(
                                                        children: [
                                                          Image(
                                                            image: NetworkImage(
                                                                document.data()['menu_image']),
                                                            fit: BoxFit.cover,
                                                            height: 80,
                                                            width: 180,
                                                          ),



                                                          // Add to Cart

                                                          CounterForCard(document)

                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
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

                        }),






                      ]
                  ),
                ),
              ),
            );




          }

          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );

        });

  }

}
