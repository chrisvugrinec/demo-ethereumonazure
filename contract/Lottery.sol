pragma solidity ^0.4.0;
contract Lottery {

    uint nrOfPossibilities;
    uint priceMoney;
    bytes32[] private unsoldLotteryNumbers;
    bytes32[] private soldLotteryNumbers;

    function Lottery(uint8 _nrOfPossibilities, uint16 _priceMoney) {
        nrOfPossibilities = _nrOfPossibilities;
        priceMoney = _priceMoney;
        
        // Initialize the unsoldLotteryNumbers with unique Lotter numbers
        for (uint i=0; i<nrOfPossibilities; i++){
              unsoldLotteryNumbers.push( sha3(i,msg.sender)  );
        }      
    }

}
