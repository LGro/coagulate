// Implementation of https://github.com/meeb/phonobyte
import 'dart:convert';
import 'dart:typed_data';
import 'package:charcode/charcode.dart';

const _byteToPhono = [
  'jab',
  'tip',
  'led',
  'rut',
  'dak',
  'jig',
  'rud',
  'pub',
  'not',
  'kid',
  'bid',
  'gup',
  'lep',
  'juk',
  'jib',
  'sid',
  'fon',
  'dug',
  'lap',
  'sog',
  'bug',
  'ret',
  'net',
  'fip',
  'gad',
  'peg',
  'gap',
  'fet',
  'rog',
  'lob',
  'lin',
  'pip',
  'fud',
  'lag',
  'gut',
  'reb',
  'din',
  'sun',
  'jun',
  'dig',
  'rag',
  'neg',
  'bin',
  'ben',
  'gob',
  'run',
  'fab',
  'lit',
  'ked',
  'rug',
  'lod',
  'rib',
  'rip',
  'sod',
  'ped',
  'dip',
  'leg',
  'sib',
  'sad',
  'sat',
  'pak',
  'jet',
  'bun',
  'gon',
  'geg',
  'bit',
  'gud',
  'rig',
  'dek',
  'pot',
  'pug',
  'ken',
  'gub',
  'rid',
  'pen',
  'nep',
  'gib',
  'jot',
  'pup',
  'tid',
  'sin',
  'kin',
  'job',
  'ted',
  'fun',
  'fop',
  'dan',
  'nip',
  'but',
  'tun',
  'put',
  'jog',
  'jit',
  'lad',
  'pig',
  'got',
  'tot',
  'gak',
  'sot',
  'rin',
  'lid',
  'don',
  'den',
  'pod',
  'rit',
  'gat',
  'ket',
  'sab',
  'rat',
  'bub',
  'dod',
  'dep',
  'dup',
  'tod',
  'lat',
  'nub',
  'lab',
  'pan',
  'rap',
  'tib',
  'tan',
  'bed',
  'seg',
  'lib',
  'kop',
  'fog',
  'tig',
  'sob',
  'pet',
  'lop',
  'bet',
  'bog',
  'nog',
  'gun',
  'lud',
  'sit',
  'dib',
  'dap',
  'ban',
  'kob',
  'nan',
  'pat',
  'pib',
  'lip',
  'fan',
  'big',
  'get',
  'bob',
  'rad',
  'ran',
  'san',
  'rot',
  'bad',
  'nop',
  'nid',
  'jut',
  'nod',
  'bap',
  'fad',
  'ten',
  'gid',
  'dop',
  'dit',
  'fid',
  'tap',
  'bib',
  'dog',
  'lek',
  'tog',
  'deg',
  'fob',
  'deb',
  'beg',
  'kan',
  'sug',
  'tup',
  'ton',
  'gag',
  'dot',
  'lot',
  'keg',
  'pap',
  'ren',
  'fit',
  'kip',
  'tub',
  'tin',
  'pad',
  'bip',
  'pun',
  'tug',
  'nap',
  'sag',
  'dob',
  'gig',
  'sup',
  'tag',
  'fub',
  'reg',
  'top',
  'jag',
  'nib',
  'sig',
  'kit',
  'dag',
  'set',
  'dud',
  'bab',
  'sud',
  'sub',
  'dub',
  'nit',
  'fed',
  'nat',
  'tad',
  'dab',
  'fen',
  'nun',
  'lug',
  'kut',
  'rep',
  'fib',
  'nab',
  'nag',
  'bok',
  'gab',
  'bot',
  'bud',
  'dad',
  'sap',
  'tat',
  'did',
  'gog',
  'dat',
  'rub',
  'pud',
  'bop',
  'lig',
  'dut',
  'pep',
  'fug',
  'bod',
  'sed',
  'sen',
  'teg',
  'pit',
  'fin',
  'dun',
  'rob',
  'let',
  'neb',
  'tut',
  'sop',
  'gan',
  'fig',
  'tab'
];

Map<String, int> _phonoToByte = _buildPhonoToByte();

Map<String, int> _buildPhonoToByte() {
  Map<String, int> phonoToByte = {};
  for (int b = 0; b < 256; b++) {
    String ph = _byteToPhono[b];
    phonoToByte[ph] = b;
  }
  return phonoToByte;
}

String prettyPhonoString(String s,
    {int wordsPerLine = 5, int phonoPerWord = 2}) {
  assert(wordsPerLine >= 1);
  assert(phonoPerWord >= 1);
  final cs = canonicalPhonoString(s).toUpperCase();
  String out = "";
  int words = 0;
  int phonos = 0;
  for (int i = 0; i < cs.length; i += 3) {
    if (i != 0) {
      phonos += 1;
      if (phonos == phonoPerWord) {
        phonos = 0;
        words += 1;
        if (words == wordsPerLine) {
          words = 0;
          out += "\n";
        } else {
          out += " ";
        }
      }
    }
    out += cs.substring(i, i + 3);
  }
  return out;
}

String canonicalPhonoString(String s) {
  Uint8List bytes = Uint8List.fromList(utf8.encode(s.toLowerCase()));
  String cs = "";
  for (int i = 0; i < bytes.length; i++) {
    int ch = bytes[i];
    if (ch >= $a && ch <= $z) {
      cs += String.fromCharCode(ch);
    }
  }
  if (cs.length % 3 != 0) {
    throw const FormatException(
        "phonobyte string length should be a multiple of 3");
  }
  for (int i = 0; i < cs.length; i += 3) {
    String ph = cs.substring(i, i + 3);
    if (!_phonoToByte.containsKey(ph)) {
      throw const FormatException("phonobyte string contains invalid sequence");
    }
  }
  return cs;
}

Uint8List decodePhono(String s) {
  final cs = canonicalPhonoString(s);
  final out = Uint8List(cs.length ~/ 3);
  for (int i = 0; i < cs.length; i += 3) {
    String ph = cs.substring(i, i + 3);
    int b = _phonoToByte[ph]!;
    out[i] = b;
  }
  return out;
}

String encodePhono(Uint8List b) {
  String out = "";
  for (int i = 0; i < b.length; i++) {
    out += _byteToPhono[b[i]];
  }
  return out;
}
