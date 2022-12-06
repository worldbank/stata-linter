from stata_linter_detect import stata_linter_detect_py
import subprocess

class TestCLI:
    def test_cli_bad(self):
        assert subprocess.run(["stata_linter_detect", "test/bad.do"]).returncode == 1
    def test_cli_simple(self):
        assert subprocess.run(["stata_linter_detect", "test/simple.do"]).returncode == 0

class TestDetect:
    def test_basic(self):
        assert stata_linter_detect_py(
        input_file="test/bad.do",
        indent=4,
        suppress="0",
        summary="0",
        excel="",
        linemax=80,
        tab_space=4
        ) == 1

    def test_excel(self):
        assert stata_linter_detect_py(
        input_file="test/bad.do",
        indent=4,
        suppress="0",
        summary="0",
        excel="linter.xlsx",
        linemax=80,
        tab_space=4
        ) == 1

    def test_simple(self):
        assert stata_linter_detect_py(
        input_file="test/simple.do",
        indent=4,
        suppress="0",
        summary="0",
        excel="",
        linemax=80,
        tab_space=4
        ) == 0
