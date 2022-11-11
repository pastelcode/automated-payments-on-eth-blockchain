// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Info {
    struct PayInfo {
        uint256 total_;
        address investor_;
        uint8 position_;
    }

    PayInfo private info;

    function setTotal(address _investor) internal {
        info.total_ = address(this).balance;
        info.investor_ = _investor;
    }

    function getInvestor() public view returns (address) {
        return info.investor_;
    }

    function addPosition() internal {
        info.position_ += 1;
    }

    function getPosition() internal view returns (uint8) {
        return info.position_;
    }

    function getTotal() internal view returns (uint256) {
        return info.total_;
    }

    modifier withFunds() {
        require(info.total_ > 0, "Contract balance is 0");
        _;
    }
}
