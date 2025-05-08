// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Staking {
    IERC20 public token; // Token yang digunakan untuk staking
    uint256 public rewardRate = 100; // Contoh reward rate, bisa disesuaikan
    mapping(address => uint256) public stakes; // Menyimpan jumlah staking per address
    mapping(address => uint256) public rewards; // Menyimpan reward per address
    mapping(address => uint256) public lastStakedAt; // Menyimpan waktu staking terakhir

    // Event untuk staking
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor(IERC20 _token) {
        token = _token;
    }

    // Fungsi untuk melakukan staking
    function stake(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        token.transferFrom(msg.sender, address(this), _amount); // Transfer token ke kontrak
        stakes[msg.sender] += _amount;
        lastStakedAt[msg.sender] = block.timestamp; // Catat waktu staking
        emit Staked(msg.sender, _amount);
    }

    // Fungsi untuk menarik staking
    function unstake(uint256 _amount) external {
        require(stakes[msg.sender] >= _amount, "Not enough staked");
        stakes[msg.sender] -= _amount;
        token.transfer(msg.sender, _amount); // Kembalikan token kepada pengguna
        emit Unstaked(msg.sender, _amount);
    }

    // Fungsi untuk klaim reward
    function claimReward() external {
        uint256 reward = calculateReward(msg.sender);
        rewards[msg.sender] += reward;
        token.transfer(msg.sender, reward); // Transfer reward ke pengguna
        emit RewardClaimed(msg.sender, reward);
    }

    // Fungsi untuk menghitung reward berdasarkan staking dan waktu
    function calculateReward(address _user) public view returns (uint256) {
        uint256 stakedAmount = stakes[_user];
        uint256 stakingDuration = block.timestamp - lastStakedAt[_user];
        uint256 reward = stakedAmount * rewardRate * stakingDuration / (1 days); // Reward berdasarkan waktu staking
        return reward;
    }

    // Fungsi untuk melihat total staking
    function totalStaked() external view returns (uint256) {
        return stakes[msg.sender];
    }
}
