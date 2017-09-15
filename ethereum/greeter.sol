pragma solidity ^0.4.13;

contract greeter {

    string greeting;

    function greeter(string _greeting) public {
        greeting = _greeting;
    }

    function setGreeting(string _greeting) public {
        greeting = _greeting;
    }
    
    function greet() constant returns (string){
        return greeting;
    }

    function calcProof(string _someString) constant returns (bytes32){
        return sha256(_someString);
    }

}
