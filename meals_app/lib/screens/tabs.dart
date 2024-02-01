import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:meals_app/Auth/auth.dart';
import 'package:meals_app/screens/filter_screen.dart';
import 'package:meals_app/screens/favourite_meals.dart';
import 'package:meals_app/screens/categories.dart';
import 'package:meals_app/widgets/main_drawer.dart';
import 'package:meals_app/provider/meals_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals_app/provider/favourite_meals_provider.dart';
import 'package:meals_app/provider/filters_provider.dart';

const kinitialFilters = {
  Filter.glutenFree: false,
  Filter.lactoseFree: false,
  Filter.vegetarian: false,
  Filter.vegan: false,
};

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen> {
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'filters') {
      await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (context) => const FilterScreen(),
        ),
      );
    }
  }

  PageRouteBuilder _createRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const AuthScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuart;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealsProvider);
    final activeFilters = ref.watch(filtersProvider);
    final availableMeals = meals.where((meal) {
      if (activeFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (activeFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (activeFilters[Filter.vegetarian]! && !meal.isVegetarian) {
        return false;
      }
      if (activeFilters[Filter.vegan]! && !meal.isVegan) {
        return false;
      }
      return true;
    }).toList();
    Widget activeScreen = CategoriesScreen(
      availableMeals: availableMeals,
      //onToggleFavourite: _selectFavoriteMeals,
    );
    var activeScreenTitle = 'Categories';
    if (_selectedPageIndex == 1) {
      final favouriteMeals = ref.watch(favouriteMealsProvider);
      activeScreen = FavouriteMealScreen(
        meals: favouriteMeals,
        //onToggleFavourite: _selectFavoriteMeals
      );
      activeScreenTitle = 'Favourites';
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              Future.delayed(const Duration(seconds: 1), () {
                FirebaseAuth.instance.signOut();
              });

              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(context, _createRoute());
            },
            // ignore: sized_box_for_whitespace
            child: Container(
              width: 35,
              child: Lottie.asset('assets/animations/logout_animation.json'),
            ),
          ),
          /*
          IconButton(
              onPressed: () {
                Future.delayed(const Duration(seconds: 1), () {
                  FirebaseAuth.instance.signOut();
                });

                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(context, _createRoute());
              },
              icon: const Icon(Icons.logout_outlined),) */
        ],
        title: Text(
          activeScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      drawer: SideDrawer(
        onSelectScreen: _setScreen,
      ),
      body: activeScreen,
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.set_meal), label: 'Categories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.star_rate_rounded), label: 'Favourites'),
        ],
      ),
    );
  }
}
