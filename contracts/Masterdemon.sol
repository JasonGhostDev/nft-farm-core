pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

//TODO reward system
//TODO reward token
//TODO rarity calculator


contract Masterdemon is Ownable {
    using SafeMath for uint256;
    using Address for address;

    struct NftInfo {
        uint256 rarity; // rarity to calculate reward minting strategy
        uint256 stakeFee; // entry fee (might be 0)
        uint256 withdrawFee; // exit fee (might be 0)
        uint256 booster; // each nft will have rewards booster
    }

    struct UserInfo {
        uint256 amountStaked; // how many nfts did user staked
    }

    /// @notice id => each nft
    mapping(uint256 => NftInfo) public nftInfo;

    /// @notice address => each user
    mapping(address => UserInfo) public userInfo;

    /// @notice cryptodemonz v1 official address
    address public demonz = 0xAE16529eD90FAfc927D774Ea7bE1b95D826664E3;

    /// @notice fee for staking
    uint256 stakingFee = 0.06 ether;

    /// @notice fee for withdrawing 
    uint256 withdrawFee = 0.08 ether;

    event UserStaked(uint256 amount, address staker);
    //TODO amount
    event UserUnstaked(address unstaker);

     // ------------------------ PUBLIC ------------------------ //

    /// @notice stake multiple tokens at same time
    /// @param _id array of tokens user wants to stake at same time
    function StakeNFT(uint256[] memory _id) public payable {
        require(msg.value >= stakingFee, "ERR: FEE NOT COVERED");

        uint256 amount = 0;
        for (uint256 i; i<=_id.length; ++i) {
            require(IERC721(demonz).ownerOf(_id[i]) == address(msg.sender), "ERR: YOU DONT OWN THESE TOKENS");
            IERC721(demonz).safeTransferFrom(msg.sender, address(this), _id[i]);

            amount += 1;

            nftInfo[_id[i]] = NftInfo(0, 0, 0, 0); //TODO test
            userInfo[msg.sender] = UserInfo(amount);
        }

        emit UserStaked(amount, msg.sender);
        //TODO check for more cases 
        //TODO replace amount with something better
    }

    /// @notice unstake NFT, no rewards given here!
    /// @param _id array fo tokens user wants to unstake at same time
    function UnstakeNFT(uint256[] memory _id) public payable {
        require(msg.value >= withdrawFee, "ERR: FEE NOT COVERED");

        for (uint256 i; i<=_id.length; ++i) {
         
            require(IERC721(demonz).ownerOf(_id[i]) == address(msg.sender), "ERR: YOU DONT OWN THESE TOKENS");

            IERC721(demonz).safeTransferFrom(address(this), msg.sender, _id[i]);
            delete nftInfo[_id[i]]; //TODO test
        }

        emit UserUnstaked(msg.sender);
        //TODO update user info as well
        //TODO add more require checks
    }

    // ------------------------ DEV ------------------------ //

    function changeStakingFee(uint256 _staking) public onlyOwner() {
        require(stakingFee != _staking, "DEV_ERR: VALUE ALREADY SET");
        stakingFee = _staking;
    }

    function changeUnstakingFee(uint256 _unstaking) public onlyOwner() {
        require(withdrawFee != _unstaking, "DEV_ERR: VALUE ALREADY SET");
        withdrawFee = _unstaking;
    }

    function changeDemonzAddress(address _newAddress) public onlyOwner() {
        require(demonz != _newAddress, "DEV_ERR: ADDRESS ALREADY SET");
        demonz = _newAddress;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }
}