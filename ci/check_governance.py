#!/usr/bin/env python3
import argparse
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]


def run_step(name: str, script: str, base: str, head: str) -> int:
    cmd = [sys.executable, str(ROOT / "k8infra" / "ci" / script), "--base", base, "--head", head]
    print(f"\n[governance] Running {name}: {' '.join(cmd)}")
    proc = subprocess.run(cmd, cwd=ROOT)
    if proc.returncode != 0:
        print(f"[governance] {name} failed with exit code {proc.returncode}")
    else:
        print(f"[governance] {name} passed")
    return proc.returncode


def main() -> int:
    parser = argparse.ArgumentParser(description="Run local governance checks in one command.")
    parser.add_argument("--base", default="HEAD~1", help="Git base ref (default: HEAD~1)")
    parser.add_argument("--head", default="HEAD", help="Git head ref (default: HEAD)")
    args = parser.parse_args()

    failures = 0
    failures += run_step("naming lint", "lint_governance_names.py", args.base, args.head)
    failures += run_step("doc drift", "check_doc_drift.py", args.base, args.head)

    if failures:
        print("\n[governance] One or more checks failed.")
        return 1

    print("\n[governance] All checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

