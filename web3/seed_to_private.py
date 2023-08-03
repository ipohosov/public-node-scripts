from web3 import Web3
from web3.middleware import geth_poa_middleware
from eth_account.signers.local import LocalAccount

def get_private_from_seed(seed: str) -> str:
    web3 = Web3(provider=Web3.HTTPProvider(endpoint_uri=arb_rpc))
    web3.middleware_onion.inject(geth_poa_middleware, layer=0)
    web3.eth.account.enable_unaudited_hdwallet_features()

    web3_account: LocalAccount = web3.eth.account.from_mnemonic(seed)

    private_key = web3_account._private_key.hex()
    address = web3_account.address
    return private_key