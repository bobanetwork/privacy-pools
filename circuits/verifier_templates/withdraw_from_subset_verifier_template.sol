// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ProofLib.sol";

contract WithdrawFromSubsetVerifier {
    using ProofLib for ProofLib.G1Point;
    using ProofLib for ProofLib.G2Point;

    // Verification Key data

    function withdrawFromSubsetVerifyingKey() internal pure returns (ProofLib.VerifyingKey memory vk) {
        ProofLib.G1Point[] memory IC;
        IC[0] = ProofLib.G1Point(IC0x, IC0y);
        IC[1] = ProofLib.G1Point(IC1x, IC1y);
        IC[2] = ProofLib.G1Point(IC2x, IC2y);
        IC[3] = ProofLib.G1Point(IC3x, IC3y);
        IC[4] = ProofLib.G1Point(IC4x, IC4y);
        IC[5] = ProofLib.G1Point(IC5x, IC5y);

        vk = ProofLib.VerifyingKey(
            ProofLib.G1Point(alphax, alphay),
            ProofLib.G2Point([betax1, betax2], [betay1, betay2]),
            ProofLib.G2Point([gammax1, gammax2], [gammay1, gammay2]),
            ProofLib.G2Point([deltax1, deltax2], [deltay1, deltay2]),
            IC
        );
    }

    function _verifyWithdrawFromSubsetProof(
        uint[8] calldata flatProof,
        uint root,
        uint subsetRoot,
        uint nullifier,
        uint assetMetadata,
        uint withdrawMetadata
    ) internal view returns (bool) {
        if (root >= ProofLib.snark_scalar_field
        || subsetRoot >= ProofLib.snark_scalar_field
        || nullifier >= ProofLib.snark_scalar_field
        || assetMetadata >= ProofLib.snark_scalar_field
            || withdrawMetadata >= ProofLib.snark_scalar_field
        ) revert ProofLib.GteSnarkScalarField();

        ProofLib.Proof memory proof;
        proof.A = ProofLib.G1Point(flatProof[0], flatProof[1]);
        proof.B = ProofLib.G2Point([flatProof[2], flatProof[3]], [flatProof[4], flatProof[5]]);
        proof.C = ProofLib.G1Point(flatProof[6], flatProof[7]);

        ProofLib.VerifyingKey memory vk = withdrawFromSubsetVerifyingKey();
        ProofLib.G1Point memory vk_x = ProofLib.G1Point(0, 0);
        vk_x = vk_x.addition(vk.IC[1].scalar_mul(root));
        vk_x = vk_x.addition(vk.IC[2].scalar_mul(subsetRoot));
        vk_x = vk_x.addition(vk.IC[3].scalar_mul(nullifier));
        vk_x = vk_x.addition(vk.IC[4].scalar_mul(assetMetadata));
        vk_x = vk_x.addition(vk.IC[5].scalar_mul(withdrawMetadata));
        vk_x = vk_x.addition(vk.IC[0]);
        return proof.A.negate().pairingProd4(
            proof.B,
            vk.alfa1,
            vk.beta2,
            vk_x,
            vk.gamma2,
            proof.C,
            vk.delta2
        );
    }
}