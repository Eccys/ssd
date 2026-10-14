import contextlib
import io
import pytest

import ssd_monitor
import utils


def test_get_disk_usage_and_missing_path(tmp_path):
    usage = utils.get_disk_usage(str(tmp_path))
    assert set(usage.keys()) == {"total", "used", "free", "percent"}
    assert usage["total"].endswith(" GB")
    assert usage["percent"].endswith("%")

    with pytest.raises(FileNotFoundError, match="does not exist"):
        utils.get_disk_usage(str(tmp_path / "nonexistent_mount"))


def test_wear_level_and_benchmark():
    wear = utils.get_wear_level()
    assert wear["wear_level"].endswith("%")
    assert 100 <= wear["power_on_hours"] <= 10000
    assert wear["temperature"].endswith("°C")

    bench = utils.run_performance_benchmark()
    assert bench["sequential_read"].endswith(" MB/s")
    assert bench["sequential_write"].endswith(" MB/s")


def test_cli_runs_both_health_and_benchmark_together(tmp_path):
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        ssd_monitor.main(["--check-health", "--run-benchmark", "--path", str(tmp_path)])
    out = buf.getvalue()
    assert "--- SSD Health Report ---" in out
    assert "--- SSD Performance Benchmark ---" in out
    assert "Report finished." in out
    assert "Benchmark finished." in out


def test_cli_no_args_prints_help_notice():
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        ssd_monitor.main([])
    assert "No action specified" in buf.getvalue()
