pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    //NOTE - declare constants
    var numberOfLeaves = 2**n;
    var numberOfNodes = 2**(n+1)-1;
    var numberOfNodesWithoutLeaves = 2**(n+1)-1-2**n;

    signal hashes[numberOfNodes];
    for (var i = 0; i< numberOfLeaves; i++) {
        hashes[numberOfNodes-1-i] <== leaves[numberOfLeaves-1-i];
    }
    component hash[numberOfNodesWithoutLeaves];
    for (var i = numberOfNodesWithoutLeaves-1; i >= 0; i--) {
        hash[i] = Poseidon(2);
        hash[i].inputs[0] <== hashes[2*i];
        hash[i].inputs[1] <== hashes[2*i+1];
        hashes[i] <== hash[i].out;
    }
    root <== hashes[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path    
    signal hashes[n];
    component poseidon_r = Poseidon(2);
    poseidon_r.inputs[0] <== leaf;
    poseidon_r.inputs[1] <== path_elements[0];

    component poseidon_l = Poseidon(2);
    poseidon_l.inputs[0] <== path_elements[0];
    poseidon_l.inputs[1] <== leaf;

    signal intermediate[n];
    intermediate[0] <== poseidon_r.out*path_index[0];
    hashes[0] <== poseidon_l.out * (1-path_index[0]) + intermediate[0];

    component hash[2*n];
    for (var i = 1; i < n; i++) {
        hash[i] = Poseidon(2);
        hash[i].inputs[0] <== path_elements[i];
        hash[i].inputs[1] <== hashes[i-1];
        hash[n+i] = Poseidon(2);
        hash[n+i].inputs[0] <== hashes[i-1];
        hash[n+i].inputs[1] <== path_elements[i];
        intermediate[i] <== hash[n+i].out*path_index[i];
        hashes[i] <== hash[i].out * (1-path_index[i]) + intermediate[i];
    }
    root <== hashes[n-1];
}