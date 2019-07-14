pragma solidity ^0.5.0;

contract EventTicketsV2 {

    address public owner;
    uint   TICKET_PRICE = 100 wei;

    uint public idGenerator;

    struct Event {
        string description;         // event description
        string website;             // event website
        uint totalTickets;          // total number of tickets available to purchase
        uint sales;                 // total number of tickets sold
        bool isOpen;                // is the event opened for sale
        mapping (address => uint) buyers;       // mapping of buyers and their ticket purchase
    }

    mapping (uint => Event) public events;

    event LogEventAdded(string desc, string url, uint ticketsAvailable, uint eventId);
    event LogBuyTickets(address buyer, uint eventId, uint numTickets);
    event LogGetRefund(address accountRefunded, uint eventId, uint numTickets);
    event LogEndSale(address owner, uint balance, uint eventId);

    modifier isOwner()
    {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier isOpenForSales(uint eventId)
    {
        require(events[eventId].isOpen, "Event is closed");
        _;
    }


    modifier hasEnoughFunds(uint eventId, uint numTickets)
    {
        require (
            msg.value >= numTickets * TICKET_PRICE,
            "Not enough was paid"
        );
        _;
    }

    modifier canHonorSale(uint eventId, uint numTickets)
    {
        require (
            events[eventId].totalTickets >= numTickets,
            "Not enough tickets to sell"
        );
        _;
    }

    modifier refundExcessPayment(uint eventId, uint numTickets)
    {
        _;
        uint amountToRefund = msg.value - (TICKET_PRICE * numTickets);
        (msg.sender).transfer(amountToRefund);
    }

    modifier hasPurchasedTickets(uint eventId) {
        require (
            events[eventId].buyers[msg.sender] > 0,
            "Buyer didn't buy any tickets"
        );
        _;
    }

    constructor()
        public
    {
        owner = msg.sender;
    }

    function addEvent(string memory _description, string memory _url, uint _totalTickets)
        public
        isOwner()
        returns (uint)
    {
        events[idGenerator]= Event(_description, _url, _totalTickets, 0, true );
        emit LogEventAdded(_description, _url, _totalTickets, idGenerator);
        return idGenerator++;
    }


    function readEvent(uint id)
        public
        view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        return (events[id].description, events[id].website, events[id].totalTickets, events[id].sales, events[id].isOpen);
    }

    function buyTickets(uint eventId, uint numTickets)
        public
        payable
        isOpenForSales(eventId)
        hasEnoughFunds(eventId, numTickets)
        canHonorSale(eventId, numTickets)
        refundExcessPayment(eventId, numTickets)
    {
        events[eventId].buyers[msg.sender] += numTickets;
        events[eventId].totalTickets -= numTickets;
        events[eventId].sales += numTickets;

        emit LogBuyTickets(msg.sender, eventId, numTickets);
    }

    function getRefund(uint eventId)
        public
        payable
        isOpenForSales(eventId)
        hasPurchasedTickets(eventId)
    {
        uint numTickets = events[eventId].buyers[msg.sender];
        events[eventId].buyers[msg.sender] -= numTickets;
        events[eventId].totalTickets += numTickets;
        events[eventId].sales -= numTickets;

        uint refundAmount = numTickets * TICKET_PRICE;
        (msg.sender).transfer(refundAmount);

        emit LogGetRefund(msg.sender, eventId, numTickets);
    }

    function getBuyerNumberTickets(uint eventId)
        public
        view
        returns (uint)
    {
        return events[eventId].buyers[msg.sender];
    }

    function endSale(uint eventId)
        public
        isOwner()
    {
        events[eventId].isOpen = false;
        uint balance = events[eventId].sales * TICKET_PRICE;
        msg.sender.transfer(balance);
        emit LogEndSale(msg.sender, balance, eventId);
    }
}
