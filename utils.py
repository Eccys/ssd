# utils.py
import psutil
import random

def get_disk_usage(path='/'):
    """Returns disk usage statistics as a dictionary."""
    usage = psutil.disk_usage(path)
    return {
        'total': f"{usage.total / (1024**3):.2f} GB",
        'used': f"{usage.used / (1024**3):.2f} GB",
        'free': f"{usage.free / (1024**3):.2f} GB",
        'percent': f"{usage.percent}%"
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
