// SPDX-License-Identifier: MIT

/*///////////////////////////////////////////////////////////////////////////////////

   / __ )____  (_) /__  _________  / /___ _/ /____ 
  / __  / __ \/ / / _ \/ ___/ __ \/ / __ `/ __/ _ \
 / /_/ / /_/ / / /  __/ /  / /_/ / / /_/ / /_/  __/
/_____/\____/_/_/\___/_/  / .___/_/\__,_/\__/\___/ 
                         /_/                       
*////////////////////////////////////////////////////////////////////////////////////

// ARTWORK LICENSE: CC0
// No Roadmap, No Utility, 0% Royalties                                                                                 

pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";

contract NFTInvestrsClub is ERC721A, Ownable {

  address private constant TEAMWALLET = 0x49086328e44966dE791aC99353c203B039b63e51;
  string private baseURI;

  bool public started = false;
  bool public claimed = false;
  uint256 public constant MAXSUPPLY = 5210;
  uint256 public constant WALLETLIMIT = 4;
  uint256 public constant TEAMCLAIMAMOUNT = 210;

  mapping(address => uint) public addressClaimed;

  constructor() ERC721A("nftinvestrs", "NIC") {}

  // Start at token 1 instead of 0
  function _startTokenId() internal view virtual override returns (uint256) {
      return 1;
  }

  function mint(uint256 _count) external {
    uint256 total = totalSupply();
    uint256 minCount = 0;
    require(started, "Mint has not started yet");
    require(_count > minCount, "You need to mint at least one");
    require(total + _count <= MAXSUPPLY, "Mint out, no more NFTs left to mint");
    require(addressClaimed[_msgSender()] + _count <= WALLETLIMIT, "Wallet limit, you can't mint more than that");
    require(total <= MAXSUPPLY, "Mint out");
    // Flash Clone Clown
    addressClaimed[_msgSender()] += _count;
    _safeMint(msg.sender, _count);
  }

  function teamClaim() external onlyOwner {
    require(!claimed, "Team has already claimed");
    // Transfer tokens to the TEAMWALLET
    _safeMint(TEAMWALLET, TEAMCLAIMAMOUNT);
    claimed = true;
  }

  function setBaseURI(string memory baseURI_) external onlyOwner {
      baseURI = baseURI_;
  }

  function _baseURI() internal view virtual override returns (string memory) {
      return baseURI;
  }

  function startCircus(bool circusStarted) external onlyOwner {
      started = circusStarted;
  }
  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), 'There is no token with that ID');
    
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _toString(_tokenId), '.json'))
        : '';
  }
}
