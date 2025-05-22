interface ContractAddresses {
    [key: string]: string;
}

type NetworkType = 'testnet' | 'mainnet';

const configs = {
    testnet: {
        Package: "0x5923b2042cd02e7686fd644d0aebad00930a569726b6e3d17d2c1cfd24ad4b1b",
        state:   "0x1b1d33e588153a75c472fe0399ca4dfddee0bb9a24ce71f4527ecf1569b34323",
    },
    mainnet: {
        Package: "0x1111111111111111111111111111111111111111",
    }
} as const satisfies Record<NetworkType, ContractAddresses>;

export function getContractConfig(network: NetworkType): ContractAddresses {
    return configs[network];
}