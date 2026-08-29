RATES = {
    "USD": 0.0117,
    "EUR": 0.0100,
    "GBP": 0.0086
}

SYMBOLS = {
    "USD": "$",
    "EUR": "€",
    "GBP": "£"
}


def convert_currency(amount, currency):
    return amount * RATES[currency]


def main():
    print("=" * 40)
    print("       INR CURRENCY CONVERTER")
    print("=" * 40)

    while True:
        try:
            amount = float(input("\nEnter amount in INR: "))

            if amount < 0:
                print("Amount cannot be negative.")
                continue

        except ValueError:
            print("Please enter a valid number.")
            continue

        print("\nChoose currency:")
        print("1. USD - US Dollar")
        print("2. EUR - Euro")
        print("3. GBP - British Pound")
        print("4. Exit")

        choice = input("Enter choice: ").strip()

        currencies = {
            "1": "USD",
            "2": "EUR",
            "3": "GBP"
        }

        if choice == "4":
            print("\nThank you for using the Currency Converter!")
            break

        currency = currencies.get(choice)

        if currency is None:
            print("Invalid choice.")
            continue

        result = convert_currency(amount, currency)

        print(
            f"\n{amount:,.2f} INR = "
            f"{SYMBOLS[currency]}{result:,.2f} {currency}"
        )

        again = input("\nConvert another amount? (y/n): ").strip().lower()

        if again != "y":
            print("\nThank you for using the Currency Converter!")
            break


if __name__ == "__main__":
    main()