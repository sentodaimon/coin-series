#!/usr/bin/env python3
# Copyright (c) 2026 Sento Daimon. MIT License.
"""Coin Series claim helper: BIP-322 "full" proofs signed by an ordinary Bitcoin wallet.

A Coin Series claim needs the owner of a Bitcoin output (snapshot of block 840,000) to sign the
claim message. Many wallets cannot sign BIP-322 messages, but almost every wallet can sign a PSBT.
A BIP-322 full proof is just a signed virtual transaction, so this tool turns it into a PSBT:

  1. psbt   <message-file> <address>      -> prints a PSBT (base64) to sign in your Bitcoin wallet
  2. proof  <signed-psbt-or-final-tx>      -> prints the proof ("ful..." string) for addclaimproof

The PSBT can never move bitcoin: it spends a virtual output worth 0 that exists only inside this
proof, and its only output is OP_RETURN with value 0. Your private key never leaves your wallet.
No network access, no dependencies (Python 3.8+).
"""
import base64, hashlib, os, struct, sys

# ---------- encoding helpers ----------
def sha256(b): return hashlib.sha256(b).digest()
def dsha(b): return sha256(sha256(b))
def tagged(tag, msg):
    t = sha256(tag.encode())
    return sha256(t + t + msg)
def cs(n):  # compact size
    if n < 0xfd: return bytes([n])
    if n <= 0xffff: return b'\xfd' + struct.pack('<H', n)
    if n <= 0xffffffff: return b'\xfe' + struct.pack('<I', n)
    return b'\xff' + struct.pack('<Q', n)
def push(data):
    n = len(data)
    if n < 0x4c: return bytes([n]) + data
    if n <= 0xff: return b'\x4c' + bytes([n]) + data
    return b'\x4d' + struct.pack('<H', n) + data

class Reader:
    def __init__(self, b): self.b, self.i = b, 0
    def read(self, n):
        if self.i + n > len(self.b): raise ValueError('truncated data')
        r = self.b[self.i:self.i + n]; self.i += n; return r
    def cs(self):
        f = self.read(1)[0]
        if f < 0xfd: return f
        return struct.unpack('<' + {0xfd: 'H', 0xfe: 'I', 0xff: 'Q'}[f], self.read({0xfd: 2, 0xfe: 4, 0xff: 8}[f]))[0]
    def bytes_(self): return self.read(self.cs())
    def done(self): return self.i == len(self.b)

# ---------- addresses -> scriptPubKey ----------
B58 = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
def b58check_decode(s):
    n = 0
    for c in s: n = n * 58 + B58.index(c)
    raw = n.to_bytes((n.bit_length() + 7) // 8, 'big')
    raw = b'\x00' * (len(s) - len(s.lstrip('1'))) + raw
    data, chk = raw[:-4], raw[-4:]
    if dsha(data)[:4] != chk: raise ValueError('bad address checksum')
    return data

BECH = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l'
def _polymod(v):
    g = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3]; c = 1
    for x in v:
        b = c >> 25; c = (c & 0x1ffffff) << 5 ^ x
        for i in range(5): c ^= g[i] if (b >> i) & 1 else 0
    return c
def bech32_decode(addr):
    addr = addr.lower(); pos = addr.rfind('1'); hrp, data = addr[:pos], [BECH.index(c) for c in addr[pos + 1:]]
    const = _polymod([ord(c) >> 5 for c in hrp] + [0] + [ord(c) & 31 for c in hrp] + data)
    ver = data[0]
    if (ver == 0 and const != 1) or (ver > 0 and const != 0x2bc830a3): raise ValueError('bad bech32 checksum')
    acc = bits = 0; out = []
    for v in data[1:-6]:
        acc = (acc << 5) | v; bits += 5
        while bits >= 8: bits -= 8; out.append((acc >> bits) & 0xff)
    return hrp, ver, bytes(out)

def script_for(address):
    a = address.strip()
    if a.lower().startswith(('bc1', 'tb1', 'bcrt1')):
        hrp, ver, prog = bech32_decode(a)
        return bytes([0x51 + ver - 1 if ver else 0x00]) + push(prog)
    d = b58check_decode(a)
    if d[0] in (0x00, 0x6f): return b'\x76\xa9\x14' + d[1:] + b'\x88\xac'      # P2PKH
    if d[0] in (0x05, 0xc4): return b'\xa9\x14' + d[1:] + b'\x87'              # P2SH
    raise ValueError('unsupported address')

# ---------- BIP-322 virtual transactions ----------
def ser_tx(version, vin, vout, locktime, witness=None):
    out = struct.pack('<i', version)
    if witness: out += b'\x00\x01'
    out += cs(len(vin))
    for prev_txid, prev_n, script_sig, seq in vin:
        out += prev_txid + struct.pack('<I', prev_n) + cs(len(script_sig)) + script_sig + struct.pack('<I', seq)
    out += cs(len(vout))
    for value, spk in vout: out += struct.pack('<q', value) + cs(len(spk)) + spk
    if witness:
        for stack in witness: out += cs(len(stack)) + b''.join(cs(len(x)) + x for x in stack)
    return out + struct.pack('<I', locktime)

def message_hash(msg): return tagged('BIP0322-signed-message', msg)
def to_spend(msg, spk):
    return ser_tx(0, [(b'\x00' * 32, 0xffffffff, b'\x00' + push(message_hash(msg)), 0)], [(0, spk)], 0)
def to_sign_unsigned(to_spend_raw):
    return ser_tx(0, [(dsha(to_spend_raw), 0, b'', 0)], [(0, b'\x6a')], 0)
