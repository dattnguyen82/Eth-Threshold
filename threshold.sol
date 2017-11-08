pragma solidity ^0.4.11;

contract Threshold {

  struct Execution
  {
    address executionAddr;
    uint8 meter;
    bytes32 tag;
    bytes32 data;
  }

  uint8 public threshold;
  Execution[] public executions;
  Execution public currentExecution;

  function Threshold(bytes32[] tags, address[] executionAddresses, bytes32[] data, uint8 maxThreshold ) {
    threshold = maxThreshold;
    for ( uint i = 0; i<tags.length; i++ )
    {
      executions.push(Execution(executionAddresses[i], 0, tags[i], data[i]));
    }
  }

  function meterValue(bytes32 tag) public returns (uint8) {
    int idx = findExecution(tag);

    if (idx >= 0)
    {
      return executions[uint(idx)].meter;
    }

    revert();
  }

  function updateMeter(bytes32 tag, uint8 val) public {
    int idx = findExecution(tag);

    if (idx >= 0)
    {
      executions[uint(idx)].meter += val;
    }
    else
    {
      revert();
    }
  
    if (checkThreshold(idx)) {
      currentExecution = executions[uint(idx)];
      currentExecution.executionAddr.call(bytes32(keccak256("cb(bytes32)")), currentExecution.data);
    }
  }

  function currentThreshold() public returns (Execution)
  {
    return currentExecution;
  }

  function highest() public returns (Execution)
  {
    int max = 0;
    int idx = -1;
    for(uint i = 0; i < executions.length; i++) {
      if (executions[i].meter > max) {
        idx = int(i);
      }
    }
    
    if (idx >= 0)
    {
      return executions[uint(idx)];
    }
    else
    {
      revert();
    }
  }

  function checkThreshold(int idx) internal returns (bool) {
    return (executions[uint(idx)].meter >= threshold);
  }

  function findExecution(bytes32 tag) internal returns (int) {
    for( uint i = 0; i < executions.length; i++) {
      if (executions[i].tag == tag) {
        return int(i);
      }
    }
    return -1;
  }
}