pragma solidity ^0.5.0;

import "../contracts/EventTickets.sol";
import "../contracts/EventTicketsV2.sol";

contract EventFactory {

    uint public eventId;

    function createEvent(string memory _description, string memory _url, uint _totalTickets)
        public
    returns(uint uint, EventTicket)
    {
        return (eventId++, new EventTickets(_description, _url, _totalTickets));
    }

    function createEventV2(string memory _description, string memory _url, uint _totalTickets)
        public
    returns(uint uint, EventTicketV2)
    {
        return (eventId++, new EventTicketsV2(_description, _url, _totalTickets));
    }
}
