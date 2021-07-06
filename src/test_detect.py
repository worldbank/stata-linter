from stata_linter_detect import stata_linter_detect_py, run

class TestDetect:
    def test_basic(self):
        stata_linter_detect_py(
        input_file="test/bad.do",
        indent=4,
        nocheck="0", 
        suppress="0",
        summary="0",
        excel="",
        linemax=80,
        tab_space=4
        )
