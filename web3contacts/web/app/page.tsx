'use client'
import { ConnectButton } from '@mysten/dapp-kit'
import Image from 'next/image'
import { getUserProfile ,create_profile } from '@/contracts/query'
import { useCurrentAccount } from '@mysten/dapp-kit'
import { useEffect, useState } from 'react'
import { CategorizedObjects } from '@/utils/assetsHelpers'
import { useBetterSignAndExecuteTransaction } from '@/hooks/useBetterTx'

export default function Home() {
  const account = useCurrentAccount();
  const [userObjects, setUserObjects] = useState<CategorizedObjects | null>(null);
  const [name, setName] = useState<string>('');
  const [description, setDescription] = useState<string>('');
  const{handleSignAndExecuteTransaction: createProfileHandler}=useBetterSignAndExecuteTransaction({
    tx: create_profile,
  });

  const handleCreateProfileClick = async (name: string, description: string) => {
    if (!account?.address) {
      console.error('No account address found');
      return;
    }
    try {
      createProfileHandler({ name, description }).beforeExecute(async () => {
        console.log('Creating profile with name:', name, 'and description:', description)}).execute();
      alert('Profile created successfully!');
      // Optionally, you can refetch the user profile after creating it
      const profile = await getUserProfile(account.address);
      setUserObjects(profile);
    } catch (error) {
      console.error('Error creating profile:', error);
    }
  };



  useEffect(() => {
    async function fetchUserProfile() {
      if (account?.address) {
        try {
          const profile = await getUserProfile(account.address);
          setUserObjects(profile);
        } catch (error) {
          console.error('Error fetching user profile:', error);
        }
      }
    }

    fetchUserProfile();
  }, [account]);

  return (
    <div className="min-h-screen flex flex-col">
      <header className="flex justify-between items-center p-4 bg-white shadow-md">
        <div className="flex items-center rounded-full overflow-hidden">
          <Image src="/logo/logo.jpg" alt="Sui Logo" width={80} height={40} />
        </div>
        <ConnectButton />
      </header>
      {userObjects != null ? (
        <main className="flex-grow flex flex-col items-center p-8">
          {userObjects && (
            <div className="w-full max-w-6xl">
              <h2 className="text-2xl font-bold mb-4">Contacts</h2>


              <div className="flex flex-col items-center p-4">
                <h2 className="text-xl font-bold mb-4">Create Your Profile</h2>
                <div className="flex flex-col gap-4 w-full max-w-md">
                  <input
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    type="text"
                    placeholder="Enter your name"
                    className="p-2 border border-gray-300 rounded-md"
                  />
                  <input
                    type="text"
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="Enter your bio"
                    className="p-2 border border-gray-300 rounded-md"
                  />
                  <button
                    onClick={() => handleCreateProfileClick(name, description)}
                    className="p-2 bg-blue-500 text-white rounded-md hover:bg-blue-600"
                  >
                    Confirm
                  </button>
                </div>
              </div>


              <div className="flex gap-8">
                {/* <div className="flex-1">
                <h3 className="text-xl font-semibold mb-2">Coins</h3>
                {Object.entries(userObjects.coins).map(([coinType, coins]) => {
                  const totalBalance = calculateTotalBalance(coins);
                  return (
                    <div key={coinType} className="mb-4 p-4 bg-gray-100 rounded-lg">
                      <h4 className="font-medium text-lg">{coinType.split('::').pop()}</h4>
                      <p>Count: {coins.length}</p>
                      <p>Total Balance: {formatBalance(totalBalance)}</p>
                    </div>
                  );
                })}
              </div> */}

                <div className="flex-1">
                  <h3 className="text-xl font-semibold mb-2">Contacts(联系人)</h3>
                  <div className="h-[500px] overflow-y-auto pr-4">
                    {Object.entries(userObjects.objects).map(([objectType, objects]) => (
                      <div key={objectType} className="mb-4 p-4 bg-gray-100 rounded-lg">
                        <h4 className="font-medium text-lg">{objectType.split('::').pop()}</h4>
                        <p>Count: {objects.length}</p>
                        <p className="text-gray-500 text-sm">{objectType.split('::').pop()}</p>
                        <p className="text-gray-500 text-sm">{objectType.split('::')[0]}</p>
                        <button type="button" className="mt-2 px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600">transfer</button>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          )}
        </main>
      ) : (
        <div className="flex-grow flex flex-col items-center p-8">
          <h1 className="text-4xl font-bold text-gray-800 mb-8">Welcome to Nextjs Sui Dapp Template</h1>
          <h3 className="text-2xl font-bold text-gray-800 mb-8">Please connect your wallet to view your assets</h3>
        </div>
      )}
    </div>
  );
}
