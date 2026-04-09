def remove_duplicates(s: str) -> str:
    """Remove duplicate characters preserving order without using sets."""
    result = ""
    for ch in s:
        if ch not in result:
            result += ch
    return result


if __name__ == "__main__":
    tests = ["aabbcc", "abcabc", "hello", "", "aaaa"]
    for t in tests:
        print(f"{t!r} -> {remove_duplicates(t)!r}")