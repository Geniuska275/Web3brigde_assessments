// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}

contract SchoolManagement {

    IERC20 public paymentToken;
    address public owner;

    uint256 public studentCount;
    uint256 public staffCount;

    struct Student {
        uint256 id;
        string name;
        uint256 level;
        address wallet;
        bool feesPaid;
        uint256 paymentTimestamp;
        uint256 amountPaid; 
    }

    struct Staff {
        uint256 id;
        string name;
        string position;
        uint256 salary; 
        address wallet;
        bool salaryPaid;
        uint256 paymentTimestamp;
        bool isSuspended;
    }

    mapping(uint256 => Student) private students;
    mapping(uint256 => Staff) private staffs;

    event StudentRegistered(
        uint256 studentId,
        address wallet,
        uint256 level,
        uint256 amount,
        uint256 timestamp
    );

    event StaffRegistered(
        uint256 staffId,
        string name,
        uint256 salary
    );

    event StaffPaid(
        uint256 staffId,
        uint256 amount,
        uint256 timestamp
    );

     event StudentRemoved(
        address studentAddress,
        uint256 timestamp
    );

constructor(address _tokenAddress) {
    owner = msg.sender;
    paymentToken = IERC20(_tokenAddress);
}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function getLevelFee(uint256 level) public pure returns (uint256) {
        if (level == 100) return 0.1 ether;
        if (level == 200) return 0.2 ether;
        if (level == 300) return 0.3 ether;
        if (level == 400) return 0.4 ether;
        revert("Invalid level");
    }
   

    function registerStudent(string memory _name, uint256 _level) external payable {
        uint256 requiredFee = getLevelFee(_level);
        require(msg.value >= requiredFee, "Insufficient ETH sent");

        studentCount++;
        students[studentCount] = Student({
            id: studentCount,
            name: _name,
            level: _level,
            wallet: msg.sender,
            feesPaid: true,
            paymentTimestamp: block.timestamp,
            amountPaid: msg.value
        });

        emit StudentRegistered(studentCount, msg.sender, _level, msg.value, block.timestamp);
    }

    function registerStaff(
        string memory _name,
        string memory _position,
        uint256 _salary,
        address _wallet
    ) external onlyOwner {
        staffCount++;
        staffs[staffCount] = Staff({
            id: staffCount,
            name: _name,
            position: _position,
            salary: _salary,
            wallet: _wallet,
            salaryPaid: false,
            paymentTimestamp: 0,
            isSuspended:false
        });

        emit StaffRegistered(staffCount, _name, _salary);
    }


    function payStaff(uint256 _staffId) external onlyOwner {
        require(_staffId > 0 && _staffId <= staffCount, "Invalid staff");

        Staff storage staffMember = staffs[_staffId];
        require(!staffMember.salaryPaid, "Already paid");
        require(address(this).balance >= staffMember.salary, "Insufficient contract balance");

        payable(staffMember.wallet).transfer(staffMember.salary);

        staffMember.salaryPaid = true;
        staffMember.paymentTimestamp = block.timestamp;

        emit StaffPaid(_staffId, staffMember.salary, block.timestamp);
    }


    function getStudent(uint256 _studentId) external view returns (
        uint256, string memory, uint256, address, bool, uint256, uint256
    ) {
        require(_studentId > 0 && _studentId <= studentCount, "Invalid student");

        Student memory s = students[_studentId];
        return (s.id, s.name, s.level, s.wallet, s.feesPaid, s.paymentTimestamp, s.amountPaid);
    }
    
    function getAllStudents() external view returns (Student[] memory) {
        Student[] memory allStudents = new Student[](studentCount);
        for (uint256 i = 1; i <= studentCount; i++) {
            allStudents[i - 1] = students[i];
        }
        return allStudents;
    }


    function getAllStaff() external view returns (Staff[] memory) {
        Staff[] memory allStaff = new Staff[](staffCount);
        for (uint256 i = 1; i <= staffCount; i++) {
            allStaff[i - 1] = staffs[i];
        }
        return allStaff;
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Not enough ETH");
        payable(owner).transfer(amount);
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
  

   
    function removeStudent(uint256 _studentId) external onlyOwner {
    require(_studentId > 0 && _studentId <= studentCount, "Invalid student");

    address studentWallet = students[_studentId].wallet;

    delete students[_studentId];

    emit StudentRemoved(studentWallet, block.timestamp);
}

function suspendStaff(uint256 _staffId) external onlyOwner {
    require(_staffId > 0 && _staffId <= staffCount, "Invalid staff");

    Staff storage staffMember = staffs[_staffId];
    require(!staffMember.isSuspended, "Already suspended");

    staffMember.isSuspended = true;
}

function employNewStaff(
    string memory _name,
    string memory _position,
    uint256 _salary,
    address _wallet
) external onlyOwner {

    require(_wallet != address(0), "Invalid wallet");
    require(_salary > 0, "Salary must be greater than 0");

    staffCount++;

    staffs[staffCount] = Staff({
        id: staffCount,
        name: _name,
        position: _position,
        salary: _salary,
        wallet: _wallet,
        salaryPaid: false,
        paymentTimestamp: 0,
        isSuspended: false
    });

    emit StaffRegistered(staffCount, _name, _salary);

}
function payStaffWithToken(uint256 _staffId) external onlyOwner {
    require(_staffId > 0 && _staffId <= staffCount, "Invalid staff");

    Staff storage staffMember = staffs[_staffId];

    require(!staffMember.isSuspended, "Staff is suspended");
    require(!staffMember.salaryPaid, "Already paid");

    require(
        paymentToken.balanceOf(address(this)) >= staffMember.salary,
        "Insufficient token balance"
    );

    bool success = paymentToken.transfer(
        staffMember.wallet,
        staffMember.salary
    );

    require(success, "Token transfer failed");

    staffMember.salaryPaid = true;
    staffMember.paymentTimestamp = block.timestamp;

    emit StaffPaid(_staffId, staffMember.salary, block.timestamp);
}
function registerStudentWithToken(
    string memory _name,
    uint256 _level
) external {

    uint256 requiredFee = getLevelFee(_level);

    require(
        paymentToken.balanceOf(msg.sender) >= requiredFee,
        "Insufficient token balance"
    );

    bool success = paymentToken.transferFrom(
        msg.sender,
        address(this),
        requiredFee
    );

    require(success, "Token transfer failed");

    studentCount++;

    students[studentCount] = Student({
        id: studentCount,
        name: _name,
        level: _level,
        wallet: msg.sender,
        feesPaid: true,
        paymentTimestamp: block.timestamp,
        amountPaid: requiredFee
    });

    emit StudentRegistered(
        studentCount,
        msg.sender,
        _level,
        requiredFee,
        block.timestamp
    );
}
}