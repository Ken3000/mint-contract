// SPDX-License-Identifier: CC0
pragma solidity = 0.8.19 || 0.8.20 || 0.8.23 || 0.8.30;

/**
 * @title OwnableStorage
 * @custom:version 1.1.0
 * @dev Логику смотри в модуле smeLegendary
 * @notice Библиотека хранилища амбассадорки
**/
library SMElegendaryStorage{

    /// @dev Слот хранилища
    bytes32 constant SLOT = keccak256(bytes('SMElegendary'));

    // Bypass for a `--via-ir` bug (https://github.com/chiru-labs/ERC721A/pull/364).
    struct TokenApprovalRef {
        address value;
    }

    struct smeLegendaryStorage{
        /// @dev URI
        string baseTokenURI;
        string defaultTokenURI;
        mapping(uint256 tokenId => string) tokenURIs;
        
        /// @dev Отслеживание идентификаторов токенов у пользователей
        mapping(address owner => mapping(uint256 index => uint256)) ownedTokens;
        mapping(uint256 tokenId => uint256) ownedTokensIndex;
        uint256[] allTokens; 
        mapping(uint256 tokenId => uint256) allTokensIndex;

        /// @dev Корни дерева для минта
        bytes32 genesislistRoot; 
        bytes32 legendlistRoot; 
        bytes32 epiclistRoot; 

        /// @dev Комиссия за минт
        uint256 fee;

        /// @dev Сминтил ли пользователь NFT
        mapping(address => bool) guaranteed_minted; 

        // =============================================================
        //                            STORAGE ERC721L - префиксы '_' остались от ERC721L
        // =============================================================

        // The next token ID to be minted.
        uint256 _currentIndex;

        // The number of tokens burned.
        uint256 _burnCounter;

        // Token name
        string _name;

        // Token symbol
        string _symbol;

        // Mapping from token ID to ownership details
        // An empty struct value does not necessarily mean the token is unowned.
        // See {_packedOwnershipOf} implementation for details.
        //
        // Bits Layout:
        // - [0..159]   `addr`
        // - [160..223] `startTimestamp`
        // - [224]      `burned`
        // - [225]      `nextInitialized`
        // - [232..255] `extraData`
        mapping(uint256 => uint256) _packedOwnerships;

        // Mapping owner address to address data.
        //
        // Bits Layout:
        // - [0..63]    `balance`
        // - [64..127]  `numberMinted`
        // - [128..191] `numberBurned`
        // - [192..255] `aux`
        mapping(address => uint256) _packedAddressData;

        // Mapping from token ID to approved address.
        mapping(uint256 => TokenApprovalRef) _tokenApprovals;

        // Mapping from owner to operator approvals
        mapping(address => mapping(address => bool)) _operatorApprovals;

        // The amount of tokens minted above `_sequentialUpTo()`.
        // We call these spot mints (i.e. non-sequential mints).
        uint256 _spotMinted;

        uint256 _startTokenId;
    }
    /// @dev ERC721
    function name() external view returns(string memory){return _getStorage(SLOT)._name;}
    function name(string memory _name) external {_getStorage(SLOT)._name = _name;}
    function symbol() external view returns(string memory){return _getStorage(SLOT)._symbol;}
    function symbol(string memory _symbol) external {_getStorage(SLOT)._symbol = _symbol;}
    function _currentIndex() external view returns(uint256){return _getStorage(SLOT)._currentIndex;}
    function _currentIndex(uint256 _index) external {_getStorage(SLOT)._currentIndex = _index;}
    function _startTokenId() external view returns(uint256){return _getStorage(SLOT)._startTokenId;}
    function _startTokenId(uint256 _id) external {_getStorage(SLOT)._startTokenId = _id;}
    function _burnCounter() external view returns(uint256){return _getStorage(SLOT)._burnCounter;}
    function _burnCounter(uint256 _id) external {_getStorage(SLOT)._burnCounter = _id;}
    function _packedOwnerships(uint256 _tokenId) external view returns(uint256){return _getStorage(SLOT)._packedOwnerships[_tokenId];}
    function _packedOwnerships(uint256 _tokenId, uint256 _index) external{_getStorage(SLOT)._packedOwnerships[_tokenId] = _index;}
    function _packedAddressData(address _owner) external view returns(uint256){return _getStorage(SLOT)._packedAddressData[_owner];}
    function _packedAddressData(address _owner, uint256 _tokenId) external{_getStorage(SLOT)._packedAddressData[_owner] = _tokenId;}
    function _packedAddressDataIncr(address _owner) external{_getStorage(SLOT)._packedAddressData[_owner] = _getStorage(SLOT)._packedAddressData[_owner]+1;}
    function _packedAddressDataDecr(address _owner) external{_getStorage(SLOT)._packedAddressData[_owner] = _getStorage(SLOT)._packedAddressData[_owner]-1;}
    function _tokenApprovals(uint256 _tokenId) external view returns(TokenApprovalRef memory){return _getStorage(SLOT)._tokenApprovals[_tokenId];}
    function _tokenApprovals(uint256 _tokenId, address _address) external{_getStorage(SLOT)._tokenApprovals[_tokenId].value = _address;}
    function _operatorApprovals(address owner, address operator) external view returns(bool){return _getStorage(SLOT)._operatorApprovals[owner][operator];}
    function _operatorApprovals(address owner, address operator, bool approved) external{_getStorage(SLOT)._operatorApprovals[owner][operator] = approved;}
    function _spotMinted() external view returns(uint256){return _getStorage(SLOT)._spotMinted;}
    function _spotMintedIncr() external {uint256 _spotMinted = _getStorage(SLOT)._spotMinted; _getStorage(SLOT)._spotMinted = _spotMinted+1;}
    
    /// @dev геттеры
    function baseTokenURI() external view returns(string memory){return _getStorage(SLOT).baseTokenURI;}
    function defaultTokenURI() external view returns(string memory){return _getStorage(SLOT).defaultTokenURI;}
    function tokenURIs(uint256 tokenId) external view returns(string memory){return _getStorage(SLOT).tokenURIs[tokenId];}
    function ownedTokens(address owner, uint256 index) external view returns(uint256){return _getStorage(SLOT).ownedTokens[owner][index];}
    function ownedTokensIndex(uint256 tokenId) external view returns(uint256){return _getStorage(SLOT).ownedTokensIndex[tokenId];}
    function allTokens() external view returns(uint256[] memory){return _getStorage(SLOT).allTokens;}
    function genesislistRoot() external view returns(bytes32){return _getStorage(SLOT).genesislistRoot;}
    function legendlistRoot() external view returns(bytes32){return _getStorage(SLOT).legendlistRoot;}
    function epiclistRoot() external view returns(bytes32){return _getStorage(SLOT).epiclistRoot;}
    function fee() external view returns(uint256){return _getStorage(SLOT).fee;}
    function guaranteed_minted(address owner) external view returns(bool){return _getStorage(SLOT).guaranteed_minted[owner];}

    
    /// @dev Сеттеры
    function baseTokenURI(string memory _baseTokenURI) external{_getStorage(SLOT).baseTokenURI = _baseTokenURI;}
    function defaultTokenURI(string memory _defaultTokenURI) external{_getStorage(SLOT).defaultTokenURI = _defaultTokenURI;}
    function tokenURIs(string memory _tokenURIs, uint256 _tokenId) external{_getStorage(SLOT).tokenURIs[_tokenId] = _tokenURIs;}
    function ownedTokens(address _owner, uint256 _index, uint256 _tokenId) external{_getStorage(SLOT).ownedTokens[_owner][_index] = _tokenId;}
    function ownedTokensIndex(uint256 _tokenId, uint256 _index) external{_getStorage(SLOT).ownedTokensIndex[_tokenId] = _index;}
    function genesislistRoot(bytes32 _genesislistRoot) external{_getStorage(SLOT).genesislistRoot = _genesislistRoot;}
    function legendlistRoot(bytes32 _legendlistRoot) external{_getStorage(SLOT).legendlistRoot = _legendlistRoot;}
    function epiclistRoot(bytes32 _epiclistRoot) external{_getStorage(SLOT).epiclistRoot = _epiclistRoot;}
    function fee(uint256 _fee) external{_getStorage(SLOT).fee = _fee;}
    function guaranteed_minted(address _owner, bool _bool) external{_getStorage(SLOT).guaranteed_minted[_owner] = _bool;}
    
    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function removeTokenFromAllTokensEnumeration(uint256 tokenId) external {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).
    
        uint256 lastTokenIndex = _getStorage(SLOT).allTokens.length - 1;
        uint256 tokenIndex = _getStorage(SLOT).allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _getStorage(SLOT).allTokens[lastTokenIndex];

        _getStorage(SLOT).allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _getStorage(SLOT).allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _getStorage(SLOT).allTokensIndex[tokenId];
        _getStorage(SLOT).allTokens.pop();
    }
    
    /**
     * @dev Добавление токена в структуры для отслеживания
     * @param tokenId uint256 идентификатор токена
     */
    function addTokenToAllTokensEnumeration(uint256 tokenId) external {
        _getStorage(SLOT).allTokensIndex[tokenId] = _getStorage(SLOT).allTokens.length;
        _getStorage(SLOT).allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function removeTokenFromOwnerEnumeration(address from, uint256 tokenId, uint256 lastTokenIndex) external {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 tokenIndex = _getStorage(SLOT).ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _getStorage(SLOT).ownedTokens[from][lastTokenIndex];

            _getStorage(SLOT).ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _getStorage(SLOT).ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _getStorage(SLOT).ownedTokensIndex[tokenId];
        delete _getStorage(SLOT).ownedTokens[from][lastTokenIndex];
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function addTokenToOwnerEnumeration(address to, uint256 tokenId, uint256 length) external {
        _getStorage(SLOT).ownedTokens[to][length] = tokenId;
        _getStorage(SLOT).ownedTokensIndex[tokenId] = length;
    }
    
   
    /// @dev получение хранилища
    function _getStorage(bytes32 _storage) private pure returns (smeLegendaryStorage storage s){
        assembly{
            s.slot := _storage
        }
    }
}