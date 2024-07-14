//SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

contract RandomNumber is VRFConsumerBaseV2, ConfirmedOwner{

event requestSent(uint ,uint);
event requestFulfilled(uint256, uint256[]);

// struct requestStatus{
//     bool fulfilled;//whether requestId fulfilled or not..
//     bool exists;//whether requestId exist or not..
//     uint[] randomWords;//The random words saves in this array....
// }

mapping(uint =>uint[]) public requestToRandom;
uint256[] randomResult;
uint256 lastRequestId;
bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15; //Key hash is the value to determine that from which chainlink oracle the data is being pulled..
uint32 numWords = 1;//No of random numbers generated..
uint16 minReqConfrm = 3 ;//The number of blocks, the oracle going to wait for fetching the VRF...
uint32 callbackGasLimit = 2500000;//The limit upto which the txn can gone in the worst case....
uint64 subscriptionId;//Subscription Id of the consumer address..
VRFCoordinatorV2Interface COORDINATOR;//The interface variable...

constructor(uint64 s_subscriptionId) VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D) ConfirmedOwner(msg.sender){
  COORDINATOR = VRFCoordinatorV2Interface(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D);
  subscriptionId = s_subscriptionId;
}

function requestRandomNum() external onlyOwner returns(uint256 requestId){
requestId = COORDINATOR.requestRandomWords
(keyHash,
 subscriptionId,
 minReqConfrm, 
 callbackGasLimit, 
 numWords);
lastRequestId = requestId;
requestToRandom[lastRequestId] = randomResult;
emit requestSent(lastRequestId, numWords);
return requestId;
}

function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomResult) internal override{
requestToRandom[_requestId] = _randomResult;
emit requestFulfilled(_requestId, _randomResult);
}

function retrieveRandom() public view returns(uint){
    return requestToRandom[lastRequestId][0];
}

}