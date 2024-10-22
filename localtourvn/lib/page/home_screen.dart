import 'package:flutter/material.dart';
import '../locationcard.dart';
import '../models/categoty.dart';
import '../models/location_card_info.dart';
import '../models/tag.dart';
import '../search_bar_icon.dart';
import 'detailpage.dart';

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

      ],
    ),


  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const SearchBarIcon(),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 400,
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.black, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26, // Darker shadow color
                    blurRadius: 5, // Reduced blur for a sharper shadow
                    offset: Offset(10, 20), // Shadow positioned to bottom-right
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



          ...categories.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: _buildCategorySection(category),
            );
          }),
        ],
      ),
    );
  }


  Widget _buildCategorySection(Category category) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, color: Colors.red),
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
                return GestureDetector(
                    onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailPage(),
                    ),
                  );
                },
                child: LocationCard(
                  locationName: card.locationName,
                  district: card.district,
                  imageUrl: card.imageUrl,
                  rating: card.rating,
                  reviews: card.reviews,
                  distance: card.distance,
                ),
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
                  side: const BorderSide(color: Colors.black, width: 3),
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
          style: const TextStyle(fontSize: 12,fontWeight: FontWeight.bold,),

        ),
      ],
    );
  }
}