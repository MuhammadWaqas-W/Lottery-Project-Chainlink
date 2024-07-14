//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;
interface IRandom{
  function retrieveRandom() external returns(uint);
}
contract Lottery { 

    struct Participant{
    address payable participantAddr;
    uint noOfLotts;
    uint etherPaid;
    }

    uint randNum;
    address contractAddress;
    address public manager;
    address[] public participants;
    address payable winnerAddr;
    mapping(address=>Participant) public participantList;
    
    modifier isManager(){
      require(msg.sender == manager);
      _;
    }
   
    constructor(address _contractAddress){
      manager = msg.sender;
      contractAddress = _contractAddress;
    }
  
    function participate() external{
      // require(msg.value == 1000 gwei,"The amount must be 1 Ether");
      require(msg.sender != manager,"The manager is not allowed...");
      if(participantList[msg.sender].participantAddr == address(0)){//kinda like mapping iteration
      participantList[msg.sender] = Participant(payable(msg.sender),1,2);
      participants.push(msg.sender);
    }
    else{
      participantList[msg.sender].noOfLotts++;
      participantList[msg.sender].etherPaid+=2;
    }
    }
    // function random() private view returns(uint){
    //   bytes32 randomChar = keccak256(abi.encodePacked(block.difficulty, block.gaslimit, block.timestamp));
    //   uint randNum = uint(randomChar);
    //   return randNum%participants.length;
    //}
    function random() private returns(uint){
      uint randomChar = IRandom(contractAddress).retrieveRandom();
      randNum = randomChar%participants.length;
      return randNum;
    }
    function selectWinner() public  isManager{
      require(participants.length>=5);
      random();
      // address contractAddr = address(this);
      uint randomWin = randNum;
      winnerAddr = payable(participants[randomWin]);
    //  winnerAddr.transfer(contractAddr.balance);
    }
    function retrieveWinner() public view returns(address){
      return winnerAddr;
    }
    function reset() public isManager{
      participants = new address [](0);

    }
    
}