def txid_hex(raw): return dsha(raw)[::-1].hex()

def parse_tx(raw):
    r = Reader(raw); version = struct.unpack('<i', r.read(4))[0]; segwit = False
    if raw[4:6] == b'\x00\x01': r.read(2); segwit = True
    vin = []
    for _ in range(r.cs()):
        txid = r.read(32); n = struct.unpack('<I', r.read(4))[0]; ss = r.bytes_(); seq = struct.unpack('<I', r.read(4))[0]
        vin.append((txid, n, ss, seq))
    vout = []
    for _ in range(r.cs()):
        v = struct.unpack('<q', r.read(8))[0]; vout.append((v, r.bytes_()))
    wit = None
    if segwit: wit = [[r.bytes_() for _ in range(r.cs())] for _ in vin]
    lock = struct.unpack('<I', r.read(4))[0]
    if not r.done(): raise ValueError('trailing data in transaction')
    return version, vin, vout, lock, wit

# ---------- PSBT (BIP-174, version 0) ----------
def kv(key, val): return cs(len(key)) + key + cs(len(val)) + val
def make_psbt(msg, spk):
    ts = to_spend(msg, spk); unsigned = to_sign_unsigned(ts)
    out = b'psbt\xff' + kv(b'\x00', unsigned) + b'\x00'
    inp = kv(b'\x00', ts)                                        # non-witness UTXO (needed for legacy / P2SH)
    if spk[0] in (0x00, 0x51): inp += kv(b'\x01', struct.pack('<q', 0) + cs(len(spk)) + spk)  # witness UTXO
    out += inp + b'\x00'
    out += b'\x00'                                               # output map (empty)
    return base64.b64encode(out).decode()

def parse_psbt(b):
    r = Reader(b)
    if r.read(5) != b'psbt\xff': raise ValueError('not a PSBT')
    def read_map():
        m = {}
        while True:
            kl = r.cs()
            if kl == 0: return m
            k = r.read(kl); m[k] = r.bytes_()
    g = read_map(); unsigned = g[b'\x00']
    _, vin, vout, _, _ = parse_tx(unsigned)
    ins = [read_map() for _ in vin]
    return unsigned, ins

def proof_from(signed):
    s = signed.strip()
    try:
        raw = base64.b64decode(s, validate=True)
    except Exception:
        raw = bytes.fromhex(s)
    if raw[:5] == b'psbt\xff':
        unsigned, ins = parse_psbt(raw)
        version, vin, vout, lock, _ = parse_tx(unsigned)
        m = ins[0]
        script_sig = m.get(b'\x07', b'')                          # final scriptSig
        wit = []
        if b'\x08' in m:                                          # final script witness
            rr = Reader(m[b'\x08']); wit = [rr.bytes_() for _ in range(rr.cs())]
        if not script_sig and not wit:
            raise ValueError('the PSBT is signed but not finalized: finalize it in your wallet (or use the final transaction)')
        vin = [(vin[0][0], vin[0][1], script_sig, vin[0][3])]
        final = ser_tx(version, vin, vout, lock, [wit] if wit else None)
    else:
        final = raw
    version, vin, vout, lock, wit = parse_tx(final)
    if version != 0 or lock != 0 or len(vin) != 1 or len(vout) != 1 or vout[0] != (0, b'\x6a'):
        raise ValueError('this is not a BIP-322 proof transaction')
    return 'ful' + base64.b64encode(final).decode()

def selftest():
    # BIP-322 test vectors (message hashes and virtual transaction ids).
    assert message_hash(b'').hex() == 'c90c269c4f8fcbe6880f72a721ddfbf1914268a794cbb21cfafee13770ae19f1'
    assert message_hash(b'Hello World').hex() == 'f0eb03b1a75ac6d9847f55c624a99169b5dccba2a31f5b23bea77ba270de0a7a'
    spk = script_for('bc1q9vza2e8x573nczrlzms0wvx3gsqjx7vavgkx0l')
    for m, a, b in [(b'', 'c5680aa69bb8d860bf82d4e9cd3504b55dde018de765a91bb566283c545a99a7', '1e9654e951a5ba44c8604c4de6c67fd78a27e81dcadcfe1edf638ba3aaebaed6'),
                    (b'Hello World', 'b79d196740ad5217771c1098fc4a4b51e0535c32236c71f1ea4d61a2d603352b', '88737ae86f2077145f93cc4b153ae9a1cb8d56afa511988c149c5c8c9d93bddf')]:
        ts = to_spend(m, spk)
        assert txid_hex(ts) == a, txid_hex(ts)
        assert txid_hex(to_sign_unsigned(ts)) == b, txid_hex(to_sign_unsigned(ts))
    print('selftest ok: BIP-322 test vectors match')

def main(a):
    if len(a) == 1 and a[0] == 'selftest': return selftest()
    if len(a) == 3 and a[0] == 'psbt':
        msg = open(a[1], 'rb').read()
        if msg.endswith(b'\r\n'): msg = msg[:-2]
        elif msg.endswith(b'\n'): msg = msg[:-1]
        print(make_psbt(msg.replace(b'\r\n', b'\n'), script_for(a[2]))); return
    if len(a) == 2 and a[0] == 'proof':
        data = open(a[1]).read() if os.path.isfile(a[1]) else a[1]
        print(proof_from(data)); return
    print(__doc__); sys.exit(1)

if __name__ == '__main__':
    main(sys.argv[1:])
