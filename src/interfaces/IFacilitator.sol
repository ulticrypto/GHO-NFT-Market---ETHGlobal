// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFacilitator {
  /**
   * @dev Emitted when fees are distributed to the GhoTreasury
   * @param ghoTreasury The address of the ghoTreasury
   * @param asset The address of the asset transferred to the ghoTreasury
   * @param amount The amount of the asset transferred to the ghoTreasury
   */
  event FeesDistributedToTreasury(
    address indexed ghoTreasury,
    address indexed asset,
    uint256 amount
  );

  /**
   * @dev Emitted when Gho Treasury address is updated
   * @param oldGhoTreasury The address of the old GhoTreasury contract
   * @param newGhoTreasury The address of the new GhoTreasury contract
   */
  event GhoTreasuryUpdated(address indexed oldGhoTreasury, address indexed newGhoTreasury);

   /**
   * @dev Create GHO Token with 
   */
   function minting(address account, uint256 amount) external;

   /**
   * @dev  Burn GHO tokens either for loan repayment or to maintain the peg.
   */
   function burning(uint256 amount) external;

  /**
   * @notice Distribute fees to the GhoTreasury
   */
  function distributeFeesToTreasury() external;

  /**
   * @notice Updates the address of the Gho Treasury
   * @dev WARNING: The GhoTreasury is where revenue fees are sent to. Update carefully
   * @param newGhoTreasury The address of the GhoTreasury
   */
  function updateGhoTreasury(address newGhoTreasury) external;

  /**
   * @notice Returns the address of the Gho Treasury
   * @return The address of the GhoTreasury contract
   */
  function getGhoTreasury() external view returns (address);
}