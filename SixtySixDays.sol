pragma solidity >=0.5.0 <0.6.0;
//@title A smart contract to deposit ether and only be able to return it after 66 days
//@author cmn721
contract SixtySixDays {
    //@notice defines the pledge object
    struct pledge {
        uint endTime;
        uint amount;
        bool returned;
    }

    pledge[] pledges;

    mapping(uint => address) idToAddress;
    mapping(address => uint64) addressPledgeCount;

    //@notice creates new pledge and records the owner of the pledge
    function createNewPledge() public payable {
     //@dev added requirement that ether be deposited
        require(msg.value > 0, 'You must deposit some ETH');
        uint id = pledges.push(pledge(now + 180, msg.value, false)) - 1;
        idToAddress[id] = msg.sender;
        addressPledgeCount[msg.sender]++;
    }
    //@notice ensures only the person who instigated the pledge can reset progress or withdraw their deposit
    modifier onlyOwner(uint _id) {
        require(msg.sender == idToAddress[_id], 'You are not authorised to view this');
        _;
   }
    //@notice function resets the pledge so 66 days have to elapse from when added
    function resetPledgeTimer(uint _id) public onlyOwner(_id) {
        require(pledges[_id].returned == false, 'You have already collected your ETH!');
        pledges[_id].endTime = now + 180;
    }
    //@notice function returns the deposit if 66 days has passed
    function returnDeposit(uint _id) public onlyOwner(_id) {
        require(pledges[_id].endTime < now, 'You have not completed 66 Days');
        msg.sender.transfer(pledges[_id].amount);
        pledges[_id].returned = true;
        addressPledgeCount[msg.sender]--;
    }

    //@notice returns the pledges owned by an address which havent returned the deposit
    function getPledges() external view returns(uint[] memory) {
        uint[] memory result = new uint[](addressPledgeCount[msg.sender]);
        uint count = 0;
        for (uint i = 0; i < pledges.length; i++) {
          if (idToAddress[i] == msg.sender && pledges[i].returned == false) {
            result[count] = i;
            count++;
          }
        }
        return result;
    }
    //@notice function to return info about pledges
    function getPledgeData(uint _id) external view onlyOwner(_id) returns(uint, uint, bool) {
        uint timeLeft;
        pledges[_id].endTime <= now ? timeLeft = 0 : timeLeft = pledges[_id].endTime - now;
        return (timeLeft, pledges[_id].amount, pledges[_id].returned);
    }
}
