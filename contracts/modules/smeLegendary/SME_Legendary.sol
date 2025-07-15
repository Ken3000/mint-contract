// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import ".deps/npm/erc721l/contracts/ERC721L.sol";
//import "/contracts/mixins/ERC721L.sol";

import "contracts/lib/@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import {Strings} from "contracts/lib/@openzeppelin/contracts/utils/Strings.sol";
import "contracts/lib/@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "contracts/lib/@openzeppelin/contracts/security/ReentrancyGuard.sol";

import {Ownable} from "/contracts/mixins/Ownable.sol";
import "/contracts/modules/IModule.sol";
import "/contracts/free/FreeVersion.sol";

/**
 * @title SME_Legendary
 * @custom:version 1.0.0
 * @dev Модуль NFT Легендари для SoulMate Partners
 * @notice Вторая стадия минта LEGENDARY
**/
contract SME_Legendary is ERC721L, Ownable, ReentrancyGuard, IERC721Receiver, IModule  {
    
    using Strings for uint256;

    /// @dev Название модуля
    string public constant MODULE_NAME = "SME_Legendary";
    /// @dev Версия модуля
    uint256 public immutable MODULE_VERSION = _encodeVersion(1, 0, 0); 

    /// @dev Предельное количество токенов для каждой из стадий
    uint256 public constant MAX_SUPPLY_GENESIS = 1200;
    uint256 public constant MAX_SUPPLY_LEGEND = 5000;
    uint256 public constant MAX_SUPPLY_EPIC = 25000;

    /// @dev This event emits when the metadata of a token is changed.
    /// So that the third-party platforms such as NFT market could
    /// timely update the images and related attributes of the NFT.
    event MetadataUpdate(uint256 _tokenId);

    constructor(string memory name, string memory symbol) ERC721L(name, symbol) {
        _initOwnable();
        _init(name, symbol);
    }

    /// @dev замена конструктора для прокси
    function init(string memory name, string memory symbol) public onlyOwner{
        _init(name, symbol);
    } 

    /// @dev Передача токена на другой кошелек
    function transferFrom(address from, address to, uint256 tokenId) public payable virtual override {
        super.transferFrom(from,to,tokenId);
        _updateOwner(from, to, tokenId);
    }

    function name() public view virtual override returns (string memory) {
        return SMElegendaryStorage.name();
    }
    
    function symbol() public view virtual override returns (string memory) {
        return SMElegendaryStorage.symbol();
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
    
    function fee() public view returns(uint256){
        return SMElegendaryStorage.fee();
    }

    /// @dev Возвращает baseTokenURI
    function baseURI() public view returns (string memory) {
        return SMElegendaryStorage.baseTokenURI();
    }

    /// @dev Returns the next token ID to be minted.
    function nextTokenId() public view returns (uint256) {
        return SMElegendaryStorage._currentIndex();
    }

    /// @dev See {IERC721Metadata-tokenURI}.
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        //_requireOwned(tokenId);

        string memory _tokenURI = SMElegendaryStorage.tokenURIs(tokenId);
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via string.concat).
        if (bytes(_tokenURI).length > 0) {
            return string.concat(base, _tokenURI);
        }

        return super.tokenURI(tokenId);
    }

    /// @dev Возвращает идентификатор токена по индексу
    function balanceOfId(address owner, uint256 index) public view returns (uint256) {
        //if (owner == address(0)) _revert(BalanceQueryForZeroAddress.selector);
        return SMElegendaryStorage.ownedTokens(owner,index);
    }
    
    function setFee(uint256 _fee) external onlyOwner {
        SMElegendaryStorage.fee(_fee);
    }

    function setGenesislistRoot(bytes32 merkleroot) external onlyOwner {
        // SMElegendaryStorage.genesislistRoot(merkleroot);
    }

    function setLegendlistRoot(bytes32 merkleroot) external onlyOwner {
        SMElegendaryStorage.legendlistRoot(merkleroot);
    }

    function setEpiclistRoot(bytes32 merkleroot) external onlyOwner {
        SMElegendaryStorage.epiclistRoot(merkleroot);
    }

    /// @dev Минт для генезисов - передает proof для проверки
    // function genesisMint(address to, bytes32[] calldata proof) external payable nonReentrant {
    //     uint256 _tokenId = _nextTokenId();
    //     require( _tokenId < MAX_SUPPLY_GENESIS, "Exceed alloc");
    //     require(SMElegendaryStorage.guaranteed_minted(to) == false, "Already minted");
    //     require(msg.value == SMElegendaryStorage.fee(), "Not match price");
    //     bytes32 leaf = keccak256(abi.encodePacked(to));
    //     bool isValidLeaf = MerkleProof.verify(proof, SMElegendaryStorage.genesislistRoot(), leaf);
    //     require(isValidLeaf == true, "Not in merkle");
    //     SMElegendaryStorage.guaranteed_minted(to,true);
    //     _safeMint(to, 1);
    //     _setTokenURI(_tokenId, _tokenURI(_tokenId));
    //     _updateOwner(address(0x0),to,_tokenId);
    // }

    /// @dev Минт для Легенлари - передает proof для проверки
    function legendaryMint(address to, bytes32[] calldata proof) external payable nonReentrant {
        uint256 _tokenId = _nextTokenId();
        require( _tokenId > MAX_SUPPLY_GENESIS, "Error alloc - id from genesis");
        require( _tokenId < MAX_SUPPLY_LEGEND, "Exceed alloc");
        require(SMElegendaryStorage.guaranteed_minted(to) == false, "Already minted");
        require(msg.value == SMElegendaryStorage.fee(), "Not match price");
        bytes32 leaf = keccak256(abi.encodePacked(to));
        bool isValidLeaf = MerkleProof.verify(proof, SMElegendaryStorage.legendlistRoot(), leaf);
        require(isValidLeaf == true, "Not in merkle");
        SMElegendaryStorage.guaranteed_minted(to,true);
        _safeMint(to, 1);
        _setTokenURI(_tokenId, _tokenURI(_tokenId));
        _updateOwner(address(0x0),to,_tokenId);
    }

    /// @dev Установка базового URI
    function setBaseURI(string calldata URI) external onlyOwner {
        SMElegendaryStorage.baseTokenURI(URI);
    }

    /// @dev Установка URI для конкретного токена
    function setTokenURI(uint256 tokenId, string calldata URI) external onlyOwner {
        _setTokenURI(tokenId, URI);
    }

    /// @dev Устанавливает defaultTokenURI 
    function setDefaultTokenURI(string calldata URI) external onlyOwner {
        SMElegendaryStorage.defaultTokenURI(URI);
    }

    /// @dev withdraw
    function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }
    
    /// @dev Возвращает существует ли tokenId
    function exists(uint256 tokenId) external view returns (bool result){
        return _exists(tokenId);
    }
    /**
     * @dev Returns the starting token ID for sequential mints.
     *
     * Override this function to change the starting token ID for sequential mints.
     *
     * Note: The value returned must never change after any tokens have been minted.
     */
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Emits {MetadataUpdate}.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        SMElegendaryStorage.tokenURIs(_tokenURI, tokenId);
        emit MetadataUpdate(tokenId);
    }

    /**
     * @dev Обновляем владельцев токена
     */
    function _updateOwner(address previousOwner, address to, uint256 tokenId ) internal {

        if (previousOwner == address(0)) {  // добавление токена в структуры отслеживания
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) { // удаление у владельца
            _removeTokenFromOwnerEnumeration(previousOwner, tokenId);
        }
        if (to == address(0)) { //удаление токена из структур отслеживания
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {  //добавляем токен новому владельцу
            _addTokenToOwnerEnumeration(to, tokenId);
        } 

    }

    /// @dev Формирует `tokenURI` по `baseURI` либо `defaultTokenURI`
    function _tokenURI(uint256 tokenId) private view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _baseURI = baseURI();
        return bytes(_baseURI).length > 0 ? string(abi.encodePacked(_baseURI, tokenId.toString(),".json")) : SMElegendaryStorage.defaultTokenURI();
    }

    /**
     * @dev Добавление токена в структуры для отслеживания
     * @param tokenId uint256 идентификатор токена
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        SMElegendaryStorage.addTokenToAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        SMElegendaryStorage.removeTokenFromOwnerEnumeration(from, tokenId,balanceOf(from));
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        SMElegendaryStorage.removeTokenFromAllTokensEnumeration(tokenId);
    }


    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        SMElegendaryStorage.addTokenToOwnerEnumeration(to, tokenId,balanceOf(to) - 1);
    }
    
    /// @dev Инициализация для роутера
    function _init(string memory name, string memory symbol) private{
        SMElegendaryStorage.baseTokenURI("https://ipfs.sweb.ru/ipfs/QmbpN9qexgznkpTEQmrdxnSfWYCDAbLkBxm5vAC71jzRxo/");
        SMElegendaryStorage.defaultTokenURI("https://ipfs.sweb.ru/ipfs/QmYRbSM2QazGb5QHogodqJfoPVaSib32ttUpvNkyJKfhXU/?filename=smeamb.json");
        SMElegendaryStorage.legendlistRoot(0xdfb96c060b2e58f09345a394fd8e994a6e7ac3539cdd256304c6e181a216752e);
        SMElegendaryStorage.fee(145); 
        SMElegendaryStorage.name(name);
        SMElegendaryStorage.symbol(symbol);
        SMElegendaryStorage._currentIndex(1200);
        SMElegendaryStorage._startTokenId(1200);
    }
}