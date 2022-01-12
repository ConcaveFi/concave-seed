import os
os.system('cls' if os.name == 'nt' else 'clear')

percent_vested = 0.2

# Alice

a_starting_purchased = 100
a_starting_redeemed = 10
a_starting_redeemable = a_starting_purchased * percent_vested - a_starting_redeemed

# Bob

b_starting_purchased = 100
b_starting_redeemed = 20 
b_starting_redeemable = b_starting_purchased * percent_vested - b_starting_redeemed

# _beforeTokenTransfer(Alice, Bob, 50)

amount_alice_sent = 50

# Alice

a_ending_purchased = a_starting_purchased - amount_alice_sent
a_ending_redeemed = a_ending_purchased * a_starting_redeemed / a_starting_purchased
a_ending_redeemable = a_ending_purchased * percent_vested - a_ending_redeemed

# Bob

b_ending_purchased = b_starting_purchased + amount_alice_sent
b_ending_redeemed = b_starting_redeemed + amount_alice_sent * a_starting_redeemed / a_starting_purchased
b_ending_redeemable = b_ending_purchased * percent_vested - b_ending_redeemed

print("##################  START  #################")

print(f"Alice Starting Purchased: {a_starting_purchased}")
print(f"Alice Starting Redeemed: {a_starting_redeemed}")
print(f"Alice Starting Redeemable: {a_starting_redeemable}")

print("###########################################")

print(f"Bob Starting Purchased: {b_starting_purchased}")
print(f"Bob Starting Redeemed: {b_starting_redeemed}")
print(f"Bob Starting Rededemable {b_starting_redeemable}")

print("###########################################")

print(f"Alice Ending Purchased: {a_ending_purchased}")
print(f"Alice Ending Redeemed: {a_ending_redeemed}")
print(f"Alice Ending Redeemable: {a_ending_redeemable}")

print("###########################################")

print(f"Bob Ending Purchased: {b_ending_purchased}")
print(f"Bob Ending Redeemed: {b_ending_redeemed}")
print(f"Bob Ending Redeemable: {b_ending_redeemable}")

print("###########################################")

print(f"Total Redeemable Before: {a_starting_redeemable + b_starting_redeemable}")
print(f"Total Redeemable After: {a_ending_redeemable + b_ending_redeemable}")

print("###########################################")

print(f"Safu: {a_starting_redeemable + b_starting_redeemable == a_ending_redeemable + b_ending_redeemable}")

print("###########################################")