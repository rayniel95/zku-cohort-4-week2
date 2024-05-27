//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Groth16Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        index = 8;
        for (uint i = 0; i < 15; i++) {
            hashes.push(0);
        }
        for (uint i = 6; i >=0; i--) {
            hashes[i] = PoseidonT3.poseidon([hashes[i*2], hashes[i*2+1]]);
        }
        root = hashes[0];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        index++;
        uint numberOfNodes = index;
        uint offset;
        while (numberOfNodes > 0) {
            for (uint i = 0; i < numberOfNodes-1; i+=2) {
                hashes.push(PoseidonT3.poseidon([hashes[offset+i], hashes[offset+i+1]]));
            }
            if (numberOfNodes % 2 == 1) {
                hashes.push(PoseidonT3.poseidon([hashes[offset+numberOfNodes-1], hashes[offset+numberOfNodes-1]]));
            }
            offset += numberOfNodes;
            numberOfNodes = numberOfNodes/2;
        }
        root = hashes[hashes.length-1];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
    }
}
