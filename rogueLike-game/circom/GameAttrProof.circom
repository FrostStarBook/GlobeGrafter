pragma circom 2.1.6;

template GameAttrProof() {

  signal input level;
  signal input exp;

  signal output result;

  result <== exp * level;
}

component main = GameAttrProof();