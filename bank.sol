// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;


contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        name = "Enkay_Tokens";
        symbol = "ENT";
        decimals = 18;
        totalSupply = 1000000 * uint256(decimals);
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(balances[_from] >= _value, "Insufficient balance");
        require(allowed[_from][msg.sender] >= _value, "Insufficient allowance");
        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}

contract Bank {
    // Mapping of user address to record
    mapping (address => uint256) public records;

    // Mapping of addresses to owners
    mapping (address => uint256) public owners;

    // Creating an instance of MyToken
    MyToken public token;

    // Event emitted for deposit
    event Deposit(address indexed account, uint256 amount);

    // Event emitted for withdrawal
    event Withdrawal(address indexed account, uint256 amount);

    // Declaring minimumDeposit and maxWithdrawal
    uint256 public minDeposit;
    uint256 public maxWithdrawal;

    constructor() {
        token = new MyToken();

        // Minimum and maximum deposit limit
        minDeposit = 10 * 18;
        maxWithdrawal = 1000 * 18;
    }

    function deposit(address account, uint256 amount) public {
        // Check if the account exists
        require(owners[account] != 0, "Address does not exist");

        require(token.balanceOf(msg.sender) >= amount, "Insufficient balance!");

        require(amount >= minDeposit, "Deposit limit not reached");

        // Transfer tokens from user to bank
        token.transferFrom(msg.sender, address(this), amount);

        // Update user's record
        records[account] += amount;

        emit Deposit(account, amount);
    }

    function withdrawal(address account, uint256 amount) public {
        require(owners[account] != 0, "Address does not exist");

        require(records[account] >= amount, "Insufficient balance!");

        require(amount <= maxWithdrawal , "Withdrawal limit!");

        // Transfer tokens from bank to user
        token.transfer(msg.sender, amount);

        // Update user's record
        records[account] -= amount;

        emit Withdrawal(account, amount);
    }

    // Function to add a new owner
    function addOwner(address _owner) public {
        owners[_owner] = 1;
    }

    // Function to remove an owner
    function removeOwner(address _owner) public {
        owners[_owner] = 0;
    }
}

