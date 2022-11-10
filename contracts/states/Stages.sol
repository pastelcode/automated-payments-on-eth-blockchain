// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Stage is Ownable {
    enum Stages {
        CREATION,
        SIGN,
        RUNNING,
        FINISH
    }

    Stages public stage = Stages.CREATION;

    modifier atStage(Stages _stage) {
        require(stage == _stage, "Function cannot be called at this time.");
        _;
    }

    function setStage(Stages _stage) internal {
        stage = _stage;
    }

    function destruct() internal {
        selfdestruct(payable(owner()));
    }
}
