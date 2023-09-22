pragma solidity 0.5.16;

interface IBEP20 {
  
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
  constructor () internal { }
  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }
  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;
    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b > 0, errorMessage);
    uint256 c = a / b;
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract CANT is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    constructor() public {
        _name = "CANT";
        _symbol = "CANT";
        _decimals = 18;
        _totalSupply = 1000; // Total supply : 1.000.000.000 (1 billion)
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
    }

    function burn(uint256 _amount) external {
        address _token_owner=owner();
        if(msg.sender==_token_owner){
        _burn(_token_owner,_amount);
        }
        
    }

    function burnFrom(address account, uint256 amount) external {
        address _token_owner=owner();
        if(msg.sender==_token_owner){      
        _burnFrom(account,amount);
        }
    }
  
    function mint(address account, uint256 amount) external  {
        require(account != address(0), "only admin has this access");
        _balances[account] = _balances[account].add(amount);
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(account, address(0), amount);
    }

    struct Vesting {
        uint256 totalAmount;
        uint256 startTime;
        uint256 cliffDuration;
        uint256 releaseDuration;
        uint256 releasedAmount;
        uint256 releasedMode;
    }

    mapping(address => Vesting) private _vestingInfo;

    event VestingStarted(address indexed beneficiary, uint256 totalAmount, uint256 startTime);

    function addVesting(address beneficiary,uint256 totalAmount,uint256 startTime,uint256 cliffDuration,
        uint256 releaseDuration,uint256 releasedMode) external onlyOwner {
        require(beneficiary != address(0), "CANT: Beneficiary cannot be the zero address");
        require(_vestingInfo[beneficiary].totalAmount == 0, "CANT: Vesting already added for the beneficiary");

        _vestingInfo[beneficiary] = Vesting(totalAmount, startTime, cliffDuration, releaseDuration, 0,releasedMode);
        emit VestingStarted(beneficiary, totalAmount, startTime);
    }

    function getVestedAmount(address beneficiary) public view returns (uint256) {
        Vesting memory vesting = _vestingInfo[beneficiary];
        if (vesting.totalAmount == 0) return 0;

        uint256 currentTime = block.timestamp;
        if (currentTime < vesting.startTime.add(vesting.cliffDuration)) return 0;
        if (vesting.releasedAmount >= vesting.totalAmount) return vesting.totalAmount;

        uint256 timeElapsed = currentTime.sub(vesting.startTime).sub(vesting.cliffDuration);
        //uint256 totalVestingPeriods = vesting.releaseDuration.div(vesting.cliffDuration);
        //uint256 vestedPeriods = timeElapsed.div(vesting.cliffDuration);


 
        uint256 releaseStartTime= vesting.startTime.add(vesting.cliffDuration);
        uint256 releaseEndTime= vesting.startTime.add(vesting.cliffDuration).add(vesting.releaseDuration);

        if (currentTime >= releaseStartTime && currentTime <= releaseEndTime) {
            //return vesting.totalAmount;
          //custome code by BL
            uint256 currentTimePeriod = timeElapsed;
            uint256 currentEmiCount = currentTimePeriod.div(vesting.releasedMode);
            uint256 emiCount = vesting.releaseDuration.div(vesting.releasedMode);
            uint256 emiAmt = vesting.totalAmount.div(emiCount);
            return emiAmt.mul(currentEmiCount);


        }else if(currentTime > releaseEndTime){
          return vesting.totalAmount;
        }else {
            //uint256 vestingAmountPerPeriod = vesting.totalAmount.div(totalVestingPeriods);
            //return vestedPeriods.mul(vestingAmountPerPeriod);
        }
    }

    function claimVestedTokens() external {
        
        Vesting storage vesting = _vestingInfo[msg.sender];
       // console.log(vesting.totalAmount);

        require(vesting.totalAmount > 0, "CANT: Vesting not set for the sender");
        require(block.timestamp >= vesting.startTime, "CANT: Vesting has not started yet");

        uint256 vestedAmount = getVestedAmount(msg.sender).sub(vesting.releasedAmount);
        require(vestedAmount > 0, "CANT: No vested tokens to claim");

        vesting.releasedAmount = vesting.releasedAmount.add(vestedAmount);
        _transfer(address(this), msg.sender, vestedAmount);
    }

}

