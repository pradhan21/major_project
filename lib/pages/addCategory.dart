import 'package:flutter/material.dart';
import '../json/create_budget_json.dart';

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final List<String> iconOptions = [
    "assets/images/auto.png",
    "assets/images/bank.png",
    "assets/images/cash.png",
    "assets/images/charity.png",
    "assets/images/eating.png",
    "assets/images/gift.png",
  ];

  FocusNode nameFocusNode = FocusNode();
  TextEditingController _nameController = TextEditingController();

  String? selectedIcon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Category'),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              focusNode: nameFocusNode,
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Category Name'),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedIcon,
              items: iconOptions.map((icon) {
                return DropdownMenuItem<String>(
                  value: icon,
                  child: ImageIcon(AssetImage(icon)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedIcon = value;
                });
              },
              decoration: InputDecoration(labelText: 'Select Icon'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Retrieve the category name and selected icon
                String categoryName = _nameController.text;

                // Create a new Category object
                BudgetCategory newCategory = BudgetCategory(
                  name: categoryName,
                );

                // Pass the new category back to the previous page
                Navigator.pop(context, newCategory);
              },
              child: Text('Save Category'),
            ),
          ],
        ),
      ),
    );
  }
}

