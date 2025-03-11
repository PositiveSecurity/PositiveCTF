// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./SafeMath.sol";
import "./P2P_WETH.sol";
import "./TransferHelper.sol";

interface IP2P_WETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
    function balanceOf(address) external returns (uint256);
    function approve(address, uint256) external returns (bool);
}

contract P2PSwapper {
    using SafeMath for uint256;

    struct Deal {
        address initiator;
        address bidToken;
        uint256 bidPrice;
        address askToken;
        uint256 askAmount;
        uint256 status;
    }

    enum DealState {
        Active,
        Succeeded,
        Canceled,
        Withdrawn
    }

    event NewUser(address user, uint256 id, uint256 partnerId);
    event WithdrawFees(address partner, uint256 userId, uint256 amount);
    event NewDeal(address bidToken, uint256 bidPrice, address askToken, uint256 askAmount, uint256 dealId);
    event TakeDeal(uint256 dealId, address bidder);
    event CancelDeal(uint256 dealId);

    uint256 public dealCount;
    mapping(uint256 => Deal) public deals;
    mapping(address => uint256[]) private _dealHistory;

    uint256 public userCount;
    mapping(uint256 => uint256) public partnerFees;
    mapping(address => uint256) public distributedFees;
    mapping(uint256 => uint256) public partnerById;
    mapping(address => uint256) public userByAddress;
    mapping(uint256 => address) public addressById;

    IP2P_WETH public immutable p2pweth;

    constructor(address weth) {
        p2pweth = IP2P_WETH(weth);

        userByAddress[msg.sender] = 1;
        addressById[1] = msg.sender;
        partnerById[1] = 1;
    }

    bool private entered = false;

    modifier nonReentrant() {
        require(entered == false, "P2PSwapper: re-entrancy detected!");
        entered = true;
        _;
        entered = false;
    }

    function createDeal(address bidToken, uint256 bidPrice, address askToken, uint256 askAmount)
        external
        payable
        returns (uint256 dealId)
    {
        uint256 fee = msg.value;
        require(fee > 31337, "P2PSwapper: fee too low");
        p2pweth.deposit{value: msg.value}();
        partnerFees[userByAddress[msg.sender]] = partnerFees[userByAddress[msg.sender]].add(fee.div(2));

        TransferHelper.safeTransferFrom(bidToken, msg.sender, address(this), bidPrice);
        dealId = _createDeal(bidToken, bidPrice, askToken, askAmount);
    }

    function takeDeal(uint256 dealId) external nonReentrant {
        require(dealCount >= dealId && dealId > 0, "P2PSwapper: deal not found");

        Deal storage deal = deals[dealId];
        require(deal.status == 0, "P2PSwapper: deal not available");

        TransferHelper.safeTransferFrom(deal.askToken, msg.sender, deal.initiator, deal.askAmount);
        _takeDeal(dealId);
    }

    function cancelDeal(uint256 dealId) external nonReentrant {
        require(dealCount >= dealId && dealId > 0, "P2PSwapper: deal not found");

        Deal storage deal = deals[dealId];
        require(deal.initiator == msg.sender, "P2PSwapper: access denied");

        TransferHelper.safeTransfer(deal.bidToken, msg.sender, deal.bidPrice);

        deal.status = 2;
        emit CancelDeal(dealId);
    }

    function status(uint256 dealId) public view returns (DealState) {
        require(dealCount >= dealId && dealId > 0, "P2PSwapper: deal not found");
        Deal storage deal = deals[dealId];
        if (deal.status == 1) {
            return DealState.Succeeded;
        } else if (deal.status == 2 || deal.status == 3) {
            return DealState(deal.status);
        } else {
            return DealState.Active;
        }
    }

    function dealHistory(address user) public view returns (uint256[] memory) {
        return _dealHistory[user];
    }

    function signup() public returns (uint256) {
        return signup(1);
    }

    function signup(uint256 partnerId) public returns (uint256 id) {
        require(userByAddress[msg.sender] == 0, "P2PSwapper: user exists");
        require(addressById[partnerId] != address(0), "P2PSwapper: partner not found");

        id = ++userCount;
        userByAddress[msg.sender] = id;
        addressById[id] = msg.sender;
        partnerById[id] = partnerId;

        emit NewUser(msg.sender, id, partnerId);
    }

    function withdrawFees(address user) public nonReentrant returns (uint256 fees) {
        uint256 userId = userByAddress[user];
        require(partnerById[userId] == userByAddress[msg.sender], "P2PSwapper: user is not your referral");

        fees = partnerFees[userId].sub(distributedFees[user]);
        require(fees > 0, "P2PSwapper: no fees to distribute");

        distributedFees[user] = distributedFees[user].add(fees);
        p2pweth.withdraw(fees);
        TransferHelper.safeTransferETH(msg.sender, fees);

        emit WithdrawFees(msg.sender, userId, fees);
    }

    function _createDeal(address bidToken, uint256 bidPrice, address askToken, uint256 askAmount)
        private
        returns (uint256 dealId)
    {
        require(askToken != address(0), "P2PSwapper: invalid address");
        require(bidPrice > 0, "P2PSwapper: invalid bid price");
        require(askAmount > 0, "P2PSwapper: invalid ask amount");
        dealId = ++dealCount;
        Deal storage deal = deals[dealId];
        deal.initiator = msg.sender;
        deal.bidToken = bidToken;
        deal.bidPrice = bidPrice;
        deal.askToken = askToken;
        deal.askAmount = askAmount;

        _dealHistory[msg.sender].push(dealId);

        emit NewDeal(bidToken, bidPrice, askToken, askAmount, dealId);
    }

    function _takeDeal(uint256 dealId) private {
        Deal storage deal = deals[dealId];

        TransferHelper.safeTransfer(deal.bidToken, msg.sender, deal.bidPrice);

        deal.status = 1;
        emit TakeDeal(dealId, msg.sender);
    }

    receive() external payable {
        require(msg.sender == address(p2pweth), "P2PSwapper: transfer not allowed");
    }
}
