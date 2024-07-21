import 'package:flutter/material.dart';

class SearchTextfieldWidget extends StatelessWidget {
  final TextEditingController? searchController;
  final void Function(String)? onChanged;
  final void Function()? onPressed;
  final double height;
  final double width;

  const SearchTextfieldWidget({
    Key? key,
    this.searchController,
    this.onChanged,
    this.onPressed,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04),
      child: SizedBox(
        height: height * 0.08,
        width: width,
        child: TextField(
          controller: searchController,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(0),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15),
            ),
            hintText: "Search",
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9F9A9A),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: height * 0.035,
              color: const Color(0xFF9F9A9A),
            ),
            suffixIcon: Material(
              color: Colors.transparent,
              child: IconButton(
                splashColor: Colors.blue, // replace with your primary color
                splashRadius: 23,
                onPressed: onPressed,
                icon: const Icon(
                  Icons.clear,
                  color: Colors.blue, // replace with your primary color
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
