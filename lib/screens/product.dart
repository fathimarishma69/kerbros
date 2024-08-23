import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cartPage.dart';

class Product extends StatelessWidget {
  final String productId;

  const Product({required this.productId, Key? key}) : super(key: key);

  Future<void> addToCart(Map<String, dynamic> productData) async {
    final cartRef = FirebaseFirestore.instance.collection('cart').doc(
        productData['id']);
    await cartRef.set(productData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('products').doc(productId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Product not found'));
          }

          final productData = snapshot.data!.data() as Map<String, dynamic>;
          final productName = productData['name'];
          final productImage = productData['image'];
          final productPrice = productData['price'];
          final productColor = productData['color'];
          final productDescription =
              productData['description']; // Fetch description

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      productImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  productName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Price: \$$productPrice',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  'Color: $productColor',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                SizedBox(height: 8),
                Text(
                  'Description:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  productDescription, // Display description
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    await addToCart({
                      'id': productId,
                      'name': productName,
                      'image': productImage,
                      'price': productPrice,
                      'color': productColor,
                      'description': productDescription,
                    });

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Cartpage(),
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    // Set height to 50
                    width: 150,
                    // Set width to 150
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8), // Space between icon and text
                        Text(
                          'Add to Bag',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
