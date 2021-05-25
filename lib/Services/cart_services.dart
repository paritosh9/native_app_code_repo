import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CartServices {

  CollectionReference cart = FirebaseFirestore.instance.collection('cart');
  User user = FirebaseAuth.instance.currentUser;

  Future<void>addToCart(document){
    cart.doc(user.uid).set({
      'user': user.uid,
      'restaurant_id': document.data()['restaurant_id'],
      'restaurant_name': document.data()['restaurant_name'],
    });

    return cart.doc(user.uid).collection('cart_products').add({
      'menu_id': document.data()['menu_id'],
      'menu_name' : document.data()['menu_name'],
      'price' : document.data()['price'],
      'quantity' : 1,
      'total':document.data()['price']
    });
  }

  Future<void>updateCartQty(docId,qty,total){
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid).collection('cart_products').doc(docId);
    return FirebaseFirestore.instance.runTransaction((transaction) async{
      DocumentSnapshot snapshot = await transaction.get(documentReference);
      print(docId);

      if(!snapshot.exists){
        throw Exception("Product does not exist in cart");
      }

      transaction.update(documentReference, {'quantity':qty,'total':total});
      return qty;
    })
        .then((value) => print("Updated Cart"))
        .catchError((error) => print("Failed to update cart: $error"));
  }

  Future<void>removeFromCart(docId)async{
    cart.doc(user.uid).collection('cart_products').doc(docId).delete();
    print("removed $docId");
  }

  Future<void>deleteCart()async{
    final result = await cart.doc(user.uid).collection('cart_products').get().then((snapshot){
      for(DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }
    });
  }



  Future<void>checkData()async{
    final snapshot = await cart.doc(user.uid).collection('cart_products').get();
    if(snapshot.docs.length==0){
      cart.doc(user.uid).delete();
    }
  }

  Future<List<String>>checkSeller()async{
    final snapshot = await cart.doc(user.uid).get();
    List<String> prevCartRestaurantDetails = new List<String>(2);
    if(snapshot.exists){
      prevCartRestaurantDetails[0] = snapshot.data()['restaurant_id'];
      prevCartRestaurantDetails[1] = snapshot.data()['restaurant_name'];
      return prevCartRestaurantDetails;
    }else{
      return null;
    }
  }

  Future<DocumentSnapshot>getRestaurantName()async{
    DocumentSnapshot doc = await cart.doc(user.uid).get();
    if(doc.exists)
    return doc;
    else return null;
  }


}
