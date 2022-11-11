// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../states/Stages.sol";

contract Time is Ownable, Stage {
    uint256 constant ORIGIN_YEAR = 1970;

    uint256 constant HOUR_IN_SECONDS = 3600;
    uint256 constant MINUTE_IN_SECONDS = 60;
    uint256 constant DAY_IN_SECONDS = 86_400;
    uint256 constant YEAR_IN_SECONDS = 31_536_000;
    uint256 constant LEAP_YEAR_IN_SECONDS = 31_622_400;

    struct Date {
        bool running_;
        bytes32 unitEnd_;
        bytes32 unitDispersion_;
        uint256[] percents_;
        uint8 duration_;
        uint8 every_;
        _DateTime start_;
        _DateTime end_;
        _DateTime nextPayment_;
    }

    struct _DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
    }

    Date private currentDate;

    function exec() internal atStage(Stages.RUNNING) {
        require(currentDate.duration_ != 0, "End time not set");
        require(currentDate.every_ != 0, "Set lapseds first");
        _DateTime memory time = parseTimestamp(block.timestamp);
        currentDate.start_ = time;
        currentDate.nextPayment_ = parseTime(
            time,
            currentDate.every_,
            currentDate.unitDispersion_
        );
        currentDate.end_ = parseTime(
            time,
            currentDate.duration_,
            currentDate.unitEnd_
        );
        currentDate.running_ = true;
    }

    function setEnd(uint8 _duration, bytes32 _unit)
        public
        onlyOwner
        atStage(Stages.CREATION)
    {
        require(
            _unit == "day" || _unit == "month" || _unit == "year",
            "Invalid time unit"
        );
        currentDate.duration_ = _duration;
        currentDate.unitEnd_ = _unit;
    }

    function setLapseds(
        uint256[] memory _percents,
        uint8 _every,
        bytes32 _unit
    ) public onlyOwner atStage(Stages.CREATION) {
        uint256 total = 0;
        for (uint256 i; i < _percents.length; i++) {
            total += _percents[i];
        }
        require(total >= 99, "Invalid percents");
        currentDate.unitDispersion_ = _unit;
        currentDate.percents_ = _percents;
        currentDate.every_ = _every;
    }

    function getStart()
        public
        view
        atStage(Stages.RUNNING)
        returns (
            uint16,
            uint8,
            uint8
        )
    {
        return (
            currentDate.start_.year,
            currentDate.start_.month,
            currentDate.start_.day
        );
    }

    function getEnd()
        public
        view
        atStage(Stages.RUNNING)
        returns (
            uint16,
            uint8,
            uint8
        )
    {
        return (
            currentDate.end_.year,
            currentDate.end_.month,
            currentDate.end_.day
        );
    }

    function getNextPayment()
        public
        view
        atStage(Stages.RUNNING)
        returns (
            uint16,
            uint8,
            uint8
        )
    {
        return (
            currentDate.nextPayment_.year,
            currentDate.nextPayment_.month,
            currentDate.nextPayment_.day
        );
    }

    function setNextPayment() internal {
        require(currentDate.every_ != 0, "Set lapseds first");
        currentDate.nextPayment_ = parseTime(
            currentDate.nextPayment_,
            currentDate.every_,
            currentDate.unitDispersion_
        );
    }

    function getTimePercents() internal view returns (uint256[] memory) {
        return currentDate.percents_;
    }

    function parseTimestamp(uint256 timestamp)
        internal
        pure
        returns (_DateTime memory dateTime)
    {
        uint256 secondsAccountedFor = 0;
        uint256 buf;
        uint8 index;

        // |- Year
        dateTime.year = getYear(timestamp);
        buf = leapYearsBefore(dateTime.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor +=
            YEAR_IN_SECONDS *
            (dateTime.year - ORIGIN_YEAR - buf);
        // Year -|

        // |- Month
        uint256 secondsInMonth;
        for (index = 1; index <= 12; index++) {
            secondsInMonth =
                DAY_IN_SECONDS *
                getDaysInMonth(index, dateTime.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dateTime.month = index;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }
        // Month -|

        // |- Day
        for (
            index = 1;
            index <= getDaysInMonth(dateTime.month, dateTime.year);
            index++
        ) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dateTime.day = index;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }
        // Day -|
    }

    function getYear(uint256 timestamp) private pure returns (uint16 year) {
        uint256 secondsAccountedFor = 0;
        uint256 numLeapYears;

        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor +=
            YEAR_IN_SECONDS *
            (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            } else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
    }

    function getMonth(uint256 timestamp) private pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint256 timestamp) private pure returns (uint8) {
        return parseTimestamp(timestamp).day;
    }

    function getHour(uint256 timestamp) private pure returns (uint8) {
        return uint8((timestamp / 60 / 60) % 24);
    }

    function isLeapYear(uint16 year) private pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint256 year) private pure returns (uint256) {
        uint256 temp = year -= 1;
        return temp / 4 - temp / 100 + temp / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year)
        private
        pure
        returns (uint8)
    {
        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            return 31;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else if (isLeapYear(year)) {
            return 29;
        } else {
            return 28;
        }
    }

    function parseTime(
        _DateTime memory time,
        uint8 duration,
        bytes32 unit
    ) private pure returns (_DateTime memory dateTime) {
        dateTime = time;
        if (unit == "day") {
            uint8 daysMonth_ = getDaysInMonth(time.month, time.year);
            uint8 totalDays = time.day + duration;
            if (totalDays > daysMonth_) {
                dateTime.month = time.month + 1;
                dateTime.day = totalDays - daysMonth_;
            } else {
                dateTime.day = time.day + duration;
            }
        }
        if (unit == "month") {
            uint8 totalMonth = time.month + duration;
            if (totalMonth > 12) {
                dateTime.year = time.year + 1;
                dateTime.month = totalMonth - 12;
            } else {
                dateTime.month = time.month + duration;
            }
        }
        if (unit == "year") {
            dateTime.year = time.year + duration;
        }
    }

    modifier timeReady() {
        require(currentDate.duration_ != 0, "Time not set");
        require(currentDate.every_ != 0, "Time not set");
        _;
    }

    modifier payDay() {
        _DateTime memory time = parseTimestamp(block.timestamp);
        require(
            time.day == currentDate.nextPayment_.day,
            "Invalid day of payment"
        );
        require(
            time.month == currentDate.nextPayment_.month,
            "Invalid month of payment"
        );
        require(
            time.year == currentDate.nextPayment_.year,
            "Invalid year of payment"
        );
        _;
    }
}
