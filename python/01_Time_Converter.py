def convert_minutes(n: int) -> str:
    """Convert minutes to hours and minutes using integer division and modulus.
    Handles edge cases: 0 minutes, exact hours, and negative input.
    """
    if n < 0:
        return "Invalid input"

    hours = n // 60
    minutes = n % 60

    if n == 0:
        return "0 hour(s) 0 minute(s)"

    return f"{hours} hour(s) {minutes} minute(s)"


if __name__ == "__main__":
    test_values = [0, 59, 60, 61, 120, 135]
    for val in test_values:
        print(f"{val} minutes -> {convert_minutes(val)}")