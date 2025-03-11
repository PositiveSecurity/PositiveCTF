// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./KhinkalToken.sol";

// MainChef is the master of Khinkal. He can make Khinkal and he is a fair guy.
//
// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once KHINKAL is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract MainChef is Ownable {
    using SafeERC20 for IERC20;
    // Info of each user.

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
            //
            // We do some fancy math here. Basically, any point in time, the amount of KHINKALs
            // entitled to a user but is pending to be distributed is:
            //
            //   pending reward = (user.amount * pool.accKhinkalPerShare) - user.rewardDebt
            //
            // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
            //   1. The pool's `accKhinkalPerShare` (and `lastRewardBlock`) gets updated.
            //   2. User receives the pending reward sent to his/her address.
            //   3. User's `amount` gets updated.
            //   4. User's `rewardDebt` gets updated.
    }
    // Info of each pool.

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. KHINKALs to distribute per block.
        uint256 lastRewardBlock; // Last block number that KHINKALs distribution occurs.
        uint256 accKhinkalPerShare; // Accumulated KHINKALs per share, times 1e12. See below.
        uint256 lastKhinkalReward; // Protection against incorrect tokenomics
    }
    // The KHINKAL TOKEN!

    KhinkalToken public khinkal;
    // Dev address.
    address public devaddr;
    // Governance address.
    address public governance;
    // Block number when bonus KHINKAL period ends.
    uint256 public bonusEndBlock;
    // KHINKAL tokens created per block.
    uint256 public khinkalPerBlock;
    // Bonus muliplier for early khinkal makers.
    uint256 public constant BONUS_MULTIPLIER = 10;
    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when KHINKAL mining starts.
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        KhinkalToken _khinkal,
        address _devaddr,
        uint256 _khinkalPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        address _governance
    ) Ownable(msg.sender) {
        khinkal = _khinkal;
        devaddr = _devaddr;
        khinkalPerBlock = _khinkalPerBlock;
        bonusEndBlock = _bonusEndBlock;
        startBlock = _startBlock;
        governance = _governance;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        _add(_allocPoint, _lpToken, _withUpdate);
    }

    // Add a new lp with the default allocation points value to the pool.
    function addToken(IERC20 _lpToken) public {
        require(msg.sender == owner() || msg.sender == governance, "Access denied");
        _add(1, _lpToken, true);
    }

    function _add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) internal {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint + _allocPoint;
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accKhinkalPerShare: 0,
                lastKhinkalReward: 0
            })
        );
    }

    // Update the given pool's KHINKAL allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        // totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        totalAllocPoint = totalAllocPoint - poolInfo[_pid].allocPoint + _allocPoint;
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return (_to - _from) * BONUS_MULTIPLIER;
        } else if (_from >= bonusEndBlock) {
            return _to - _from;
        } else {
            return ((bonusEndBlock - _from) * BONUS_MULTIPLIER) + (_to - bonusEndBlock);
        }
    }

    // View function to see pending KHINKALs on frontend.
    function pendingKhinkal(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accKhinkalPerShare = pool.accKhinkalPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);

            uint256 khinkalReward = multiplier * khinkalPerBlock * pool.allocPoint / totalAllocPoint;
            accKhinkalPerShare = accKhinkalPerShare + (khinkalReward * 1e12 / lpSupply);
        }
        return user.amount * accKhinkalPerShare / 1e12 - user.rewardDebt;
    }

    // Update reward vairables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 khinkalReward = multiplier * khinkalPerBlock * pool.allocPoint / totalAllocPoint;
        khinkal.mint(devaddr, khinkalReward / 10);
        khinkal.mint(address(this), khinkalReward);
        pool.accKhinkalPerShare = pool.accKhinkalPerShare + (khinkalReward * 1e12 / lpSupply);
        pool.lastKhinkalReward = khinkalReward;
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to MainChef for KHINKAL allocation.
    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            // uint256 pending = user.amount.mul(pool.accKhinkalPerShare).div(1e12).sub(user.rewardDebt);
            uint256 pending = (user.amount * pool.accKhinkalPerShare / 1e12) - user.rewardDebt;
            require(pending <= pool.lastKhinkalReward, "Reward bigger than minted");
            if (pending > 0) {
                khinkal.transfer(msg.sender, pending);
            }
            khinkal.transfer(msg.sender, pending);
        }
        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount + _amount;
        user.rewardDebt = user.amount * pool.accKhinkalPerShare / 1e12;
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from MainChef.
    function withdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending = (user.amount * pool.accKhinkalPerShare / 1e12) - user.rewardDebt;
        require(pending <= pool.lastKhinkalReward, "Reward bigger than minted");
        if (pending > 0) {
            khinkal.transfer(msg.sender, pending);
        }
        if (user.amount > 0) {
            pool.lpToken.safeTransfer(address(msg.sender), user.amount);
            user.amount = 0;
            user.rewardDebt = user.amount * pool.accKhinkalPerShare / 1e12;
        }
        emit Withdraw(msg.sender, _pid, user.amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    // Update governance address by the governance.
    function setGovernance(address _governance) public {
        require(msg.sender == owner() || msg.sender == _governance, "Access denied");
        governance = _governance;
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == owner() || msg.sender == devaddr, "Access denied");
        devaddr = _devaddr;
    }
}
