pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "../contracts/EventTickets.sol";
import "../contracts/ProxyActor.sol";
import "../contracts/EventFactory.sol";


contract TestEventTicket {

    uint public initialBalance = 1 ether;

    EventFactory public eventFactory;

    EventTickets public theEvent;
    ProxyActor public fan;
    ProxyActor public underFundedFan;
    ProxyActor public hater;

    string _description = 'TruffleCon Jamboree';
    string _url = 'trufflesuite.com';
    uint _totalTickets = 256;

    function() external payable {}

    function before()
        public
    {
        eventFactory = new EventFactory();
    }

    function beforeEach()
        public
    {
        theEvent = new EventTickets(_description, _url, _totalTickets);
        (,theEvent) = eventFactory.createEvent(_description, _url, _totalTickets);

        fan = new ProxyActor(eventFactory, theEvent);
        underFundedFan = new ProxyActor(eventFactory, theEvent);
        hater = new ProxyActor(eventFactory, theEvent);

        address (fan).transfer(1000 wei);
    }

    function testFanCanBuyTickets()
        public
    {
        uint numTix = 2;
        uint price = numTix * 100;
        Assert.isTrue(
            fan.purchaseTickets(numTix, price),
            "Cannot buy tickets"
        );

        Assert.equal(
            theEvent.getBuyerTicketCount(address(fan)),
            numTix,
            "Should be able to buy tickets"
        );
    }

    function testHasToPayFairPrice()
        public
    {
        uint numTix = 1;
        uint price = numTix * 100;
        Assert.isFalse(
            underFundedFan.purchaseTickets(numTix, price),
            "Should not be able to buy tickets"
        );

        Assert.equal(
            theEvent.getBuyerTicketCount(address(underFundedFan)),
            0,
            "Should not have any tickets"
        );
    }

    function testHaterCannotCloseEvents()
        public
    {
        uint numTix = 16;
        uint price = numTix * 100;
        underFundedFan.purchaseTickets(numTix, price);

        Assert.isFalse(
            hater.endEventSale(),
            "Should not be able to close Sale"
        );
    }
}
