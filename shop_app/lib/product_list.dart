import 'package:flutter/material.dart';
import 'package:shop_app/global_variable.dart';
import 'package:shop_app/product_card.dart';
import 'package:shop_app/product_details_page.dart';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ProductList> {
  bool boolSearch = false;
  final List<String> filters = const ['All', 'Addidas', 'Nike', 'Reebok'];

  final TextEditingController textEditingController = TextEditingController();
  List<Map<String, Object>> getSearchItem(String value) {
    List<String> searchWords = value.toLowerCase().split(' ');
    final val = products.where((product) {
      String title = product['company'] as String;

      String lowerCaseTitle = title.toLowerCase();
      final matches =
          searchWords.every((word) => lowerCaseTitle.contains(word));

      return matches;
    }).toList();

    return val;
  }

  List<Map<String, Object>> getFilteredShoes() {
    if (selectedFilter == 'All') {
      return products;
    } else {
      return products
          .where((product) => product['company'] == selectedFilter)
          .toList();
    }
  }

  late String selectedFilter = 'All';
  @override
  void initState() {
    super.initState();
  }

  List<Map<String, Object>> filteredProduct = [];

  final border = OutlineInputBorder(
      borderSide: const BorderSide(
        color: Color.fromRGBO(225, 225, 225, 1),
      ),
      borderRadius: BorderRadius.circular(50));

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (boolSearch == false) {
      filteredProduct = getFilteredShoes();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text('Shoes\nCollection',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Expanded(
                  child: TextField(
                    controller: textEditingController,
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = 'All';
                        filteredProduct = getSearchItem(value);
                        boolSearch = true;
                      });
                    },
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: const Icon(Icons.search),
                      border: border,
                      focusedBorder: border,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filter;
                          boolSearch = false;
                        });
                      },
                      child: Chip(
                        backgroundColor: selectedFilter == filter
                            ? Theme.of(context).colorScheme.primary
                            : const Color.fromRGBO(245, 247, 249, 1),
                        side: const BorderSide(
                          color: Color.fromRGBO(245, 247, 249, 1),
                        ),
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        label: Text(filter),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: size.width > 650
                  ? GridView.builder(
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 2),
                      itemBuilder: (context, index) {
                        final product = products[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ProductDetailsPage(product: product);
                                },
                              ),
                            );
                          },
                          child: ProductCard(
                            title: product['title'] as String,
                            price: product['price'] as double,
                            image: product['imageUrl'] as String,
                            backgroundColor: index.isEven
                                ? const Color.fromRGBO(216, 240, 253, 1)
                                : const Color.fromRGBO(245, 247, 249, 1),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: filteredProduct.length,
                      itemBuilder: (context, index) {
                        final product = filteredProduct[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return ProductDetailsPage(product: product);
                                },
                              ),
                            );
                          },
                          child: ProductCard(
                            title: product['title'] as String,
                            price: product['price'] as double,
                            image: product['imageUrl'] as String,
                            backgroundColor: index.isEven
                                ? const Color.fromRGBO(216, 240, 253, 1)
                                : const Color.fromRGBO(245, 247, 249, 1),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
