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
    uint timesDrawn;
    WinningLotteryClient[] winners;

    struct LotteryClient {
        string name;
        uint lotteryNumber;
    }

    struct WinningLotteryClient {
        string name;
        uint ticketNr;
        uint price;
    }

    uint[] private unsoldLotteryNumbers;
    LotteryClient[] private soldLotteryNumbers;

    function SimpleLottery(uint _nrOfTickets, uint _priceMoney) {
        nrOfTickets = _nrOfTickets;
        priceMoney = _priceMoney;
        ticketsSold = 0;
        timesDrawn = 0;
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
            logTicketBuy(_name," has bought a ticket with lotteryticketnr: ",ticketNumber);
            ticketsSold++;
        }
    }

    function getWinner() {
        //  Only draw when all tickets are sold and no winner yet
        //  uint ticketsLeft = nrOfTickets-ticketsSold;
        if( !lotteryWon  &&
            (soldLotteryNumbers.length == nrOfTickets)
        ){

            // Draw lucky winner:
            uint winningNumber = randomLotteryNumber(ticketsSold);

            //  Iterate over all users until winningNumber is
            //  owned by 1 or more users
            for(uint i=0; i<soldLotteryNumbers.length; i++){

                //  If user has winning number add to tmpArray of winningNames
                //  Contratz
                if(soldLotteryNumbers[i].lotteryNumber == winningNumber){
                    
                    logWinMessage("we have a winner for this ticketNumber ",winningNumber);
                    winners.push(WinningLotteryClient(soldLotteryNumbers[i].name, soldLotteryNumbers[i].lotteryNumber,priceMoney));
                    lotteryWon=true;
                }
            }
            if( lotteryWon ){
                //  Divide price and change state
                uint nrOfWinners = winners.length;
                uint price = priceMoney/nrOfWinners;
                for(uint j=0; j<nrOfWinners; j++){
                    logWinnerMessage(winners[j].name," wins pricemoney ",price, " with ticketnr: ", winners[j].ticketNr);
                }
            }else{
                timesDrawn++;
                logNobodyWinsMessage("Redraw needed: nobody has this winning ticketnr, :", winningNumber, " times drawn: ",timesDrawn);
            }
        }
    }
    
    event logTicketBuy(string message, string message2, uint ticketNr);
    event logNobodyWinsMessage(string message, uint ticketNr,string message2, uint timesDrawnNr);
    event logWinMessage(string message, uint ticketNr);
    event logWinnerMessage(string message, string submessage, uint price, string submessage2, uint ticketNr);
    
    // note: solidity accessor types:
    // public - all
    // private - only this contract
    // internal - only this contract and contracts deriving from it
    // external - Cannot be accessed internally, only externally
    function randomLotteryNumber(uint seed) private returns (uint randomNumber) {
        uint result = (uint(sha3(block.blockhash(block.number-1), seed ))%10);
        return result;
    }

}


