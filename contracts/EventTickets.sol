pragma solidity ^0.5.0;

contract EventTickets {

    address public owner;

    uint   TICKET_PRICE = 100 wei;

    struct Event {
        string description;
        string website;
        uint unsoldTickets;
        uint soldTickets;
        mapping (address => uint) buyers;
        bool isOpen;
    }

    Event myEvent;

    event LogEventCreated (address owner, string description, string website, uint unsoldTickets);
    event LogBuyTickets (address purchaser, uint numTickets);
    event LogGetRefund (address purchaser, uint numTickets);
    event LogEndSale (address owner, uint balance);

    modifier isOwner()
    {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier isEventOpen() {
        require (
            myEvent.isOpen == true,
            "Event is not opened"
        );
        _;
    }

    modifier hasEnoughFunds(uint numTickets) {
        require (
            msg.value >= numTickets * TICKET_PRICE,
            "Not enough was paid"
        );
        _;
    }

    modifier hasEnoughTickets(uint numTickets) {
        require (
            myEvent.unsoldTickets >= numTickets,
            "Not enough tickets to sell"
        );
        _;
    }

    modifier refundExcessPayment(uint numTickets) {
        _;
        uint amountToRefund = msg.value - (TICKET_PRICE * numTickets);
        (msg.sender).transfer(amountToRefund);
    }

    modifier hasTicketsToRefund() {
        require (
            getBuyerTicketCount(msg.sender) > 0,
            "Buyer didn't buy any tickets"
        );
        _;
    }

    constructor(string memory _description, string memory _website, uint _totalTickets)
    public
    {
        owner = msg.sender;
        myEvent.description = _description;
        myEvent.website = _website;
        myEvent.unsoldTickets = _totalTickets;
        myEvent.soldTickets = 0;
        myEvent.isOpen = true;
        emit LogEventCreated(owner, _description, _website, _totalTickets);
    }

    function readEvent()
        public
        view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        return (myEvent.description, myEvent.website, myEvent.unsoldTickets, myEvent.soldTickets, myEvent.isOpen);
    }

    function getBuyerTicketCount(address buyer)
        public
        view
        returns (uint)
    {
        return myEvent.buyers[buyer];
    }

    function buyTickets(uint numTickets)
        public
        payable
        isEventOpen()
        hasEnoughFunds(numTickets)
        hasEnoughTickets(numTickets)
        refundExcessPayment(numTickets)
    {
        myEvent.buyers[msg.sender] += numTickets;
        myEvent.unsoldTickets -= numTickets;
        myEvent.soldTickets += numTickets;

        emit LogBuyTickets(msg.sender, numTickets);
    }

    function getRefund()
        public
        payable
        isEventOpen()
        hasTicketsToRefund()
    {
        uint numTickets = getBuyerTicketCount(msg.sender);
        myEvent.buyers[msg.sender] -= numTickets;
        myEvent.unsoldTickets += numTickets;
        myEvent.soldTickets -= numTickets;

        uint refundAmount = numTickets * TICKET_PRICE;
        (msg.sender).transfer(refundAmount);

        emit LogGetRefund(msg.sender, numTickets);
    }

    function endSale()
        public
        isOwner()
        isEventOpen()
    {
        myEvent.isOpen = false;
        uint balance = myEvent.soldTickets * TICKET_PRICE;
        msg.sender.transfer(balance);
        emit LogEndSale(msg.sender, balance);
    }
}
