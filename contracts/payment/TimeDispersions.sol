// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../states/Stages.sol";
import "../time/Time.sol";
import "../utils/Info.sol";
import "../Member.sol";
import "@openzeppelin/contracts/utils/escrow/Escrow.sol";

contract TimeDispersions is Stage, Time, Info, Members {
    Escrow private escrow;
    address private clock;

    constructor() {
        escrow = new Escrow();
    }

    receive() external payable {
        setTotal(msg.sender);
    }

    function typeContract() public pure returns (bytes memory) {
        return "time_contract";
    }

    function setTratoClock(address _clock) internal pure {
        _clock = _clock;
    }

    function dispersions() public atStage(Stages.RUNNING) payDay {
        require(msg.sender == clock, "Only trato delayed service");

        uint256[] memory percents = getTimePercents();
        uint8 currentPosition = getPosition();
        if (currentPosition == percents.length) {
            setStage(Stages.FINISH);
        } else if (currentPosition < percents.length) {
            setMembers(((percents[currentPosition] / 1e2) * getTotal()) / 100);
            addPosition();
            setNextPayment();
        }
    }

    function setMembers(uint256 _quantity) private {
        address[] memory members = getMembers();
        for (uint256 i = 0; i < members.length; i++) {
            (uint256 percent, ) = getMember(members[i]);
            pay(members[i], (_quantity * percent) / 100);
        }
    }

    function pay(address _to, uint256 _amount) private {
        escrow.deposit{value: _amount}(_to);
        escrow.withdraw(payable(_to));
    }

    function refund() public onlyOwner atStage(Stages.CREATION) {
        escrow.deposit{value: getTotal()}(getInvestor());
        escrow.withdraw(payable(getInvestor()));
    }

    function payTo(address _to)
        public
        payable
        onlyOwner
        atStage(Stages.CREATION)
    {
        escrow.deposit{value: msg.value}(_to);
        escrow.withdraw(payable(_to));
        setTotal(getInvestor());
    }

    function sign(address _member) public timeReady withFunds {
        signMember(_member);
        bool start = allSigned();
        if (start) {
            setStage(Stages.RUNNING);
            exec();
        }
    }
}
