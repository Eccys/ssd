# utils.py
import os
import random
import shutil

try:
    import psutil
except ImportError:
    psutil = None


def get_disk_usage(path='/'):
    """Returns disk usage statistics as a dictionary."""
    if not isinstance(path, (str, os.PathLike)):
        raise FileNotFoundError(f"Disk path does not exist: {path}")
    raw_path = os.fspath(path)
    if not isinstance(raw_path, str) or not raw_path.strip() or not os.path.exists(raw_path):
        raise FileNotFoundError(f"Disk path does not exist: {path}")
    abs_path = os.path.abspath(raw_path)
    target = os.path.dirname(abs_path) if os.path.isfile(abs_path) else abs_path
    if psutil is not None:
        usage = psutil.disk_usage(target)
        percent = usage.percent
    else:
        usage = shutil.disk_usage(target)
        percent = round((usage.used / usage.total) * 100, 1) if usage.total else 0.0
    return {
        'total': f"{usage.total / (1024**3):.2f} GB",
        'used': f"{usage.used / (1024**3):.2f} GB",
        'free': f"{usage.free / (1024**3):.2f} GB",
        'percent': f"{percent}%"
    }


def get_wear_level():
    """Returns a simulated wear level for the SSD."""
    # In a real scenario, this would involve complex S.M.A.R.T. data reading.
    # Here, we'll just simulate it.
    return {
        'wear_level': f"{random.uniform(0.1, 5.0):.2f}%",
        'power_on_hours': random.randint(100, 10000),
        'temperature': f"{random.randint(30, 60)}°C"
    }


def run_performance_benchmark():
    """Simulates a simple read/write performance benchmark."""
    # This is a simulation. A real test would write/read a large file.
    print("\nRunning benchmark... (simulation)")
    read_speed = random.uniform(450.0, 550.0)
    write_speed = random.uniform(400.0, 500.0)

    return {
        'sequential_read': f"{read_speed:.2f} MB/s",
        'sequential_write': f"{write_speed:.2f} MB/s"
    }

