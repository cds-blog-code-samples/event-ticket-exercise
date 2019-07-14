pragma solidity ^0.5.0;

import "../contracts/EventTickets.sol";


contract ProxyActor {

    EventTickets public escrow;

    function() external payable {}

    constructor(EventTickets _escrow)
        public
    {
        escrow = _escrow;
    }

    function purchaseTickets(uint numTickets, uint price)
    public payable
    returns (bool) {
        (bool success, ) =
            address(escrow).call.value(price)(abi.encodeWithSignature("buyTickets(uint256)", numTickets));
        return success;
    }

    function returnTickets()
    public payable
    returns (bool) {
        (bool success, ) =
            address(escrow).call(abi.encodeWithSignature("getRefund()"));
        return success;
    }

    function endEventSale()
    public payable
    returns (bool) {
        (bool success, ) =
            address(escrow).call(abi.encodeWithSignature("endSale()"));
        return success;
    }
}

