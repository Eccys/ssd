# ssd_monitor.py
import argparse
import sys
from utils import get_disk_usage, get_wear_level, run_performance_benchmark


def main(argv=None):
    parser = argparse.ArgumentParser(description="A simple SSD Health & Performance Monitor.")
    parser.add_argument('--check-health', action='store_true', help='Check disk usage and simulated health.')
    parser.add_argument('--run-benchmark', action='store_true', help='Run a simulated performance benchmark.')
    parser.add_argument('--path', default='/', help='Filesystem path or mount point to inspect (default: /).')

    args = parser.parse_args(argv)

    if not args.check_health and not args.run_benchmark:
        print("No action specified. Use --help for options.")
        return

    if args.check_health:
        print("--- SSD Health Report ---")

        print("\n[Disk Usage]")
        try:
            usage = get_disk_usage(args.path)
        except OSError as exc:
            print(f"Error reading disk usage for '{args.path}': {exc}", file=sys.stderr)
            sys.exit(1)
        for key, value in usage.items():
            print(f"{key.capitalize()}: {value}")

        print("\n[Simulated Health Stats]")
        health = get_wear_level()
        for key, value in health.items():
            print(f"{key.replace('_', ' ').capitalize()}: {value}")

        print("\nReport finished.")

    if args.run_benchmark:
        print("--- SSD Performance Benchmark ---")
        performance = run_performance_benchmark()
        for key, value in performance.items():
            print(f"{key.replace('_', ' ').capitalize()}: {value}")
        print("\nBenchmark finished.")


if __name__ == "__main__":
    main()

