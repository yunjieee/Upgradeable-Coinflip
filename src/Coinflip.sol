// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
error SeedTooShort();

contract Coinflip is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    string public seed;


    constructor() {
        _disableInitializers();
    }
    
    function initialize(address initialOwner) initializer public {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        seed = "It is a good practice to rotate seeds often in gambling";
    }

    function userInput(uint8[10] calldata guesses) external view returns(bool) {
        uint8[10] memory generatedFlips = getFlips();
        for (uint i = 0; i < 10; i++) {
            if (guesses[i] != generatedFlips[i]) {
                return false;
            }
        }
        return true;
    }

    function seedRotation(string memory newSeed) public onlyOwner {
        bytes memory seedBytes = bytes(newSeed);
        require(seedBytes.length >= 10, "SeedTooShort");
        seed = newSeed;
    }

    function getFlips() public view returns(uint8[10] memory) {
        bytes memory seedBytes = bytes(seed);
        uint8[10] memory results;
        for (uint i = 0; i < 10; i++) {
            uint randomNum = uint(keccak256(abi.encodePacked(seedBytes[i % seedBytes.length], block.timestamp)));
            results[i] = (randomNum % 2 == 0) ? 1 : 0;
        }
        return results;
    }

   
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
