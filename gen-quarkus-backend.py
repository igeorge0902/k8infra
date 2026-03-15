#!/usr/bin/env python3
"""Generate quarkus-backend.yaml from kubernetes.yaml by adding namespace: cinemas to every resource."""
import os

here = os.path.dirname(os.path.abspath(__file__))
src = os.path.join(here, 'kubernetes.yaml')
dst = os.path.join(here, 'quarkus-backend.yaml')

with open(src) as f:
    lines = f.readlines()

ns_header = [
    'apiVersion: v1\n',
    'kind: Namespace\n',
    'metadata:\n',
    '  name: cinemas\n',
    '---\n',
]

out = list(ns_header)
i = 0
while i < len(lines):
    out.append(lines[i])
    if lines[i].strip() == 'metadata:':
        j = i + 1
        while j < len(lines) and lines[j].strip() == '':
            out.append(lines[j])
            j += 1
        if j < len(lines) and lines[j].strip().startswith('name:'):
            out.append(lines[j])
            k = j + 1
            while k < len(lines) and lines[k].strip() == '':
                k += 1
            if k < len(lines) and lines[k].strip().startswith('namespace:'):
                pass
            else:
                indent = len(lines[j]) - len(lines[j].lstrip())
                out.append(' ' * indent + 'namespace: cinemas\n')
            i = j + 1
            continue
    i += 1

with open(dst, 'w') as f:
    f.writelines(out)

print(f'OK: wrote {len(out)} lines to {dst}')

