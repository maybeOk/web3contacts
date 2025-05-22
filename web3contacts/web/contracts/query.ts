import { isValidSuiAddress } from "@mysten/sui/utils";
import { suiClient ,createBetterTxFactory,networkConfig} from "./index";
import { SuiObjectResponse } from "@mysten/sui/client";
import { categorizeSuiObjects, CategorizedObjects } from "@/utils/assetsHelpers";

export const getUserProfile = async (address: string): Promise<CategorizedObjects> => {
  if (!isValidSuiAddress(address)) {
    throw new Error("Invalid Sui address");
  }

  let hasNextPage = true;
  let nextCursor: string | null = null;
  let allObjects: SuiObjectResponse[] = [];

  while (hasNextPage) {
    const response = await suiClient.getOwnedObjects({
      owner: address,
      options: {
        showContent: true,
      },
      cursor: nextCursor,
    });

    allObjects = allObjects.concat(response.data);
    hasNextPage = response.hasNextPage;
    nextCursor = response.nextCursor ?? null;
  }

  return categorizeSuiObjects(allObjects);
};

export const create_profile =createBetterTxFactory<{  name: string,description:string}>
((tx, networkVariables, params) => {
  tx.moveCall({
    package: networkVariables.Package,
    module: "human_relations",
    function: "create_froflie",
    arguments: [
      tx.pure.string(params.name),
      tx.pure.string(params.description),
      tx.pure.string(networkConfig.testnet.variables.state),
    ],
}) 
return tx

});

