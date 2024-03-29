// ignore_for_file: prefer_typing_uninitialized_variables
import 'package:flutter/material.dart';
import 'package:meals_app/models/category.dart';

class CategoryGridItem extends StatelessWidget {
  const CategoryGridItem(
      {super.key, required this.category, required this.onSelectCategory});
  final Category category;
  final onSelectCategory;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelectCategory,
      splashColor: Theme.of(context).primaryColor,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              category.color.withOpacity(0.9),
              category.color.withOpacity(0.55),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Text(
          category.title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.w400,
              ),
        ),
      ),
    );
  }
}
