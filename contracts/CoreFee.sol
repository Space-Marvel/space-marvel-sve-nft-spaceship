// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./access/Ownable.sol";
import "./ERC/ERC20/IBEP20.sol";
import "./ERC/ERC20/SafeBEP20.sol";

contract CoreFee is Ownable {
    using SafeBEP20 for IBEP20;
    IBEP20 public feeContract;
    address public spaceShipCore;
    uint256 public bornFee;
    uint256 public evolveFee;
    uint256 public breedFee;
    uint256 public destroyFee;

    constructor(IBEP20 _feeContract) {
        require(address(_feeContract) != address(0), "Error: address(0)");
        feeContract = _feeContract;
    }

    modifier onlySpaceShipCore() {
        require(_msgSender() == spaceShipCore, "Error: Not SVECore");
        _;
    }

    function setSVESpaceShipCore(address _spaceShipCore) external onlyOwner {
        require(_spaceShipCore != address(0), "Error: address(0)");
        spaceShipCore = _spaceShipCore;
    }

    function setFeeContract(IBEP20 _feeContract) external onlyOwner {
        require(address(_feeContract) != address(0), "Error: address(0)");
        feeContract = _feeContract;
    }

    function setBornFee(uint256 _bornFee) external onlyOwner {
        bornFee = _bornFee;
    }

    function setEvolveFee(uint256 _evolveFee) external onlyOwner {
        evolveFee = _evolveFee;
    }

    function setBreedFee(uint256 _breedFee) external onlyOwner {
        breedFee = _breedFee;
    }

    function setDestroyFee(uint256 _destroyFee) external onlyOwner {
        destroyFee = _destroyFee;
    }

    function chargeBornFee(
        address _toAddress,
        uint256 _nftId,
        uint256 _gene
    ) external onlySpaceShipCore {
        if (bornFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        // feeContract.transferFrom(_toAddress, owner(), bornFee);
        feeContract.safeTransferFrom(_toAddress, owner(), bornFee);
    }

    function chargeEvolveFee(
        address _toAddress,
        uint256[] memory _nftIds,
        uint256 _newGene
    ) external onlySpaceShipCore {
        if (evolveFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        // feeContract.transferFrom(_toAddress, owner(), evolveFee);
        feeContract.safeTransferFrom(_toAddress, owner(), evolveFee);
    }

    function chargeBreedFee(
        address _toAddress,
        uint256 _nftId1,
        uint256 _nftId2,
        uint256 _newGene
    ) external onlySpaceShipCore {
        if (breedFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        // feeContract.transferFrom(_toAddress, owner(), breedFee);
        feeContract.safeTransferFrom(_toAddress, owner(), breedFee);
    }

    function chargeDestroyFee(address _toAddress, uint256 _nftId)
        external
        onlySpaceShipCore
    {
        if (destroyFee == 0) return;
        //TODO: base on nftid and gene can have another calculation
        // feeContract.transferFrom(_toAddress, owner(), destroyFee);
        feeContract.safeTransferFrom(_toAddress, owner(), destroyFee);
    }
}
