// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./IMarketCurrencyManager.sol";
import "./Ownable.sol";

contract MarketCurrencyManager is IMarketCurrencyManager, Ownable {
    bool currencyPublicAll;
    uint256 commisionDefault; //2 decinal
    uint256 minAmountDefault;

    struct Currency {
        uint256 commission; //2 decinal
        uint256 minAmount;
        bool valid;
    }
    mapping(address => Currency) currencies;
    event UpdateCurrency(
        address currency,
        uint256 commision,
        uint256 minAmount,
        bool valid,
        uint256 time
    );

    constructor(
        bool _currencyPublicAll,
        uint256 _commisionDefault,
        uint256 _minAmountDefault
    ) {
        currencyPublicAll = _currencyPublicAll;
        commisionDefault = _commisionDefault;
        minAmountDefault = _minAmountDefault;
    }

    function setCurrencyPublicAll(bool _currencyPublicAll) external onlyOwner {
        currencyPublicAll = _currencyPublicAll;
    }

    function setCommisionDefault(uint256 _commisionDefault) external onlyOwner {
        commisionDefault = _commisionDefault;
    }

    function setMinAmountDefault(uint256 _minAmountDefault) external onlyOwner {
        minAmountDefault = _minAmountDefault;
    }

    function setCurrencies(
        address[] memory _currencies,
        uint256[] memory _commisions,
        uint256[] memory _minAmounts,
        bool[] memory _valids
    ) external override onlyOwner {
        require(
            _currencies.length == _commisions.length,
            "Error: invalid input"
        );
        require(
            _currencies.length == _minAmounts.length,
            "Error: invalid input"
        );
        require(_currencies.length == _valids.length, "Error: invalid input");
        for (uint16 i = 0; i < _currencies.length; i++) {
            currencies[_currencies[i]] = Currency(
                _commisions[i],
                _minAmounts[i],
                _valids[i]
            );
            emit UpdateCurrency(
                _currencies[i],
                _commisions[i],
                _minAmounts[i],
                _valids[i],
                block.timestamp
            );
        }
    }

    function getCurrency(address _currency)
        external
        view
        override
        returns (
            uint256,
            uint256,
            bool
        )
    {
        if (currencies[_currency].valid)
            return (
                currencies[_currency].commission,
                currencies[_currency].minAmount,
                currencies[_currency].valid
            );

        if (currencyPublicAll) {
            return (commisionDefault, minAmountDefault, true);
        } else return (0, 0, false);
    }
}
