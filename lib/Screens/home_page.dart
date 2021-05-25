import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nativeapp/Screens/login_page.dart';
import 'package:nativeapp/Widgets/bottom_tabs.dart';
import 'package:nativeapp/tabs/OrdersTab.dart';
import 'package:nativeapp/tabs/SearchTab.dart';
import 'package:nativeapp/tabs/home_tab.dart';

import '../constants.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  User user = FirebaseAuth.instance.currentUser;

  PageController _tabsPageController;
  int _selectedTab = 0;

  @override
  void initState() {
    _tabsPageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _tabsPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabsPageController,
                onPageChanged: (num) {
                  setState(() {
                    _selectedTab = num;
                  });
                },
                children: [
                  HomeTab(),
                  SearchTab(),
                  OrdersTab(),
                ],
              ),
            ),
            BottomTabs(
              selectedTab: _selectedTab,
              tabPressed: (num) {
                _tabsPageController.animateToPage(
                    num,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic);
              },
            ),
          ],
        ),
    );

    /*
          return Scaffold(
            body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Home Page",
                      style: Constants.regularHeading,
                    ),
                    SizedBox(height: 8),
                    CircleAvatar(
                      maxRadius: 25,
                      backgroundImage: NetworkImage(data['photoUrl']),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Name: ${data['Name']}",
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Email: ' + user.email,
                      style: TextStyle(color: Colors.black),
                    ),
                    //SizedBox(height: 8),



                    FlatButton(
                      child: Text("Logout"),
                      onPressed: (){
                        googleSignIn.disconnect();
                        FirebaseAuth.instance.signOut();
                      },
                    )
                  ]
              ),
            ),
          );
          //return Text("Full Name: ${data['Name']} ${data['last_name']}");

        }
        */
        return Scaffold();

  }
}
