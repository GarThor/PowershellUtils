[String[]]$Bases = @("Gluten Free Crust", "Thin Crust", "Stuffed Crust", "Deep Dish");
$Bases;
[String[]]$Sauces = @("BBQ", "Garlic Rub", "Olive Oil", "Pesto", "Red Sauce", "Spicy Calabrian Chilli Red Sauce", "White Sauce");
$Sauces
[String[]]$Cheeses = @("Motzarella", "Feta", "Asiago", "Dairy-Free", "Gorgonzola", "Parmesan", "Ricota");
$Cheeses
[String[]]$Meats = @(
    "Anchovies", "Bacon", "Canadian Bacon", 
    "Chicken Jalepeno Sausage", "Grilled Chicken", "Ground Beef", 
    "Mild Sausage", "Pepperoni", "Plant-Based Italian Sausage", 
    "Salami", "Spicy Chicken Sausage");
$Meats
[String[]]$Vegies = @(
    "Artichokes", "Arugula", "Basil (Fresh Chopped)",
    "Black Olives", "Broccoli - Roasted", "Cauliflower - Roasted",
    "Corm", "Garlic - Chopped", "Garlic - Roasted",
    "Green Bell Peppers", "Mama's Lils Sweet Hots", "Mushrooms",
    "Oregano", "Pineapple", "Red Onion",
    "Red Peppers - Roasted", "Roasemary - Fresh Chopped", "Salt & Pepper",
    "Spinach", "Tomatoes - Diced", "Tomatoes - Sliced");
$Vegies
[String[]]$FinishingSauces = @(
    "Balsamic Fig Glaze", "BBQ Swirl", "Hot Buffalo Sauce", 
    "Mikes Hot HOney", "Pesto Drizzle", "Ranch",
    "Red Sauce Dollops", "Sri-rancha");
$FinishingSauces

Export-ModuleMember -Variable "Bases","Sauces","Cheeses","Meats","Vegies","FinishingSauces"