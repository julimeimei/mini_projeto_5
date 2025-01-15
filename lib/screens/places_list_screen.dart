import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mini_projeto_5/provider/places_model.dart';
import 'package:mini_projeto_5/screens/place_details_screen.dart';
import 'package:mini_projeto_5/utils/db_util.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_routes.dart';

class PlacesListScreen extends StatefulWidget {
  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  bool _hasCallSupport = false;
  @override
  void initState() {
    super.initState();
    Provider.of<PlacesModel>(context, listen: false).loadPlaces();
    canLaunchUrl(Uri(scheme: 'tel', path: '123')).then((bool result) {
      setState(() {
        _hasCallSupport = result;
        print(result);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(
          'Meus Lugares',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.PLACE_FORM);
            },
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Places')),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Tela inicial'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.place),
              title: const Text('Gerenciar lugares'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => PlacesListScreen()),
                    (route) => false);
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: Provider.of<PlacesModel>(context, listen: false).loadPlaces(),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(child: CircularProgressIndicator())
                : Consumer<PlacesModel>(
                    child: Center(
                      child: Text('Nenhum local'),
                    ),
                    builder: (context, places, child) => places.itemsCount == 0
                        ? child!
                        : ListView.builder(
                            itemCount: places.itemsCount,
                            itemBuilder: (context, index) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    FileImage(places.itemByIndex(index).image),
                              ),
                              title: Text(places.itemByIndex(index).title),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => PlaceDetailScreen(
                                      places.itemByIndex(index),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
      ),
    );
  }
}
