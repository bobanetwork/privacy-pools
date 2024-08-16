#!/usr/bin/env python3
import sys

def find_verifying_key(lines: list, end: int):
    start = None
    stop = None

    for l, line in enumerate(lines):
        if '// Verification Key data' in line:
            start = l + 1
        elif f'uint256 constant IC{end}y' in line:
            stop = l + 1

    if start is None or stop is None:
        raise ValueError("Could not find the verifying key block in the verifier file.")

    return ''.join(lines[start:stop])

if __name__ == '__main__':
    target, num_public_inputs = sys.argv[1], sys.argv[2]
    with open(f'./circuits/out/{target}_verifier.sol', 'r') as f:
        verifier = f.readlines()

    vkey = find_verifying_key(verifier, int(num_public_inputs))

    with open(f'./circuits/verifier_templates/{target}_verifier_template.sol', 'r') as f:
        template = f.read()

    with open(f'./contracts/verifiers/{target}_verifier.sol', 'w+') as f:
        solidity = template.replace('    // Verification Key data', vkey)
        f.write(solidity)