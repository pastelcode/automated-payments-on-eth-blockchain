// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./states/Stages.sol";

contract Members is Ownable, Stage {
    using SafeMath for uint256;

    address[] private members_;

    mapping(address => Member) private relations_;

    struct Member {
        uint256 percent_;
        bool signed_;
        bool exists_;
    }

    event AddressSigned(address signed);

    function registerMember(address _member, uint256 _percent)
        public
        onlyOwner
        atStage(Stages.CREATION)
    {
        require(!relations_[_member].exists_, "Member already exists.");

        members_.push(_member);
        relations_[_member].percent_ = _percent;
        relations_[_member].signed_ = false;
        relations_[_member].exists_ = true;
    }

    function signMember(address _member) internal {
        setStage(Stages.SIGN);

        require(relations_[_member].exists_, "Member does not exist");
        require(!relations_[_member].signed_, "Member already signed");

        relations_[_member].signed_ = true;
        emit AddressSigned(_member);
    }

    function getMember(address _member) public view returns (uint256, bool) {
        Member memory member = relations_[_member];
        return (member.percent_, member.exists_);
    }

    function getMembers() public view returns (address[] memory) {
        return members_;
    }

    function allSigned() internal view returns (bool) {
        bool start = false;
        for (uint256 i = 0; i < members_.length; i++) {
            start = relations_[members_[i]].signed_;
        }
        return start;
    }
}
