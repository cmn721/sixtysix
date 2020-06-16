import React, { useState } from 'react';
import Web3 from 'web3';
import { SixtySixDaysABI, SixtySixDaysAddress } from './abi/abis.js';
import './App.css';

const web3 = new Web3(Web3.givenProvider || 'http://localhost:7545')
const SixtySixDays = new web3.eth.Contract(SixtySixDaysABI, SixtySixDaysAddress);

function App() {
  const [account, setAccount] = useState();
  const [button, setButton] = useState('Enable Ethereum');
  const [value, setValue] = useState(1);


  const handlePledge = async (e) => {
    e.preventDefault();
    const gas = await SixtySixDays.methods.createNewPledge().estimateGas();
    const result = await SixtySixDays.methods.createNewPledge().send({
      from: account,
      gas,
      value: value
    })
    console.log(result);
  }

  const handleAccount = async (e) => {
    e.preventDefault();
    const accounts = await window.ethereum.enable();
    setAccount(accounts[0]);
    setButton('Change Account');
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>66 Days</h1>
        <button onClick={handleAccount}>{button}</button>
        <p>Your Account: {account} </p>
        <form onSubmit={handlePledge}>
          <label>
            Set Amount:
            <input
            type="number"
            name="name"
            value={value}
            onChange={ e => setValue(e.target.value) } />
          </label>
          <input type="submit" value="Deposit" />
        </form>
        <p>Amount: {value}</p>
      </header>
    </div>
  );
}

export default App;
