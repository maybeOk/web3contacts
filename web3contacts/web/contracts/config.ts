interface ContractAddresses {
    [key: string]: string;
}

type NetworkType = 'testnet' | 'mainnet';

const configs = {
    testnet: {
        Package: "0x1f657bae3d39ebd18e29068240cdfea3602baee49eeccc55fa4f523cde286116",
        state:   "0xbfa3c6c70f3ff637ad97c9068d7afdf534c1fae85b1be9a24b5669d17e70b392",
    },
    mainnet: {
        Package: "0x1111111111111111111111111111111111111111",
    }
} as const satisfies Record<NetworkType, ContractAddresses>;

export function getContractConfig(network: NetworkType): ContractAddresses {
    return configs[network];
}