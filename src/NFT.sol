// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";

contract TEST is
    ERC721,
    ERC721Enumerable,
    ERC721Burnable,
    ERC2981,
    AccessControl
{
    using Counters for Counters.Counter;
    using Strings for uint256;

    uint256 public constant MAX_SUPPLY = 1000;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    string public baseURI;
    string public contractURI;
    string public notRevealedURI;
    string public baseExtension = ".json";
    Counters.Counter private _tokenIdCounter;
    bool public revealed = false;

    event URI(uint256 tokenId);
    event URIAll();
    event ContractURI();

    modifier onlyOwner() {
        _checkRole(ADMIN_ROLE, msg.sender);
        _;
    }

    constructor() ERC721("DeGenerousDAO", "DGRS") {
        _tokenIdCounter.increment(); // start from 1
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function batchMint(
        uint256 _batchSize,
        address _receiver
    ) external onlyOwner {
        require(
            _batchSize + totalSupply() <= MAX_SUPPLY,
            "Maximium supply exceeded"
        );
        for (uint i = 0; i < _batchSize; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(_receiver, tokenId);
        }
    }

    function tokensOfOwner(
        address _owner
    ) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        uint256[] memory result = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            result[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return result;
    }

    function reveal() external onlyOwner {
        revealed = true;
        emit URIAll();
    }

    function setDefaultRoyalty(
        address _receiver,
        uint96 _feeNumerator
    ) external onlyOwner {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
        emit URIAll();
    }

    function setNotRevealedURI(
        string memory _notRevealedURI
    ) external onlyOwner {
        notRevealedURI = _notRevealedURI;
        emit URIAll();
    }

    function setContractURI(string memory _contractURI) external onlyOwner {
        contractURI = _contractURI;
        emit ContractURI();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return notRevealedURI;
        }
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function withdraw() public payable onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
}
