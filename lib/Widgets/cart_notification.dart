import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nativeapp/Screens/cart_screen.dart';
import 'package:nativeapp/Services/cart_services.dart';
import 'package:nativeapp/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartNotification extends StatefulWidget {
  @override
  _CartNotificationState createState() => _CartNotificationState();
}

class _CartNotificationState extends State<CartNotification> {
  CartServices _cart = CartServices();
  DocumentSnapshot document;

  @override
  Widget build(BuildContext context) {
    final _cartProvider = Provider.of<CartProvider>(context);
    _cartProvider.getCartTotal();

    _cart.getRestaurantName().then((value){
      setState(() {
       document = value;
      });
    });

    return Container(
      height:45,
      width: MediaQuery.of(context).size.width,
      color: Colors.green,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_cartProvider.cartQty} | Items', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                  ),
                  if(document!=null)
                  Text('From ${document.data()['restaurant_name']}', style: TextStyle(color: Colors.white,fontSize: 10
                  ),
                  )
                ],
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => CartScreen(document: document,),
                ));
              },
              child: Container(
                child: Row(
                  children: [
                    Text(
                      'View Cart',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5,),
                    Icon(Icons.shopping_cart,color: Colors.white,)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
