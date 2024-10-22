import 'package:flutter/material.dart';
import 'locationcard.dart';
import 'models/categoty.dart';
import 'models/location_card_info.dart';
import 'models/tag.dart';
import 'search_bar.dart';  // Import the search bar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Category> categories = [
    Category(
      name: 'NEAREST LOCATION',
      icon: Icons.location_on,
      cards: [
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        // Add 4 more cards for FEATURED LOCATION
      ],
    ),
    Category(
      name: 'FEATURED LOCATION',
      icon: Icons.star,
      cards: [
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        // Add 4 more cards for FEATURED LOCATION
      ],
    ),
    Category(
      name: 'Eco-tourism area',
      icon: Icons.eco,
      cards: [
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        // Add 4 more cards for FEATURED LOCATION
      ],
    ),
    Category(
      name: 'Museum',
      icon: Icons.museum,
      cards: [
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        // Add 4 more cards for FEATURED LOCATION
      ],
    ),
    Category(
      name: 'Historical site',
      icon: Icons.history,
      cards: [
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        // Add 4 more cards for FEATURED LOCATION
      ],
    ),
    Category(
      name: 'Playground',
      icon: Icons.sports_soccer,
      cards: [
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        // Add 4 more cards for FEATURED LOCATION
      ],
    ),
    Category(
      name: 'Quarter',
      icon: Icons.home_filled,
      cards: [
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        LocationCardInfo(
          locationName: 'Bitexco Financial Tower',
          district: 'Phường 1',
          imageUrl: 'assets/bitexco.png',
          rating: 5.0,
          reviews: 9999,
          distance: 100,
        ),
        // Add 4 more cards for FEATURED LOCATION
      ],
    ),

    // Add more categories like Eco-tourism, Museum, etc.
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const SearchBarHome(),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 400,
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                shrinkWrap: true,
                childAspectRatio: 0.8,
                physics: const NeverScrollableScrollPhysics(),
                children: tagList.map((tag) {
                  return _buildTagItem(tag.thumpnail, tag.nameTag);
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dynamically render category sections
          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: _buildCategorySection(category),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Build each category section dynamically
  Widget _buildCategorySection(Category category) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                category.name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: category.cards.map((card) {
                return LocationCard(
                  locationName: card.locationName,
                  district: card.district,
                  imageUrl: card.imageUrl,
                  rating: card.rating,
                  reviews: card.reviews,
                  distance: card.distance,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8CBD0),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: Colors.black, width: 3), // Border line
                ),
              ),
              child: const Text(
                'SEE ALL',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagItem(String imagePath, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 30,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}