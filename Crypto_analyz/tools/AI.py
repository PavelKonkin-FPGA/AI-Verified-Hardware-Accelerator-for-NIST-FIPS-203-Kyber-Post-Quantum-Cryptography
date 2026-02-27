import sys
import os


def analyze_simulation_logs(log_file="simulation_output.log"):
    if not os.path.exists(log_file):
        print("[TinyML] Error: Log file not found.")
        return False

    Q = 3329
    results = []

    with open(log_file, "r") as f:
        for line in f:
            if "RAM[" in line:
                try:
                    val = int(line.split('=')[1].split('(')[0].strip())
                    results.append(val)
                except:
                    continue

    if not results:
        print("[TinyML] Status: NO DATA to analyze.")
        return False

    anomalies = [x for x in results if x >= Q or x < 0]
    stuck_at_zero = all(x == 0 for x in results)

    print("\n--- TinyML Security Audit ---")
    if stuck_at_zero:
        print("RESULT: [CRITICAL] Signal stuck at 0. Check Reset or Clock.")
    elif anomalies:
        print(f"RESULT: [WARNING] Data overflow detected! Found {len(anomalies)} invalid values.")
    else:
        print("RESULT: [SUCCESS] NTT Data Distribution is HEALTHY.")
    print("-----------------------------\n")


if __name__ == "__main__":
    analyze_simulation_logs()