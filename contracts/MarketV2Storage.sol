// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./access/Ownable.sol";

contract MarketV2Storage is Ownable {
    struct Item {
        address owner;
        address currency;
        uint256 price;
        uint256 listingTime;
        uint256 openTime;
    }
    mapping(uint256 => Item) public items;

    address market;

    modifier onlyMarket() {
        require(market == _msgSender(), "Storage: only market");
        _;
    }

    function setMarket(address _market) external onlyOwner {
        require(_market != address(0), "Error: address(0)");
        market = _market;
    }

    function addItem(
        uint256 _nftId,
        address _owner,
        address _currency,
        uint256 _price,
        uint256 _listingTime,
        uint256 _openTime
    ) public onlyMarket {
        items[_nftId] = Item(
            _owner,
            _currency,
            _price,
            _listingTime,
            _openTime
        );
    }

    function addItems(
        uint256[] memory _nftIds,
        address[] memory _owners,
        address[] memory _currencies,
        uint256[] memory _prices,
        uint256[] memory _listingTimes,
        uint256[] memory _openTimes
    ) external onlyMarket {
        for (uint256 i = 0; i < _nftIds.length; i++) {
            addItem(
                _nftIds[i],
                _owners[i],
                _currencies[i],
                _prices[i],
                _listingTimes[i],
                _openTimes[i]
            );
        }
    }

    function deleteItem(uint256 _nftId) public onlyMarket {
        delete items[_nftId];
    }

    function deleteItems(uint256[] memory _nftIds) external onlyMarket {
        for (uint256 i = 0; i < _nftIds.length; i++) {
            deleteItem(_nftIds[i]);
        }
    }

    function updateItem(
        uint256 _nftId,
        address _owner,
        address _currency,
        uint256 _price,
        uint256 _listingTime,
        uint256 _openTime
    ) external onlyMarket {
        items[_nftId] = Item(
            _owner,
            _currency,
            _price,
            _listingTime,
            _openTime
        );
    }

    function getItem(uint256 _nftId)
        external
        view
        returns (
            address,
            address,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            items[_nftId].owner,
            items[_nftId].currency,
            items[_nftId].price,
            items[_nftId].listingTime,
            items[_nftId].openTime
        );
    }
}
