pragma solidity ^ 0.6.0;

contract Bank {
    address payable public owner;
    mapping(string => address) public addressData;
    string[] usersList;
    mapping(address => uint) public moneyData;
    uint asset;


    constructor() public payable {
        owner = msg.sender;
    }


    // tool 0
    function getUserCount() external view returns(uint256) {
        return usersList.length;
    }

    // tool 1
    function isEnrolled(address input) public view returns(bool) {
        for (uint i = 0; i < usersList.length; i++) {
            address check = addressData[usersList[i]];
            if (check == input) {
                return true;
            }
        }
        return false;
    }

    // tool 2
    function isValidId(string memory studentId) public pure returns(bool) {
        if (keccak256(abi.encodePacked(studentId)) != keccak256(abi.encodePacked(''))) {
            return true;
        } else {
            return false;
        }
    }

    function isUniqueId(string memory studentId) public view returns(bool) {
        for (uint i = 0; i < usersList.length; i++) {
            string memory check = usersList[i];
            if (keccak256(abi.encodePacked(studentId)) == keccak256(abi.encodePacked(check))) {
                return false;
            }
        }
        return true;
    }


    // 註冊
    function enroll(string memory studentId) public returns(string memory) {

        if (isEnrolled(msg.sender)) {
            revert('這個 Account 好像已經註冊過囉!');
        } else {
            if (isValidId(studentId) && isUniqueId(studentId)) {
                addressData[studentId] = msg.sender;
                usersList.push(studentId);
                return '註冊成功';
            } else {
                revert('id 不合法或此 id 已被註冊!');
            }
        }

    }


    event depositEvent(address depoAddress, uint depoAmount);

    // 存錢
    function deposit() public payable returns(uint) {
        if (isEnrolled(msg.sender)) {
            if (msg.value >= 1 wei) {
                moneyData[msg.sender] += msg.value;
                asset += msg.value;
                
                emit depositEvent(msg.sender, msg.value);
                
                return getBalance();
            } else {
                revert('請至少存入 1 wei.');
            }
        } else {
            revert('請先註冊喔~');
        }
    }

    // 銀行資產查詢
    function getBankBalance() public view returns(uint) {
        require(msg.sender == owner, '你不是銀行老闆，不跟你說 > <');
        return asset;
    }

    // 餘額查詢
    function getBalance() public view returns(uint) {
        if(isEnrolled(msg.sender)){
            return moneyData[msg.sender];
        }else{
            revert('請先註冊喔~');
        }
    }

    // 提錢
    function withdraw(uint withdrawAmount) public payable returns(uint) {
        if (getBalance() != 0) {
            if (withdrawAmount <= getBalance()) {
                moneyData[msg.sender] -= withdrawAmount;
                asset -= withdrawAmount;
                return getBalance();
            } else {
                revert('你好像沒那麼多錢喔~');
            }
        } else {
            revert('你的銀行帳戶餘額為 0');
        }
    }

    // 轉帳
    function transfer(uint transferAmount, address payable transferTo) public payable returns(uint) {
        if (getBalance() != 0) {
            if(isEnrolled(transferTo)){
                if (transferAmount <= getBalance()) {
                    moneyData[transferTo] += transferAmount;
                    moneyData[msg.sender] -= transferAmount;
                    return getBalance();
                } else {
                    revert('你好像沒那麼多錢喔~');
                }
            }else{
                revert('您要轉帳的對象並非本行會員喔~');
            }
        } else {
            revert('你的戶頭目前沒半毛錢喔.');
        }
    }


    fallback() external {
        require(msg.sender == owner, '你不是銀行老闆，想幹嘛?');
        selfdestruct(owner);
    }
    


}
