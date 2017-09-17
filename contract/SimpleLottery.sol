pragma solidity ^0.4.0;

contract SimpleLottery {

    /*  
        This Lottery example is not linked to a wallet
        buy a ticket with your name and a number is drawn
        no wallets or whatsoever are used here
    */  

    uint nrOfTickets;
    uint priceMoney;
    uint ticketsSold;
    bytes32 test;
    bool lotteryWon;
    WinningLotteryClient[] winners;
    
    struct LotteryClient { 
        string name;
        uint lotteryNumber;
    }

    struct WinningLotteryClient { 
        string name;
        uint price;
    }
    
    uint[] private unsoldLotteryNumbers;
    LotteryClient[] private soldLotteryNumbers;
    
    function SimpleLottery(uint _nrOfTickets, uint _priceMoney) {
        nrOfTickets = _nrOfTickets;
        priceMoney = _priceMoney;
        ticketsSold = 0;
        lotteryWon = false;

        // Initialize the unsoldLotteryNumbers with a Lottery Number
        for (uint i=1; i<nrOfTickets+1; i++){
              unsoldLotteryNumbers.push( randomLotteryNumber(i) );
        }      
    }

    function buyTicket(string _name){
        // Dont sell tickets if you have none left :)
        if(ticketsSold < nrOfTickets){
            uint ticketNumber = unsoldLotteryNumbers[ticketsSold];
            delete unsoldLotteryNumbers[ticketsSold];
            //test = block.blockhash(block.number);
            soldLotteryNumbers.push( LotteryClient(_name, ticketNumber));
            ticketsSold++;
        }
    }


    function getWinner() {
        //  Only draw when all tickets are sold and no winner yet
        //  uint ticketsLeft = nrOfTickets-ticketsSold;
        if(!lotteryWon){

            if(soldLotteryNumbers.length == nrOfTickets){
                
                string [] winningNames;
                
                while(!lotteryWon){

                    // Draw lucky winner:
                    uint winningNumber = randomLotteryNumber(ticketsSold);
                    
                    //  Iterate over all users until winningNumber is 
                    //  owned by 1 or more users
                    for(uint i=0; i<soldLotteryNumbers.length; i++){
                        
                        //  If user has winning number add to tmpArray of winningNames
                        //  Contratz
                        if(soldLotteryNumbers[i].lotteryNumber == winningNumber){
                            winningNames.push(soldLotteryNumbers[i].name);
                            lotteryWon=true;
                        }
                    }
                    //  If after iteration of solTickets no one has won...
                    //  generate new winningTicktetNumber, else divide price
                    if( winningNames.length>0){
                        //  Divide price and change state
                        uint nrOfWinners = winningNames.length;
                        uint price = priceMoney/nrOfWinners;
                        for(uint j=0; j<nrOfWinners; j++){
                            winners.push(WinningLotteryClient(winningNames[j],price));
                        }
                    }
                }
            }
        }
        
    }

    // note: solidity accessor types: 
    // public - all
    // private - only this contract
    // internal - only this contract and contracts deriving from it
    // external - Cannot be accessed internally, only externally
    function randomLotteryNumber(uint seed) private returns (uint randomNumber) {
        uint result = (uint(sha3(block.blockhash(block.number-1), seed ))%100);
        return result;
    }

}

