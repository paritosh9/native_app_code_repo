import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nativeapp/Services/cart_services.dart';

class CounterForCard extends StatefulWidget {
  final DocumentSnapshot document;

  CounterForCard(this.document);


  @override
  _CounterForCardState createState() => _CounterForCardState();
}

class _CounterForCardState extends State<CounterForCard> {

  CartServices _cart = CartServices();
  User user = FirebaseAuth.instance.currentUser;
  int _qty = 1;
  String _docId;
  bool _exists = false;
  bool _updating = false;
  bool _allowAdd = true;
  bool _allowUpdate = true;



  @override
  void initState() {
    // TODO: implement initState
    getCartData(); // when opening restaurant page check for items in cart
    super.initState();
  }

  getCartData()async{

    FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid)
        .collection('cart_products')
        .where('menu_id',isEqualTo: widget.document.data()['menu_id'])
        .get()
        .then((QuerySnapshot querySnapshot) =>{
          querySnapshot.docs.forEach((doc) {
            if(doc['menu_id'] == widget.document.data()['menu_id']){
              setState(() {
                _qty = doc['quantity'];
                _docId = doc.id;
                _exists = true;
              });
            }
          })
          });
  }


  @override
  Widget build(BuildContext context) {
    return _exists ? Container(
      height:28,
      decoration:BoxDecoration(
          border: Border.all(
              color: Colors.red
          ),
          borderRadius: BorderRadius.circular(4)
      ),
      child: Row(
        children: [
          InkWell(
            onTap: !_allowUpdate ? null : (){
              setState(() {
                _updating = true;
                _allowUpdate = false;
              });
              if(_qty==1){
                _cart.removeFromCart(_docId).then((value){
                  setState(() {
                    _updating=false;
                    _exists=false;
                    _allowUpdate = true;
                  });
                  _cart.checkData();
                });
                print("Removed");
              }

              if(_qty>1){
                setState(() {
                  _qty--;
                });
                var total = _qty * widget.document.data()['price'];
                _cart.updateCartQty(_docId,_qty,total).then((value){
                  setState(() {
                    _updating=false;
                    _allowUpdate = true;
                  });
                });
              }
              print("-- $_qty");

            },
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 3,right: 3),
                child: Icon(Icons.remove,color: Colors.red),
              ),
            ),
          ),
          Container(
            height: 30,
            width: 30,
            color: Colors.red,
            child: Center(child: FittedBox(child: _updating ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
              ):Text(
                _qty.toString(),style: TextStyle(color: Colors.white)))),
          ),
          InkWell(
            onTap: !_allowUpdate? null : (){
              setState(() {
                _updating = true;
                _allowUpdate = false;
                _qty++;
              });
              var total = _qty * widget.document.data()['price'];
              _cart.updateCartQty(_docId,_qty,total).then((value){
               setState(() {
                 _updating=false;
                 _allowUpdate = true;
               });
              });
              print("++ $_qty $_docId");
            },
            child: Container(
              child: Padding(
                padding:  const EdgeInsets.only(left: 5,right: 3),
                child: Icon(Icons.add,color: Colors.red),
              ),
            ),
          )
        ],
      ),
    ):
    InkWell(
      onTap: !_allowAdd
          ? null
          : (){
        setState(() => _allowAdd = false); // Dont Allow to add
        _cart.checkSeller().then((prevRestaurant){
          if(prevRestaurant!=null){
            String restaurant_id = prevRestaurant[0];
            String restaurant_name = prevRestaurant[1];

            if(restaurant_id==widget.document.data()['restaurant_id']){
              //Product from same Restaurant
              print(restaurant_id);
              _cart.addToCart(widget.document).then((value){
                setState(() {
                  _exists = true;
                  getCartData();
                  _allowAdd = true;
                });
                print("Added to cart");
              });
            }
            else{
              //Product from different restaurant
              showCupertinoDialog(context: context, builder: (BuildContext context){
                return CupertinoAlertDialog(
                  title: Text("Replace Cart Item ?"),
                  content: Text("Your cart item contains items from $restaurant_name. Do you want to discard the selection and add items from ${widget.document.data()['restaurant_name']}"),
                  actions: [
                    FlatButton(
                      child: Text("Yes"),
                      onPressed: (){
                        //Delete existing product from Cart
                        _cart.deleteCart().then((value){
                          _cart.addToCart(widget.document).then((value){
                            setState(() {
                              getCartData();
                              _exists=true;
                              _allowAdd = true;
                            });
                          });
                          Navigator.pop(context);
                        });
                      },
                    ),
                    FlatButton(
                      child: Text("No"),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    )
                  ],
                );
              });
              print("Another seller exists");
              print(restaurant_id);
              print(widget.document.data()['restaurant_id']);
            }

          }
          else{
            //If product is the added for first time
            setState(() {
              _exists = true;
            });
            _cart.addToCart(widget.document).then((value){
              getCartData();
              _allowAdd = true;
              print("Added to cart");
            });
          }

        });
//        _cart.addToCart(widget.document);
//        setState(() {
//          getCartData();
//          _exists = true;
//        });
//        print("print new add");
      },
      child: Container(
        height: 25,
        width: 100,
        color:Colors.red,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              'Add',
              style: TextStyle(
                color:Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
