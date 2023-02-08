require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");

require('dotenv').config({path:'./process.env'})

const GOERLI_URL = process.env.URL1;
const MAINNET_URL = process.env.URL2;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const API_KEY = process.env.API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.17",

    networks: {
      goerli: {
        url: GOERLI_URL,
        accounts: [PRIVATE_KEY],
      },

      mainnet: {
        url: MAINNET_URL,
        accounts: [PRIVATE_KEY],
      },

    },

    etherscan: {
      apiKey: API_KEY,
    }
};
