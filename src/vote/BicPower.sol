// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../token/BeinGiveTake.sol";
import "@openzeppelin/contracts/governance/utils/Votes.sol";

contract BicPower is Votes {
    address public bgtAddress;
    string private _name;
    string private _symbol;
    mapping(address => uint256) public currentDelegateAmount;
    constructor(address _bgtAddress) EIP712("BIC Powers", "1") {
        bgtAddress = _bgtAddress;
        _name = "BIC Powers";
        _symbol = "BIC POWERS";
    }

    function _getVotingUnits(address owner) internal view virtual override returns (uint256) {
        return BeinGiveTake(bgtAddress).balanceOf(owner);
    }

    function CLOCK_MODE() public view virtual override returns (string memory) {
        return Votes.CLOCK_MODE();
    }

    function clock() public view virtual override returns (uint48) {
        return Votes.clock();
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return BeinGiveTake(bgtAddress).totalSupply();
    }

    function balanceOf(address account) public view returns (uint256) {
        return _getVotingUnits(account);
    }

    function _delegate(address owner, address delegatee) internal virtual override {
        require(owner != delegatee, "BicPower: self-delegation");
        uint256 oldDelegateAmount = currentDelegateAmount[owner];
        uint256 newDelegateAmount = _getVotingUnits(owner);
        address oldDelegate = delegates(owner);

        // update in case BGT be minted
        if(newDelegateAmount > oldDelegateAmount) {
            super._transferVotingUnits(address(0), oldDelegate, newDelegateAmount - oldDelegateAmount);
        }
        super._delegate(owner, delegatee);
    }

    function getVotes(address account) public view virtual override returns (uint256) {
        return super.getVotes(account) + _getVotingUnits(account);
    }

    function getPastVotes(address /* account */, uint256 /* timepoint */) public view virtual override returns (uint256) {
        return 0;  // Disable this function
    }
}