/*作业请提交在这个目录下*/

pragma solidity ^0.4.14;

import './Ownable.sol';

contract Payroll is Ownable{
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    mapping(address => Employee) public employees;
    uint constant payDuration = 10 seconds;

    address owner;

    uint totalSalary;

    modifier employeeExist (address employeeId){
      var employee = employees[employeeId];
      assert(employee.id != 0x0);
      _;
    }

    function _partialPaid(Employee employee) private {
      uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
      employee.id.transfer(payment);
    }

    function _calculatePayment(Employee employee) private returns (uint){
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        return payment;
    }

    function addEmployee(address employeeId, uint salary) onlyOwner {

        var employee = employees[employeeId];

        assert(employee.id == 0x0);
        totalSalary +=salary * 1 ether;
        employees[employeeId] = (Employee(employeeId, salary, now));
    }

    function removeEmployee(address employeeId) public onlyOwner employeeExist(employeeId){
        var employee = employees[msg.sender];
        uint payment = _calculatePayment(employee);
        // 先付钱，再修改本地变量会有安全问题
        // _partialPaid(employee);

        totalSalary -= employees[employeeId].salary;
        // 重置为默认值
        delete employees[employeeId];
    }

    function updateEmployee(address employeeId, uint salary) public onlyOwner employeeExist(employeeId){

        var employee = employees[msg.sender];
        uint payment = _calculatePayment(employee);

        totalSalary += salary - employees[employeeId].salary;
        employees[employeeId].salary = salary;
        employees[employeeId].lastPayday = now;
        employeeId.transfer(payment);

    }

    function addFund() payable returns (uint) {
       return this.balance;
    }

    function calculateRunway() returns (uint) {
        return this.balance / totalSalary;
    }

    function hasEnoughFund() returns (bool) {
      return calculateRunway() > 0;
    }

    function getPaid() public employeeExist(msg.sender){
        var employee = employees[msg.sender];
        uint nextPayDay = employee.lastPayday + payDuration;
        assert(nextPayDay < now);
        employee.lastPayday = nextPayDay;
        employee.id.transfer(employee.salary);
    }

//  第二题：增加 changePaymentAddress 函数，更改员工的薪水支付地址
    function changePaymentAddress (address employeeId) public employeeExist(msg.sender) {
       var employee = employees[msg.sender];
       employees[employeeId] = (Employee(employeeId, employee.salary, employee.lastPayday));
       delete employees[msg.sender];

    }
}
