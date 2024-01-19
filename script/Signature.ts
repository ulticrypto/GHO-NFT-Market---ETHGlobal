
generateCreditDelegationSignatureRequest: async ({
    user,
    amount,
    deadline,
    underlyingAsset,
    name,
    spender,
    chainId,
    nonce,
  }) => {

    const typedData = {
      types: {
        EIP712Domain: [
          { name: 'name', type: 'string' },
          { name: 'version', type: 'string' },
          { name: 'chainId', type: 'uint256' },
          { name: 'verifyingContract', type: 'address' },
        ],
        DelegationWithSig: [
          { name: 'delegatee', type: 'address' },
          { name: 'value', type: 'uint256' },
          { name: 'nonce', type: 'uint256' },
          { name: 'deadline', type: 'uint256' },
        ],
      },
      primaryType: 'DelegationWithSig' as const,
      domain: {
        name,
        version: '1',
        chainId: chainId,
        verifyingContract: underlyingAsset,
      },
      message: {
        delegatee: spender,
        value: amount,
        nonce,
        deadline,
      },
    };

    return JSON.stringify(typedData);
  }