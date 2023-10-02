import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});
  @override
  State createState() {
    return _CurrencyConverterPageState();
  }
}

class CurrencyInfo {
  final String countryCode;
  final String country;
  CurrencyInfo(this.countryCode, this.country);
}

class _CurrencyConverterPageState extends State with TickerProviderStateMixin {
  String selectedFromCurrency = '';
  String selectedToCurrency = '';
  List<CurrencyInfo> currencyOptions = [
    CurrencyInfo('USD', 'United States'),
    CurrencyInfo('EUR', 'Eurozone'),
    CurrencyInfo('JPY', 'Japan'),
    CurrencyInfo('GBP', 'United Kingdom'),
    CurrencyInfo('AUD', 'Australia'),
    CurrencyInfo('CAD', 'Canada'),
    CurrencyInfo('CHF', 'Switzerland'),
    CurrencyInfo('CNY', 'China'),
    CurrencyInfo('SEK', 'Sweden'),
    CurrencyInfo('NOK', 'Norway'),
    CurrencyInfo('DKK', 'Denmark'),
    CurrencyInfo('NZD', 'New Zealand'),
    CurrencyInfo('SGD', 'Singapore'),
    CurrencyInfo('HKD', 'Hong Kong'),
    CurrencyInfo('KRW', 'South Korea'),
    CurrencyInfo('INR', 'India'),
    CurrencyInfo('BRL', 'Brazil'),
    CurrencyInfo('ZAR', 'South Africa'),
    CurrencyInfo('AED', 'UAE')
  ];

  double result = 0;
  final TextEditingController textEditingController = TextEditingController();
  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> getExchangeRates() async {
    final apiUrl = 'https://open.er-api.com/v6/latest/$selectedFromCurrency';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      throw Exception('Failed to make the API request: $e');
    }
  }

  Future<void> convertCurrency() async {
    final exchangeRates = await getExchangeRates();

    final exchangeRate = exchangeRates['rates'][selectedToCurrency];

    final amount = double.parse(textEditingController.text);
    final convertedAmount = amount * exchangeRate;

    setState(() {
      result = convertedAmount;
    });
  }

  bool containsSpecialCharacters(String text) {
    final pattern = RegExp(r'^[\d.]+$');
    return !pattern.hasMatch(text);
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Animation duration
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear, // Animation curve
      ),
    );
    // Add a listener to the text field controller
    textEditingController.addListener(() {
      if (textEditingController.text.isEmpty) {
        // Reset the result and animation if the text field is empty
        setState(() {
          result = 0;
          _controller.reset();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fBorder = OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 185, 2, 32),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(40));
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(56.0), // Set the desired height of the AppBar
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(167, 35, 48, 140),
                Color.fromARGB(161, 43, 42, 42)
              ],
              begin: Alignment.topLeft, // Alignment for the gradient
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            title: const Text(
              'Currency Converter',
            ),
            centerTitle: true,
            backgroundColor:
                Colors.transparent, // Make the AppBar background transparent
          ),
        ),
      ),
      backgroundColor:
          Colors.transparent, // Make the Scaffold's background transparent
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(167, 27, 42, 138),
              Color.fromARGB(255, 86, 84, 84)
            ], // Define your gradient colors
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _animation,
                child: Text(
                  (result != 0 ? result.toStringAsFixed(2) : '0'),
                  style: const TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              const SizedBox(height: 11),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: DropdownSearch<String>(
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Convert From',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        baseStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Search',
                          ),
                        ),
                      ),
                      items: currencyOptions
                          .map((currencyInfo) =>
                              '${currencyInfo.countryCode} - ${currencyInfo.country}')
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          final finalValue = value.split('-')[0];

                          setState(() {
                            selectedFromCurrency = finalValue.trim();
                          });
                        }
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20.0),
                    child: DropdownSearch<String>(
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          floatingLabelAlignment: FloatingLabelAlignment.start,
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Convert To',
                          labelStyle: TextStyle(
                            color: Color.fromARGB(255, 120, 116, 5),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        baseStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            labelText: 'Search',
                          ),
                        ),
                      ),
                      items: currencyOptions
                          .map((currencyInfo) =>
                              '${currencyInfo.countryCode} - ${currencyInfo.country}')
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          final finalValue1 = value.split('-')[0];

                          setState(() {
                            selectedToCurrency = finalValue1.trim();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textEditingController,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Please enter the amount',
                    hintStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                    prefixIcon: const Icon(
                      Icons.money,
                    ),
                    prefixIconColor: Colors.black,
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(60),
                    ),
                    focusedBorder: fBorder,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Check if the text field is empty
                    if (textEditingController.text.isEmpty) {
                      // Show a message to the user
                      showErrorMessage(
                          'Please enter a value before converting.');
                      setState(() {
                        result = 0;
                      });
                    } else if (selectedFromCurrency.isEmpty ||
                        selectedToCurrency.isEmpty) {
                      showErrorMessage('Please select both currencies.');
                    } else if (containsSpecialCharacters(
                        textEditingController.text)) {
                      // Show a message to the user
                      showErrorMessage(
                          'Special characters and commas are not allowed.');
                      textEditingController.clear();
                      setState(() {
                        result = 0;
                        _controller.reset();
                      });
                    } else {
                      // Perform the conversion

                      setState(() {
                        convertCurrency();
                        _controller.reset();
                        _controller.forward();
                      });
                    }
                  },
                  style: const ButtonStyle(
                    overlayColor: MaterialStatePropertyAll(
                        Color.fromARGB(255, 60, 52, 52)),
                    elevation: MaterialStatePropertyAll(15),
                    backgroundColor: MaterialStatePropertyAll(Colors.black),
                    foregroundColor: MaterialStatePropertyAll(Colors.white),
                    minimumSize:
                        MaterialStatePropertyAll(Size(double.infinity, 50)),
                  ),
                  child: const Text(
                    'Convert',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
