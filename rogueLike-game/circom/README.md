
## Generating zero-knowledge proofs using zkSNARK

Each dependent environment version：
```shell
cargo 1.71.0
node v18.12.1
snarkjs@0.7.0
circom compiler 2.1.6
```


install snarkjs

```shell
npm install -g snarkjs@latest
```

install circom(need node.js & rust)
```shell
git clone https://github.com/iden3/circom.git

cargo build --release

cargo install --path circom

circom --help
```

Start a new powers of tau ceremony
```shell
snarkjs powersoftau new bn128 14 pot14_0000.ptau -v
```

Contribute to the ceremony
```shell
snarkjs powersoftau contribute pot14_0000.ptau pot14_0001.ptau --name="First contribution" -v
```
```shell
snarkjs powersoftau contribute pot14_0001.ptau pot14_0002.ptau --name="Second contribution" -v -e="some random text"
```

Provide a third contribution using third party software
```shell
snarkjs powersoftau export challenge pot14_0002.ptau challenge_0003
snarkjs powersoftau challenge contribute bn128 challenge_0003 response_0003 -e="some random text"
snarkjs powersoftau import response pot14_0002.ptau response_0003 pot14_0003.ptau -n="Third contribution name"
```

Verify the protocol so far
```shell
snarkjs powersoftau verify pot14_0003.ptau
```

Apply a random beacon
```shell
snarkjs powersoftau beacon pot14_0003.ptau pot14_beacon.ptau 0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="Final Beacon"
```

Prepare phase 2
```shell
snarkjs powersoftau prepare phase2 pot14_beacon.ptau pot14_final.ptau -v
```

Verify the final ptau
```shell
snarkjs powersoftau verify pot14_final.ptau
```

Compile the circuit
```shell
circom GameAttrProof.circom --r1cs --wasm --sym
```

View information about the circuit
```shell
snarkjs r1cs info GameAttrProof.r1cs
```

Print the constraints
```shell
snarkjs r1cs print GameAttrProof.r1cs GameAttrProof.sym
```
Export r1cs to json
```shell
snarkjs r1cs export json GameAttrProof.r1cs GameAttrProof.r1cs.json
cat GameAttrProof.r1cs.json
```
Calculate the witness
```shell
cd GameAttrProof_js
node generate_witness.js GameAttrProof.wasm ../input.json ../witness.wtns
```
WITNESS CHECKING
```shell
cd ..
snarkjs wtns check GameAttrProof.r1cs witness.wtns
```

Setup
```shell
snarkjs groth16 setup GameAttrProof.r1cs pot14_final.ptau GameAttrProof_final.zkey
```

Verify the final zkey
```shell
snarkjs zkey verify GameAttrProof.r1cs pot14_final.ptau GameAttrProof_final.zkey
```

Export the verification key
```shell
snarkjs zkey export verificationkey GameAttrProof_final.zkey verification_key.json
```

Create the proof
```shell
snarkjs groth16 prove GameAttrProof_final.zkey witness.wtns proof.json public.json
```

Verify the proof
```shell
snarkjs groth16 verify verification_key.json public.json proof.json
```

Turn the verifier into a smart contract
```shell
snarkjs zkey export solidityverifier GameAttrProof_final.zkey GameAttrProof.sol
```

Simulate a verification call
```shell
snarkjs zkey export soliditycalldata public.json proof.json
```

![verification](https://github.com/liushuheng163/GlobeGrafter/blob/main/rogueLike-game/circom/verification.jpg?raw=true)