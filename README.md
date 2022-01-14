# Concave-Seed
# P-Token (pCNV)

Includes generator used to create merkle root, frontend used to redeem, as well as underlying contracts

    npm i

After install

    npm run dev


    
    
# pCNV to CNV mechanics
    ---------------------
    The contract features two vesting schedules to redeem pCNV into CNV. Both
    schedules are linear, and have a duration of 2 years.

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
