import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localtourapp/base/back_to_top_button.dart';
import 'package:localtourapp/base/weather_icon_button.dart';
import 'package:localtourapp/models/posts/post.dart';
import 'package:localtourapp/models/schedule/schedule.dart';
import 'package:localtourapp/page/account/view_profile/post_provider.dart';
import 'package:localtourapp/page/detail_page/detail_page_tab_bars/count_provider.dart';
import 'package:provider/provider.dart';

class PostTabBar extends StatefulWidget {
  final List<Post> posts;
  final List<Schedule> schedules;


  const PostTabBar({
    super.key,
    required this.posts,
    required this.schedules,
  });

  @override
  State<PostTabBar> createState() => _PostTabBarState();
}

class _PostTabBarState extends State<PostTabBar> {
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;
  final FocusNode _nameFocusNode = FocusNode();
  String bullet = "\u2022 ";
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    searchFocusNode.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _navigateToWeatherPage() {
    Navigator.pushNamed(context, '/weather');
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onDateSelected(DateTime? newDate, bool isFromDate) {
    setState(() {
      if (isFromDate) {
        _fromDate = newDate;
      } else {
        _toDate = newDate;
      }
    });
  }

  List<Schedule> getFilteredSchedules() {
    String searchText = searchController.text.toLowerCase();
    final filtered = widget.schedules.where((schedule) {
      final matchesName =
      schedule.scheduleName.toLowerCase().contains(searchText);
      final matchesDate = (_fromDate == null ||
          (schedule.startDate != null &&
              schedule.startDate!.isAfter(_fromDate!))) &&
          (_toDate == null ||
              (schedule.endDate != null &&
                  schedule.endDate!.isBefore(_toDate!)));
      return matchesName && matchesDate;
    }).toList();
    return filtered;
  }

  void _scrollListener() {
    if (_scrollController.offset >= 200 && !_showBackToTopButton) {
      setState(() {
        _showBackToTopButton = true;
      });
    } else if (_scrollController.offset < 200 && _showBackToTopButton) {
      setState(() {
        _showBackToTopButton = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //build widget here:
                    _buildFilterSection(),
                    const SizedBox(height: 20),
                    _buildButtonsSection(),
                    const SizedBox(height: 10),
                    // _buildPostSection(),

                  ],
                ),
              ),
            ),
          ),
        ),
        //this is for WeatherIconButton and BackToTopButton
        Positioned(
          bottom: 0,
          left: 20,
          child: WeatherIconButton(
            onPressed: _navigateToWeatherPage,
            assetPath: 'assets/icons/weather.png',
          ),
        ),
        Positioned(
          bottom: 12,
          left: 110,
          child: AnimatedOpacity(
            opacity: _showBackToTopButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: _showBackToTopButton
                ? BackToTopButton(
              onPressed: _scrollToTop,
            )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 40,
          width: 250,
          child: TextField(
            controller: searchController,
            focusNode: searchFocusNode,
            decoration: const InputDecoration(
              labelText: "Search by name",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDateField(
                "From Date",
                true,
                _fromDate,
                    (newDate) {
                  _onDateSelected(newDate, true);
                },
                clearable: true,
                onClear: () {
                  _onDateSelected(null, true);
                }),
            const SizedBox(width: 5),
            _buildDateField(
                "To Date",
                false,
                _toDate,
                    (newDate) {
                  _onDateSelected(newDate, false);
                },
                clearable: true,
                onClear: () {
                  _onDateSelected(null, false);
                }),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if ((_fromDate != null && _toDate == null) ||
                (_fromDate == null && _toDate != null)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Please choose both "From Date" and "To Date" for filtering.')),
              );
              return;
            }
            setState(() {});
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDCA1A1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.black, width: 2),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          ),
          child: const Text(
            "Search",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
      String labelText,
      bool isFromDate,
      DateTime? initialDate,
      Function(DateTime) onDateChanged, {
        bool clearable = false,
        VoidCallback? onClear,
      }) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      child: Stack(
        children: [
          AbsorbPointer(
            child: SizedBox(
              height: 30,
              width: 160,
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: initialDate != null
                      ? DateFormat('yyyy-MM-dd').format(initialDate)
                      : labelText,
                  hintStyle: const TextStyle(fontSize: 12),
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
          ),
          if (clearable && initialDate != null)
            Positioned(
              right: 5,
              top: 5,
              child: GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButtonsSection() {
    final postProvider =
    Provider.of<PostProvider>(context, listen: false);
    final posts = postProvider.posts;
    return Container(
      child:
          ElevatedButton.icon(
            onPressed: () {
              // showAddPostDialog(context,
              //         (postName, startDate, endDate) {
              //       final newPost = Post(
              //         id: widget.posts.length + 1,
              //         createdAt: DateTime.now(),
              //         isPublic: false,
              //         authorId: '',
              //         title: '',
              //         updatedAt: DateTime.now(),
              //         content: '',
              //       );
              //
              //       // Add schedule using ScheduleProvider
              //       Provider.of<PostProvider>(context, listen: false)
              //           .addPost(newPost);
              //       // Increment schedule count in CountProvider
              //       Provider.of<CountProvider>(context, listen: false)
              //           .incrementPostCount();
              //     });
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add Post"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
    );
  }
}
