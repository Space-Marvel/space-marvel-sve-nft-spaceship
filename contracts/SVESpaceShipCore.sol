// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./ERC/ERC721/ERC721.sol";
import "./access/Ownable.sol";
import "./access/ISVEAccessManager.sol";
import "./CoreFee.sol";
import "./security/ReentrancyGuard.sol";
import "./ERC/ERC20/SafeBEP20.sol";

contract SVESpaceShipCore is ERC721, Ownable, ReentrancyGuard {
    using SafeBEP20 for IBEP20;

    uint256 public currentId;
    ISVEAccessManager SVEAccessManager;
    CoreFee coreFee;

    struct Hero {
        uint256[] parents;
        uint256 gene;
        uint256 breedCount;
        uint256 bornAt;
    }
    mapping(uint256 => Hero) heros;
    uint256 breedMax;

    event Born(
        address indexed caller,
        address indexed to,
        uint256 indexed nftId,
        uint256 gene,
        uint256 time
    );
    event Evolve(
        address indexed caller,
        uint256[] nftIDs,
        uint256 newGene,
        uint256 time
    );
    event Breed(
        address indexed caller,
        address indexed to,
        uint256 indexed newNftId,
        uint256 parent1,
        uint256 parent2,
        uint256 newGene,
        uint256 time
    );
    event Destroy(address indexed caller, uint256 indexed nftId, uint256 time);

    constructor(
        ISVEAccessManager _SVEAccessManager,
        CoreFee _coreFee,
        uint256 _breedMax
    ) ERC721("spacemarvel.io", "SVE721") {
        require(address(_SVEAccessManager) != address(0), "Error: address(0)");
        require(address(_coreFee) != address(0), "Error: address(0)");
        SVEAccessManager = _SVEAccessManager;
        coreFee = _coreFee;
        breedMax = _breedMax;
        currentId = 1;
    }

    function setSVEAccessManager(ISVEAccessManager _SVEAccessManager)
        public
        onlyOwner
    {
        require(address(_SVEAccessManager) != address(0), "Error: address(0)");
        SVEAccessManager = _SVEAccessManager;
    }

    function setCoreFee(CoreFee _coreFee) external onlyOwner {
        require(address(_coreFee) != address(0), "Error: address(0)");
        coreFee = _coreFee; // check
    }

    function born(address _toAddress, uint256 _gene) public nonReentrant {
        require(
            SVEAccessManager.isBornAllowed(_msgSender(), _gene),
            "Not have born permisison"
        );
        uint256 _nftId = currentId;

        _mint(_toAddress, _nftId);

        heros[_nftId].gene=_gene;
        heros[_nftId].breedCount=0;
        heros[_nftId].bornAt=block.timestamp;

        //charge fee
        coreFee.chargeBornFee(_toAddress, _nftId, _gene);

        emit Born(_msgSender(), _toAddress, _nftId, _gene, block.timestamp);

        currentId = currentId + 1;
        // return _nftId;
    }

    function borns(address[] calldata _toAddresses, uint256[] calldata _genes)
        external
    {
        require(_toAddresses.length == _genes.length, "Invalid input");

        for (uint256 i = 0; i < _toAddresses.length; i++) {
            born(_toAddresses[i], _genes[i]);
            // ids.push(id);
        }
        // return ids;
    }

    function evolve(uint256[] memory _nftIds, uint256 _newGene) external nonReentrant {
        require(
            SVEAccessManager.isEvolveAllowed(_msgSender(), _newGene, _nftIds),
            "Not have evolve permisison"
        );
        for (uint8 i = 0; i < _nftIds.length; i++)
            require(ownerOf(_nftIds[i]) != address(0), "NFT id invalid");

        uint256 _newNftId = currentId;

        _mint(_msgSender(), _newNftId);
        heros[_newNftId] = Hero(
            _nftIds,
            _newGene,
            0,
            block.timestamp
        );

        for (uint8 i = 0; i < _nftIds.length; i++)
            delete heros[_nftIds[i]];

        //charge fee
        coreFee.chargeEvolveFee(_msgSender(), _nftIds, _newGene);
        emit Evolve(_msgSender(), _nftIds, _newGene, block.timestamp);
    }

    //only whilelist can call breed
    function breed(
        address _toAddress,
        uint256 _nftId1,
        uint256 _nftId2,
        uint256 _gene
    ) external nonReentrant returns (uint256) {
        require(
            SVEAccessManager.isBreedAllowed(_msgSender(), _nftId1, _nftId2),
            "Not have breed permisison"
        );
        require(ownerOf(_nftId1) != address(0), "NFT 1 invalid");
        require(ownerOf(_nftId2) != address(0), "NFT 2 invalid");
        require(_nftId1 != _nftId2, "NFT the same");

        //if breedMax == 0 dont check logic
        if (breedMax != 0) {
            require(
                heros[_nftId1].breedCount < breedMax,
                "NFT 1 breed max"
            );
            require(
                heros[_nftId2].breedCount < breedMax,
                "NFT 2 breed max"
            );
        }

        uint256 _nftId = currentId;

        _mint(_toAddress, _nftId);

        heros[_nftId].parents.push(_nftId1);
        heros[_nftId].parents.push(_nftId2);
        heros[_nftId].gene=_gene;
        heros[_nftId].breedCount=0;
        heros[_nftId].bornAt=block.timestamp;

        heros[_nftId1].breedCount += 1;
        heros[_nftId2].breedCount += 1;

        currentId = currentId + 1;

        //charge fee
        coreFee.chargeBreedFee(_toAddress, _nftId1, _nftId2, _gene);
        emit Breed(
            _msgSender(),
            _toAddress,
            _nftId,
            _nftId1,
            _nftId2,
            _gene,
            block.timestamp
        );
        return _nftId;
    }

    function destroy(uint256 _nftId) external nonReentrant {
        require(
            SVEAccessManager.isDestroyAllowed(_msgSender(), _nftId),
            "Not have destroy permisison"
        );
        require(ownerOf(_nftId) != _msgSender(), "Not owner");
        _burn(_nftId);
        delete heros[_nftId];

        //charge fee
        coreFee.chargeDestroyFee(_msgSender(), _nftId);
        emit Destroy(_msgSender(), _nftId, block.timestamp);
    }

    function exists(uint256 _id) external view returns (bool) {
        return _exists(_id);
    }

    function get(uint256 _nftId)
        external
        view
        returns (
            address,
            uint256[] memory,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            ownerOf(_nftId),
            heros[_nftId].parents,
            heros[_nftId].gene,
            heros[_nftId].breedCount,
            heros[_nftId].bornAt
        );
    }
}
