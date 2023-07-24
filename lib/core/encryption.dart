class Encryption {
  static String encode(String plainText) {
    String P = plainText;
    List p = [], c1 = [], c2 = [], pp = [];
    int halflen;
    if (P.length % 2 == 0) {
      p = P.split('');
    } else {
      pp = P.split('');
      for (int i = 0; i < P.length; i++) {
        p.insert(i, pp[i]);
      }
      p.add(' ');
    }

    halflen = p.length ~/ 2;

    for (int i = 0; i < halflen; i++) {
      c1.insert(i, p[(i * 2) + 1]);
      c2.insert(i, p[i * 2]);
    }
    c1.addAll(c2);

    return c1.join('');
  }

  static String decode(cipherText) {
    String C = cipherText;
    String P;
    int len = C.length;
    int halflen = len ~/ 2;
    List c = [], p = [], p1 = [], p2 = [];

    if (C.length % 2 == 0) {
      len = C.length;
      c = C.split('');
    } else {
      // len = C.length + 1;
      // cc = C.split('');
      // for (int i = 0; i < C.length; i++) {
      //   c.insert(i, cc[i]);
      // }
      // c.insert(0, ' ');
      return "The result may be incorrect because input letters count is not even number";
    }

    halflen = len ~/ 2;

    for (int i = 0; i < halflen; i++) {
      p1.insert(i, c[halflen + i]);
      p2.insert(i, c[i]);
    }

    int i1 = 0;
    int i2 = 0;
    for (int i = 0; i < len; i++) {
      if (i % 2 == 0) {
        p.insert(i, p1[i1]);
        i1++;
      } else {
        p.insert(i, p2[i2]);
        i2++;
      }
    }
    if (p.elementAt(p.length - 1) == 'x') p.removeAt(p.length - 1);
    P = p.join('');
    return P;
  }
}

// 777