import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kerbros/screens/cartPage.dart';

class Product extends StatelessWidget {
  final String productId;

  const Product({required this.productId, Key? key}) : super(key: key);

  Future<Map<String, dynamic>> fetchAdditionalData(String productId) async {
    // Simulate fetching additional data
    await Future.delayed(Duration(seconds: 2)); // Simulating delay
    return {'reviewsCount': 23, 'relatedProductName': 'Sample Product'};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
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
          final productColor = productData['color']; // Add the color field

          return FutureBuilder<Map<String, dynamic>>(
            future: fetchAdditionalData(productId),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (futureSnapshot.hasError) {
                return Center(child: Text('Error: ${futureSnapshot.error}'));
              }

              final additionalData = futureSnapshot.data!;
              // final reviewsCount = additionalData['reviewsCount'];

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display Product Image inside a Container
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Background color of the container
                        borderRadius: BorderRadius.circular(10), // Optional: Rounded corners
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Clip image to rounded corners
                        child: Image.network(
                          productImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Display Product Name
                    Text(
                      productName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // Display Product Price
                    Text(
                      'Price: \$$productPrice',
                      style: TextStyle(fontSize: 20, color: Colors.green),
                    ),
                    SizedBox(height: 8),
                    // Display Product Color
                    Text(
                      'Color: $productColor',
                      style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                    ),
                    SizedBox(height: 16),
                    // Add to Bag Container
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Cartpage(
                              // productId: productId,
                              // productName: productName,
                              // productImage: productImage,
                              // productPrice: productPrice,
                              // productColor: productColor,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue, // Blue background color
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                        width: 150,
                        child: Center(
                          child: Text(
                            'Add to Bag',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
