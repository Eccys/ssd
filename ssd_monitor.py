# ssd_monitor.py
import argparse
from utils import get_disk_usage, get_wear_level, run_performance_benchmark

def main():
    parser = argparse.ArgumentParser(description="A simple SSD Health & Performance Monitor.")
    parser.add_argument('--check-health', action='store_true', help='Check disk usage and simulated health.')
    parser.add_argument('--run-benchmark', action='store_true', help='Run a simulated performance benchmark.')

    args = parser.parse_args()

    if args.check_health:
        print("--- SSD Health Report ---")
        
        print("\n[Disk Usage]")
        usage = get_disk_usage()
        for key, value in usage.items():
            print(f"{key.capitalize()}: {value}")
            
        print("\n[Simulated Health Stats]")
        health = get_wear_level()
        for key, value in health.items():
            print(f"{key.replace('_', ' ').capitalize()}: {value}")
        
        print("\nReport finished.")

    elif args.run_benchmark:
        print("--- SSD Performance Benchmark ---")
        performance = run_performance_benchmark()
        for key, value in performance.items():
            print(f"{key.replace('_', ' ').capitalize()}: {value}")
        print("\nBenchmark finished.")

    else:
        print("No action specified. Use --help for options.")

if __name__ == "__main__":
    main()
