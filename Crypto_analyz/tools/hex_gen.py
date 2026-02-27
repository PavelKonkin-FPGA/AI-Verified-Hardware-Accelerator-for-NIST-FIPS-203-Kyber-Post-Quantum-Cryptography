import os


def generate_kyber_twiddles(filename="twiddle_table.hex"):
    Q = 3329
    zeta = 1750

    twiddles = [pow(zeta, i, Q) for i in range(256)]

    with open(filename, 'w') as f:
        for val in twiddles:
            # Пишем только HEX значение, 3 знака (12 бит)
            f.write(f"{val:03X}\n")

    with open("twiddle_table.ver", 'w') as f:
        for val in twiddles:
            f.write(f"{val:03X}\n")

    print(f"Success! Files updated. Total rows: {len(twiddles)}")


if __name__ == "__main__":
    generate_kyber_twiddles()