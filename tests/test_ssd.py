import contextlib
import io
import pytest

import ssd_monitor
import utils


def test_get_disk_usage_and_missing_path(tmp_path, monkeypatch):
    usage = utils.get_disk_usage(str(tmp_path))
    assert set(usage.keys()) == {"total", "used", "free", "percent"}
    assert usage["total"].endswith(" GB")
    assert usage["percent"].endswith("%")

    file_target = tmp_path / "sample.bin"
    file_target.write_bytes(b"data")
    file_usage = utils.get_disk_usage(str(file_target))
    assert file_usage["total"].endswith(" GB")

    monkeypatch.setattr(utils, "psutil", None)
    fallback_usage = utils.get_disk_usage(str(tmp_path))
    assert set(fallback_usage.keys()) == {"total", "used", "free", "percent"}
    assert fallback_usage["percent"].endswith("%")

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


def test_cli_invalid_path_exits_with_code_1(tmp_path):
    err = io.StringIO()
    with contextlib.redirect_stderr(err):
        with pytest.raises(SystemExit) as excinfo:
            ssd_monitor.main(["--check-health", "--path", str(tmp_path / "missing_dir")])
    assert excinfo.value.code == 1
    assert "does not exist" in err.getvalue()


def test_cli_no_args_prints_help_notice():
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        ssd_monitor.main([])
    assert "No action specified" in buf.getvalue()

