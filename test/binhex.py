import sys
from binascii import hexlify

index = 0
size = int(sys.argv[2])

with open(sys.argv[1], 'rb') as f:
    while ((buf := f.read(4)) != b''):
        sys.stdout.write('ee' * (4 - len(buf)) +
                         hexlify(bytes(reversed(buf))).decode('utf-8'))
        sys.stdout.write('\n')
        index += 1
    assert index < size, index
    while index < size:
        sys.stdout.write('eeeeeeee\n')
        index += 1
