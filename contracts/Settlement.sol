// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Settlement
 * @dev Handles stablecoin (USDC/USDT) escrow and settlement for SME trade.
 */
contract Settlement is Ownable {
    
    IERC20 public stablecoin;

    struct Escrow {
        uint256 amount;
        bool isCompleted;
        bool isPaidOut;
    }

    mapping(string => Escrow) public escrows;

    event SettlementExecuted(string invoiceRef, uint256 amount);

    constructor(address _stablecoinAddress) Ownable(msg.sender) {
        stablecoin = IERC20(_stablecoinAddress);
    }

    // Agent triggers this to lock funds in escrow
    function lockFunds(string memory _invoiceRef, uint256 _amount) public {
        require(stablecoin.transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        escrows[_invoiceRef] = Escrow(_amount, false, false);
    }

    // AI Agent triggers this once delivery/service is verified
    function releaseFunds(string memory _invoiceRef, address _merchant) public onlyOwner {
        Escrow storage escrow = escrows[_invoiceRef];
        require(!escrow.isPaidOut, "Already settled");
        
        escrow.isPaidOut = true;
        stablecoin.transfer(_merchant, escrow.amount);
        
        emit SettlementExecuted(_invoiceRef, escrow.amount);
    }
}
