#!/usr/bin/env python3
import argparse
import pathlib
import re
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
CONTRACTS_INDEX = ROOT / ".github" / "references" / "CONTRACTS_INDEX.md"
SPEC_ROOT = ROOT / ".specify" / "features"

PATH_RE = re.compile(r'@Path\("([^"]+)"\)')
SERVLET_RE = re.compile(r'@WebServlet\([^\)]*"([^"]+)"[^\)]*\)')

IGNORED_PATHS = {
    "/rest",
    "/book",
    "/login",
    "/mbook-1",
    "/mbooks-1",
    "/simple-service-webapp",
}


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


def extract_new_paths(base, head, files):
    result = {}
    for rel in files:
        if not rel.endswith(".java"):
            continue
        added = added_lines_for_file(base, head, rel)
        paths = []
        for line in added:
            for pat in (PATH_RE, SERVLET_RE):
                m = pat.search(line)
                if not m:
                    continue
                p = m.group(1).strip()
                if p in IGNORED_PATHS:
                    continue
                if len(p) <= 1:
                    continue
                paths.append(p)
        if paths:
            result[rel] = paths
    return result


def module_from_path(rel):
    parts = rel.split("/")
    for p in parts:
        if p.endswith("-quarkus"):
            return p
    return None


def contains_in_spec(path_text):
    if not SPEC_ROOT.exists():
        return False
    for p in SPEC_ROOT.rglob("*"):
        if p.suffix not in {".plan", ".specify", ".tasks", ".md"}:
            continue
        try:
            txt = p.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        if path_text in txt:
            return True
    return False


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", required=True)
    parser.add_argument("--head", required=True)
    args = parser.parse_args()

    files = changed_files(args.base, args.head)
    new_paths = extract_new_paths(args.base, args.head, files)

    if not new_paths:
        print("No new endpoint annotations detected in changed Java files.")
        return 0

    contracts_txt = CONTRACTS_INDEX.read_text(encoding="utf-8", errors="ignore") if CONTRACTS_INDEX.exists() else ""
    errors = []

    for rel, paths in new_paths.items():
        module = module_from_path(rel)
        readme = ROOT / module / "README.md" if module else None
        readme_txt = ""
        if readme and readme.exists():
            readme_txt = readme.read_text(encoding="utf-8", errors="ignore")

        for p in paths:
            in_readme = p in readme_txt if readme_txt else False
            in_contracts = p in contracts_txt
            in_spec = contains_in_spec(p)

            missing = []
            if not in_readme:
                missing.append(f"{module}/README.md" if module else "module README")
            if not in_contracts:
                missing.append(".github/references/CONTRACTS_INDEX.md")
            if not in_spec:
                missing.append(".specify/features/*")

            if missing:
                errors.append(
                    f"{rel}: endpoint '{p}' missing in: {', '.join(missing)}"
                )

    if errors:
        print("Doc drift check failed:")
        for e in errors:
            print(f"- {e}")
        return 1

    print("Doc drift check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

