pragma solidity ^0.5.0;

import "../contracts/EventTickets.sol";
import "../contracts/EventFactory.sol";


contract ProxyActor {

    EventTickets public escrow;
    EventFactory public factory;

    function() external payable {}

    constructor(EventFactory _factory, EventTickets _escrow)
        public
    {
        escrow = _escrow;
        factory = _factory;
    }

    function setEvent(EventTickets _escrow)
    public
    {
        escrow = _escrow;
    }

    function createEvent(string memory _description, string memory _url, uint _totalTickets)
        private
    returns (EventsTicket)
    {
        (, bytes memory data) =  address(factory).call(abi.encodeWithSignature(
                "createEvent(string memory,string memory,uint256)",
                _description, _url, _totalTickets));

        return abi.decode(data, (EventsTicket));
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

