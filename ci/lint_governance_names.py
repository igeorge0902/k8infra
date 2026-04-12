#!/usr/bin/env python3
import argparse
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]

SPEC_NAME_RE = re.compile(
    r"^speckit\.([a-z0-9]+(?:-[a-z0-9]+)*)\.([a-z0-9]+(?:-[a-z0-9]+)*)\.(plan|specify|tasks)$"
)
PATH_RE = re.compile(r'@Path\("([^"]+)"\)')


def run_git(args):
    res = subprocess.run(["git", *args], cwd=ROOT, capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError(res.stderr.strip() or "git command failed")
    return res.stdout


def changed_files(base, head):
    out = run_git(["diff", "--name-only", base, head])
    return [line.strip() for line in out.splitlines() if line.strip()]


def added_lines_for_file(base, head, file_path):
    out = run_git(["diff", "-U0", base, head, "--", file_path])
    added = []
    for line in out.splitlines():
        if line.startswith("+++"):
            continue
        if line.startswith("+"):
            added.append(line[1:])
    return added


def is_new_endpoint_segment_invalid(path_value):
    # Allow path params and legacy base segments.
    for seg in path_value.split("/"):
        seg = seg.strip()
        if not seg or seg.startswith("{") and seg.endswith("}"):
            continue
        if seg in {"rest", "book", "login", "mbook-1", "mbooks-1", "simple-service-webapp"}:
            continue
        if not re.fullmatch(r"[a-z0-9-]+", seg):
            return True
    return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", required=True)
    parser.add_argument("--head", required=True)
    args = parser.parse_args()

    files = changed_files(args.base, args.head)
    errors = []

    for rel in files:
        p = pathlib.Path(rel)
        if rel.startswith(".specify/features/") and p.name.startswith("speckit."):
            if not SPEC_NAME_RE.fullmatch(p.name):
                errors.append(
                    f"Invalid spec filename '{p.name}'. Expected: speckit.<module>.<feature-or-task>.<plan|specify|tasks>"
                )

        if rel.endswith(".java"):
            for line in added_lines_for_file(args.base, args.head, rel):
                m = PATH_RE.search(line)
                if not m:
                    continue
                pv = m.group(1).strip()
                if is_new_endpoint_segment_invalid(pv):
                    errors.append(
                        f"Invalid new endpoint path segment style in {rel}: '{pv}' (use lowercase kebab-case for new segments)"
                    )

    if errors:
        print("Governance naming lint failed:")
        for e in errors:
            print(f"- {e}")
        return 1

    print("Governance naming lint passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

