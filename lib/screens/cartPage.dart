import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cartpage extends StatefulWidget {
  const Cartpage({super.key});

  @override
  State<Cartpage> createState() => _CartpageState();
}

class _CartpageState extends State<Cartpage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateQuantity(String docId, int quantity) async {
    if (quantity > 0) {
      await _firestore.collection('cart').doc(docId).update({'quantity': quantity});
    } else {
      await _firestore.collection('cart').doc(docId).delete();
    }
  }

  Future<void> deleteItem(String docId) async {
    await _firestore.collection('cart').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: Text(
          "Cart Page",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('cart').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final cartItems = snapshot.data?.docs ?? [];
                    double totalPrice = 0.0;

                    if (cartItems.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.3),
                          child: Text(
                            "Your cart is empty",
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.brown,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index].data() as Map<String, dynamic>;
                            final docId = cartItems[index].id;

                            final imgUrl = item['image'] ?? '';
                            final isValidUrl = Uri.tryParse(imgUrl)?.hasAbsolutePath ?? false;

                            int quantity = item['quantity'] ?? 1;
                            double price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;

                            totalPrice += price * quantity;

                            return Dismissible(
                              key: Key(docId),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                deleteItem(docId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Item removed from cart')),
                                );
                              },
                              background: Container(
                                color: Colors.brown,
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.delete, color: Colors.white, size: 40),
                              ),
                              child: Card(
                                color: Colors.white,
                                elevation: 5,
                                margin: EdgeInsets.all(screenWidth * 0.02),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: isValidUrl
                                        ? Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                      width: screenWidth * 0.15,
                                      height: screenWidth * 0.15,
                                    )
                                        : Icon(Icons.error, size: screenWidth * 0.15, color: Colors.redAccent),
                                  ),
                                  title: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'] ?? 'N/A',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Color: ${item['color'] ?? 'N/A'}',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: Colors.brown,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove_circle, color: Colors.brown),
                                                onPressed: quantity > 1
                                                    ? () {
                                                  setState(() {
                                                    quantity--;
                                                  });
                                                  updateQuantity(docId, quantity);
                                                }
                                                    : () {
                                                  setState(() {
                                                    quantity = 0;
                                                  });
                                                  updateQuantity(docId, quantity);
                                                },
                                              ),
                                              Text(
                                                '$quantity',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add_circle, color: Colors.brown),
                                                onPressed: () {
                                                  setState(() {
                                                    quantity++;
                                                  });
                                                  updateQuantity(docId, quantity);
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Price: \$${price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          color: Colors.brown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Container(
              color: Colors.brown,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$Total Price:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
