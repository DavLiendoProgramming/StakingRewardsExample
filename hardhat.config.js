/**
 * Required imports
 */
require('dotenv').config();
require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-truffle5');
require('@nomiclabs/hardhat-etherscan');

/**
 * Import private key of the account with funds
 */
const PRIVATE_KEY = process.env.PRIVATE_KEY;

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  /**
   * using matic network for deployment
   */
  defaultNetwork: 'matic',
  networks: {
    hardhat: {},
    matic: {
      url: 'https://rpc-mumbai.maticvigil.com',
      accounts: [PRIVATE_KEY],
      /**
       * Configuring gas restrictions
       */
      gas: 2100000,
      gasPrice: 8000000000,
    },
    goerli: {
      url: 'https://goerli.infura.io/v3/8173bc023d8f45e595df4f3fb55db36e',
      accounts: [PRIVATE_KEY],
      /**
       * Configuring gas restrictions
       */
      gas: 2100000,
      gasPrice: 8000000000,
    },
  },
  solidity: {
    version: '0.8.4',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  mocha: {
    timeout: 20000,
  },
  /**
   * Using hardhat-etherscan plugin for veryfying introduce key for polygon or eth nets
   */
  etherscan: {
    apiKey: process.env.POLYGON_KEY,
  },
};
