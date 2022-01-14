# pCNV to CNV mechanics

What is pCNV? 

pCNV Holder = Concave Stakeholder or owner

On a surface level, just like pOHM, pCNV is a precursor derivative of CNV; it gives the holder the option to mint CNV by burning pCNV and providing the intrinsic value of CNV. For example, an investor would provide 1 DAI and 1 pCNV to mint 1 CNV. 

On a deeper level, pCNV represents the claim of a constant % of circulating supply (thus a constant share of market cap) and it is quoted in related to or as a % of the 333,000,000 “Target Terminal supply” (TTS). Maybe let’s run through an example, say Sert did a great job building an awesome bonding machine for our treasury, MiaoShi decides to award him with 3,330,000 pCNV. This 3,330,000 is quoted in related to TTS which means Sert will always have 3,330,000/333,000,000 = 1% of circulating supply after his pToken becomes fully vested. Let’s look at 3 cases:

At the end of year 2 when all of his pCNVs are fully vested, circulating supply is 200,000,000. He can basically cash out 200 million X 1% = 2million CNVs by providing 2million DAI, assuming he hasn’t redeemed any pCNV before.

At the end of day 900 when concave reaches TTS and all of his pCNVs are vested, circulating supply is 333,000,000. He can basically cash out 333 million X 1% = 3.33million CNVs by providing 3.33million DAI, assuming he hasn’t redeemed any pCNV before.

At the end of year 5, circulating supply is 1,000,000,000.  He can basically redeem 1000 million X 1% = 10million CNVs by providing 10million DAI, assuming he hasn’t redeemed any pCNV before.


![image](https://user-images.githubusercontent.com/96172957/149446529-b67f5a16-99b9-407a-8337-91e3e6b580bc.png)

# FAQs

How does this work? The amount of pConcave redeemable at time T = Circulating supply at T * Vesting % at time T * Your pToken ownership as a % of circulating supply. Let’s just run an example, say Akarin owns half of all pTokens, which is 5% of the circulating supply. At the end of year 1, circulating supply is say 20,000,000 and he can vest 50% of his token, thus he can take out up to 20mil * 50% * 5% = 0.5mil of Concave Native Tokens by providing 0.5mil DAI. If he chooses to take all of it out, he will be left with 5% - 50%*5% = 2.5% claim on the circulating supply. Then at the end of year 2, circulating supply becomes 150mil and his vesting % becomes 100%. Now he can redeem up to 150mil * 100% *2.5% = 3.75mil pConcave by providing the same amount of DAI. 

Why is there a 5-month cliff imposed on the work team? What does that mean? The cliff means that you, as a member of the work team, cannot redeem anything until month 5. And if you end up doing some really stupid shit before month 5, the core team could take away your pConcave allocation at the contract level. The goal of this 5-month cliff is to ensure every member of the work team (especially core team and early contributors) won't just get their pConcave allocation and disappear or lay down on the floor. We want the work team to stay focused and motivated, especially during the first few months which is critical to the success of the project. 


# Gnosis Safe Instructions
Source Material: https://help.gnosis-safe.io/en/articles/3738081-contract-interactions

Here's an example on how to use the "Contract Interaction" feature to interact with arbitrary smart contracts. You can access the Contract Interaction feature using the Send button.

 <img src="https://downloads.intercomcdn.com/i/o/210019106/a760737ee58cbdc2536732a2/image.png?expires=1618516800&signature=e1b364f14390eb55409ed144bb1c40089e98f9f375827034baa5cb0fcf8bd4e2" width="550">


1) Select a smart contract to interact with
First, you need to paste a valid Ethereum address of a smart contract that you would like to interact with.

 <img src="https://downloads.intercomcdn.com/i/o/210015834/7384a7d5cc058bba7c1d2632/Screenshot+2020-05-18+at+15.36.06.png?expires=1618516800&signature=62ef8eb219f74a00612642e1edec6f9190938f08852461c3af081a622287e946" width="550">

2) Specify the ABI
For contracts that are verified on Etherscan, we automatically suggest the ABI, but you can also add an ABI manually using the input field.

3) Select the method
You can now select one of the available methods for this contract. Gnosis Safe supports both, read and write functions.

 <img src="https://downloads.intercomcdn.com/i/o/210009967/ad91db9acad6205bab4b3a3c/image.png?expires=1618516800&signature=ed6cd33e528e74cecfc9d9ee92db00e252a06f21c381ccc151a280cf931db23c" width="550">

4) Define parameter
The interface will now display the parameters and parameter types of this method. Optional: Define how much ETH is being sent with this contract interaction in the Value input field.

 <img src="https://downloads.intercomcdn.com/i/o/210016016/2f2813eaf11b36952057e919/Screenshot+2020-05-18+at+15.35.44.png?expires=1618516800&signature=714c84f3b28ed500831aec49fc7314e96002e93bf4996667e0048e803069ce09" width="550">

5) Review and send
Finally, you can review your smart contract interaction and confirm the transaction. Depending on your owner setup, the transaction will have to be confirmed by other signers as well.


# FEEL FREE TO PING US IN DISCORD IF YOU NEED HELP CLAIMING USING A MULTISIG

## User Story

    ---------------------
    The contract features two vesting schedules to redeem pCNV into CNV.
    Both schedules are linear, and have a duration of 2 years.

    The first vesting schedule determines how many pCNV a holder can redeem at
    any point in time. At contract inception - 0% of a holder's pCNV can be 
    redeemed. At the end of 2 years, 100% of a holder's pCNV can be redeemed.
    It goes from 0% to 100% in a linear fashion.

    The second vesting schedule determines the percent of CNV supply that pCNV
    corresponds to. This vesting schedule also begins at 0% on day one, and
    advances linearly to reach 10% at the end of year two.

    The following is a breakdown of a pCNV to CNV redemption:

    Assumptions:
        - Alice holds 100 pCNV
        - pCNV total supply is 200
        - CNV total supply is 1000
        - 1 year has passed and Alice has not made any previous redemptions
    
    Then:
        - The first vesting schedule tells us that users may redeem 50% of their
          holdings, so Alice may redeem 50 pCNV.
        - The second vesting schedule tells us that pCNV total supply corresponds
          to 5% of total CNV supply.
        - Since total CNV supply is 1000, 5% of it is 50, so 50 CNV are what
          correspond to the 200 pCNV supply.
        - Alice has 50% of total pCNV supply
        - Thus, Alice is entitled to 50% of the claimable CNV supply, i.e Alice
          is entitled to 25 CNV

    Conclusion:
        - Alice burns 50 pCNV
        - Alice mints 25 CNV


# Developer Notes
Includes generator used to create merkle root, frontend used to redeem, as well as underlying contracts

    npm i



After install

    npm run dev
