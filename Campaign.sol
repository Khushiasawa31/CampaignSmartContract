pragma solidity ^0.4.17;

contract Campaign{
    
    struct Request{
        string description;
        uint value;
        address vendor;
        bool complete;
        uint approvalCount;
        mapping(address=>bool) approvals;
    }
    
    address public manager;
    uint public minimumContribution;
    mapping(address=> bool) approvers;
    Request[] public requests;
    uint public approversCount;
    
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    function Campaign(uint _min) public{
        manager=msg.sender;
        minimumContribution= _min;
        approversCount=0;
    }
    
    function contribute() public payable{
        require(msg.value >= minimumContribution);
        
        approvers[msg.sender]=true;
        approversCount++;
    }
    
    function createRequest(string _description, uint _value, address _vendor) public restricted{
        Request memory newRequest= Request({
            description: _description,
            value: _value,
            vendor: _vendor,
            complete: false,
            approvalCount: 0
        });
        
        requests.push(newRequest);
    }

    function approveRequests(uint index) public {
        Request storage request= requests[index]; 
        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);
        request.approvals[msg.sender]= true;
        request.approvalCount++;
        
    }
    
    function finalizeRequest(uint index) public restricted returns(bool){
        Request storage request= requests[index]; 
        require(request.approvalCount > (approversCount/2));
        require(!request.complete);
        request.complete=true;
        request.vendor.transfer(request.value);
        
    }
    
}