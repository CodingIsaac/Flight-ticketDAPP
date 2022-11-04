// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract VirginAirways is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    uint256 MAX_SUPPLY = 40000000;

    Counters.Counter private _tokenIdCounter;

   
    enum ticketStatus {
        SOLD,
        REDEEMED,
        CANCELLED,
        DEFAULT
    }

    struct Ticket {
        uint256 id;
        uint256 issued;
        uint256 schedule;
        uint256 expires;
        uint256 price;
        uint256 origin;
        uint256 destination;
        address owner;
        ticketStatus status;
    }

    mapping(uint256 => Ticket) _tickets;

    uint256 _numberofTicket;
    string _uri;

    constructor() ERC721("Virgin Airways", "VTG") {}
    receive() external payable{}

    function createTicket(
        uint256 schedule,
        uint256 expires,
        uint256 price,
        uint256 origin,
        uint256 destination
    ) public onlyOwner {
        _tickets[_numberofTicket] = Ticket (
            ++_numberofTicket,
            block.timestamp,
            schedule,
            expires + block.timestamp,
            price,
            origin,
            destination,
            address(0),
            ticketStatus.DEFAULT
        );

    }

    function buyTicket(uint256 id) public payable {
        Ticket storage ticket = _tickets[id];
        require(ticket.id != 0, "Invalid Identifier");
        require(ticket.status == ticketStatus.DEFAULT);
        ticket.price += msg.value;
        ticket.status = ticketStatus.SOLD;
        ticket.owner = msg.sender;
        safeMint(msg.sender, _uri);

    }

    function destroyTicker(uint256 id) public onlyOwner {
        Ticket storage ticket = _tickets[id];
        require(ticket.id != 0, "invalid identifier given");
        require(ticket.status == ticketStatus.DEFAULT);
        ticket.status = ticketStatus.CANCELLED;
    }

    function redeemTicket(
        uint256 id
       
        ) public {
            require(_tickets[id].status == ticketStatus.SOLD, "Unreedemable");
        Ticket storage ticket = _tickets[id];
        ticket.status = ticketStatus.REDEEMED;

           

    }

    function safeMint(address to, string memory uri) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        require(tokenId <= MAX_SUPPLY, "Balance Exceeded");
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }



    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
