import { eth } from "state/eth"; // Global state: ETH
import { useState } from "react"; // State management
import { token } from "state/token"; // Global state: Tokens
import Layout from "components/Layout"; // Layout wrapper
import styles from "styles/pages/Claim.module.scss"; // Page styles
console.log(token);

export default function Claim() {
  // Global ETH state
  const { address, unlock }: { address: string | null; unlock: Function } =
    eth.useContainer();
  // Global token state
  const {
    dataLoading,
    numTokens,
    alreadyClaimed,
    claimAirdrop,
    claimedAmount
  }: {
    dataLoading: boolean;
    alreadyClaimed: boolean;
    numTokens: number;
    claimedAmount: number;
    claimAirdrop: Function;
  } = token.useContainer();
  console.log(numTokens);
  // Local button loading
  const [buttonLoading, setButtonLoading] = useState<boolean>(false);
  const [value, setValue] = useState<number>(0);

  /**
   * Claims airdrop with local button loading
   */
  const claimWithLoading = async () => {
    setButtonLoading(true); // Toggle
    await claimAirdrop(value); // Claim
    setButtonLoading(false); // Toggle
  };

  const handleChange = (e) => {
    const amountToBuy = e.target.value.replace(/\D/g, "");
    setValue(amountToBuy);
  };

  return (
    <Layout>
      <div className={styles.claim}>
        {!address ? (
          // Not authenticated
          <div className={styles.card}>
            <h1>You are not authenticated.</h1>
            <p>Please connect your wallet to verify address and max possible contribution.</p>
            <button onClick={() => unlock()}>Connect Wallet</button>
          </div>
        ) : dataLoading ? (
          // Loading details about address
          <div className={styles.card}>
            <h1>Loading airdrop details...</h1>
            <p>Please hold while we collect details about your address.</p>
          </div>
        ) : numTokens == 0 ? (
          // Not part of airdrop
          <div className={styles.card}>
            <h1>This wallet is not whitelisted</h1>
          </div>
        ) : alreadyClaimed ? (
          // Already claimed airdrop
          <div className={styles.card}>
            <h1>Already claimed.</h1>
            <p>
              Your address ({address}) has already claimed {numTokens} tokens.
            </p>
          </div>
        ) : (
          // Claim your airdrop
          <div className={styles.card}>
            <div>
              <input value={`${numTokens}`} onChange={handleChange} />
            </div>
            <button onClick={claimWithLoading} disabled={buttonLoading}>
              Purchase
            </button>
            <p>
            {`Total pCNV Claimed: ${claimedAmount}`}
            </p>
            <p>
            {`Max pCNV Claimable: ${numTokens}`}
            </p>
          </div>
        )}
      </div>
    </Layout>
  );
}