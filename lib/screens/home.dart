import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kerbros/screens/cartPage.dart';
import 'package:kerbros/screens/favoratePage.dart';
import 'package:kerbros/screens/product.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<Map<String, String>>> _offersFuture;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _favoritedProductIds = {};

  @override
  void initState() {
    super.initState();
    _offersFuture = _loadOffers();
    _loadFavoriteProducts();
  }

  Future<List<Map<String, String>>> _loadOffers() async {
    final List<Map<String, String>> offers = [];
    try {
      final QuerySnapshot offersSnapshot = await _firestore.collection('offers').get();
      for (final DocumentSnapshot doc in offersSnapshot.docs) {
        offers.add({
          'image': doc['image'],
          'name': doc['name'],
        });
      }
    } catch (e) {
      print('Error loading offers: $e');
    }
    return offers;
  }

  void _toggleFavorite(String productId) async {
    final favoritesCollection = _firestore.collection('favorites');
    final favoriteDoc = favoritesCollection.doc(productId);

    if (_favoritedProductIds.contains(productId)) {
      setState(() {
        _favoritedProductIds.remove(productId);
      });
      await favoriteDoc.delete();
    } else {
      setState(() {
        _favoritedProductIds.add(productId);
      });
      await favoriteDoc.set({
        'productId': productId,
      });
    }
  }

  Future<void> _loadFavoriteProducts() async {
    final favoritesSnapshot = await _firestore.collection('favorites').get();
    setState(() {
      _favoritedProductIds = favoritesSnapshot.docs.map((doc) => doc['productId'] as String).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("KERBROS", style: TextStyle(fontSize: 22, color: Colors.black)),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_bag, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Cartpage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildOffersCarousel(),
                const SizedBox(height: 32),
                _buildProductList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (query) {
        setState(() {
          _searchQuery = query.toLowerCase();
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search, color: Colors.brown),
        hintText: 'Search products...',
        hintStyle: const TextStyle(color: Colors.brown),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.brown),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.brown),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Colors.brown),
        ),
      ),
    );
  }

  Widget _buildOffersCarousel() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _offersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No offers found', style: TextStyle(color: Colors.white)));
        } else {
          final offers = snapshot.data!;
          return CarouselSlider(
            options: CarouselOptions(
              height: 250,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
            ),
            items: offers.map((offer) {
              return Builder(
                builder: (BuildContext context) {
                  return Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(offer['image']!),
                            fit: BoxFit.fill,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          height: 40,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              offer['name']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products found', style: TextStyle(color: Colors.white)));
        } else {
          final products = snapshot.data!.docs;
          final filteredProducts = products.where((product) {
            final name = (product['name'] as String).toLowerCase();
            return name.contains(_searchQuery);
          }).toList();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.7,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              final isFavorited = _favoritedProductIds.contains(product.id);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Product(productId: product.id),
                    ),
                  );
                },
                child: Card(
                  color: Colors.brown,
                  elevation: 4,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.network(
                              product['image'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product['name'],
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Price: \$${product['price']} \nColor: ${product['color']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.75),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: isFavorited ? Colors.brown : Colors.white,
                            ),
                            onPressed: () {
                              _toggleFavorite(product.id);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
