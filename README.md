# Totalitea
Totalitea Code

Client Information:

Website:
- Attractive and guide customers towards certain choices
- Keep simple (unlike Amazon)
- Username and password dont need to be restricted but should be unique
- Client wanted social media login features
- Ability to add items
- Basic input for credit card details - possibly store details
- Have search bar and filter(category) on side 

Demographic:
- Mid 20s to late 30s
- Sells both premium and regular drinks.
- UK Only

Extra information:
- Stock - Keep in mind they have set amount of stock. Assume pulling from their system 
	but create a basic file with information and pull it from there (not a requirement)
- Track when someone creates an account and the transactions that have taken place




Stuart / Steve Tips
Finding username and password:
String sql = "SELECT * FROM users WHERE email = ? and password = ?";
-gives back user and password
-will return 0 rows if wrong "0 rows selected"
-count number of rows selected which would return 0 or 1
-if 0 then give back message stating invalid user/pass (redirect to login page)
-if 1 then login and redirect to main page (Stuart stated something more complicated can be done?)

Once logged in have username appear at top of page.
