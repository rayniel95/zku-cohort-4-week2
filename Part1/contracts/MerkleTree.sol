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
        for (uint i = 0; i < 8; i++) {
            hashes.push(0);
        }
        index = 8;
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
            uint[2] calldata a,
            uint[2][2] calldata b,
            uint[2] calldata c,
            uint[1] calldata input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        bool response = super.verifyProof(a, b, c, input);
        return response;
    }
}
