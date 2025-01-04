// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract RealEstateMarket is ERC721{
    struct Property {
        address owner;                   
        address renter;
        uint price;
        bool isForSale;
        bool isForRent;
        uint rentPricePerDay;
        uint rentalDuration;
        string name;
        string description;
        string location;
        string renterName;
        string renterFullName;
    }

    mapping(uint => Property) public properties;
    uint public propertiesCount;
    uint public totalTransactions;

    event PropertyRegistered(uint indexed id, address indexed owner, uint price, 
    string name, string description, string location);
    event PropertySold(uint indexed id, address indexed buyer, uint price, 
    string buyerName, string buyerFullName);
    event PropertyRented(uint indexed id, address indexed renter, uint rentPricePerDay, 
    uint rentalDuration, string renterName, string renterFullName);
    event BuyProperty(uint indexed id, address indexed buyer, uint price, 
    string buyerName, string buyerFullName);

    modifier onlyOwner(uint _id) {
        require(properties[_id].owner == msg.sender, "You are not the owner of this property");
        _;
    }

    constructor() ERC721("RealEstateToken", "RET") {
        propertiesCount = 0;
        totalTransactions = 0;
    }

    function registerProperty(uint _price, string memory _name, string memory _description, string memory _location) public {
        propertiesCount++;
        uint tokenId = propertiesCount;
        
        _mint(msg.sender, tokenId);
        
        properties[tokenId] = Property({
            owner: msg.sender,
            renter: address(0), 
            price: _price,
            isForSale: false,
            isForRent: false,
            rentPricePerDay: 0,
            rentalDuration: 0,
            name: _name,
            description: _description,
            location: _location,
            renterName: "",
            renterFullName: ""
        });
        
        emit PropertyRegistered(tokenId, msg.sender, _price, _name, _description, _location);
    }

    function buyProperty(uint _id, string memory _buyerName, string memory _buyerFullName) public payable {
        require(properties[_id].isForSale, "This property is not for sale");
        require(msg.value >= properties[_id].price, "Insufficient funds");

        address payable previousOwner = payable(properties[_id].owner);
        previousOwner.transfer(properties[_id].price);


        _transfer(properties[_id].owner, msg.sender, _id);

        properties[_id].owner = msg.sender;
        properties[_id].renter = address(0);
        properties[_id].isForSale = false;
        properties[_id].isForRent = false; 
        properties[_id].renterName = "";
        properties[_id].renterFullName = "";
        totalTransactions++;

        emit PropertySold(_id, msg.sender, properties[_id].price, _buyerName, _buyerFullName);
        emit BuyProperty(_id, msg.sender, properties[_id].price, _buyerName, _buyerFullName); 
    }

    function rentOutProperty(uint _id, uint _rentPricePerDay, uint _rentalDuration) public onlyOwner(_id) {
        require(!properties[_id].isForSale, "This property is currently for sale and cannot be rented");
        properties[_id].isForRent = true;
        properties[_id].rentPricePerDay = _rentPricePerDay;
        properties[_id].rentalDuration = _rentalDuration;
    }

    function rentProperty(uint _id, string memory _renterName, string memory _renterFullName) public payable {
        require(properties[_id].isForRent, "This property is not for rent");
        uint totalRentPrice = properties[_id].rentPricePerDay * properties[_id].rentalDuration;
        require(msg.value >= totalRentPrice, "Insufficient funds");

        address payable owner = payable(properties[_id].owner);
        owner.transfer(totalRentPrice);

        properties[_id].isForRent = false; 
        properties[_id].renter = msg.sender;
        properties[_id].renterName = _renterName;
        properties[_id].renterFullName = _renterFullName;
        totalTransactions++;

        emit PropertyRented(_id, msg.sender, properties[_id].rentPricePerDay, properties[_id].rentalDuration, _renterName, _renterFullName);
    }

    function saleProperty(uint _id, uint _price) public onlyOwner(_id) {
        require(!properties[_id].isForRent, "This property is currently rented and cannot be sold");
        properties[_id].isForSale = true;
        properties[_id].price = _price;
        emit PropertyRegistered(_id, properties[_id].owner, _price, properties[_id].name, properties[_id].description, properties[_id].location);
    }

    function getTotalTransactions() public view returns (uint) {
        return totalTransactions;
    }

    function getProperty(uint _id) public view returns (
        address owner,
        address renter,
        uint price,
        bool isForSale,
        bool isForRent,
        uint rentPricePerDay,
        uint rentalDuration,
        string memory name,
        string memory description,
        string memory location,
        string memory renterName,
        string memory renterFullName
    ) {
        Property memory property = properties[_id];
        return (
            property.owner,
            property.renter,
            property.price,
            property.isForSale,
            property.isForRent,
            property.rentPricePerDay,
            property.rentalDuration,
            property.name,
            property.description,
            property.location,
            property.renterName,
            property.renterFullName
        );
    }
}

