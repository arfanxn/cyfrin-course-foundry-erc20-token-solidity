// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.18;

contract ManualToken {
    mapping(address => uint256) private s_balances;

    constructor() {
        //
    }

    function name() public pure returns (string memory) {
        return "Manual Token";
    }

    function symbol() public pure returns (string memory) {
        return "MT";
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public pure returns (uint256) {
        return 100 ether; // 1 000 000 000 000 000 000
    }

    function balanceOf(address _account) public view returns (uint256) {
        return s_balances[_account];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        address _from = msg.sender;

        if (balanceOf(_from) < _value) return false;

        s_balances[_from] -= _value;
        s_balances[_to] += _value;
        return true;
    }
}
