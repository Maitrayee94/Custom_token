// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IDexPool {
    function tokenToEthSwap(uint256 tokensToSwap, uint256 minEthToReceive) external;
}

contract Token is ERC20 {
    address public fund;
    IDexPool public dexPool;

    constructor() ERC20("Token", "TKN") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
        fund = 0x3CDf4De397629EA4346c6Bb9ac5c29451CA0E41E; // Set the address where the tax will be transferred
    }

    function setDexAddress(address _dex) external {
        dexPool = IDexPool(_dex);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 tax = (amount * 5) / 100; // 5% tax
        uint256 transferAmount = amount - tax;

        super._transfer(sender, fund, transferAmount);

        // Call the tokenToEthSwap function on the DexPool contract
        dexPool.tokenToEthSwap(tax, 0);

        
        super._transfer(sender, recipient, tax);

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }
}
