const wagmi = require('wagmi');

console.log('Available hooks:');
console.log('useAccount:', !!wagmi.useAccount);
console.log('useNetwork:', !!wagmi.useNetwork);
console.log('useSigner:', !!wagmi.useSigner);
console.log('useWalletClient:', !!wagmi.useWalletClient);
console.log('usePublicClient:', !!wagmi.usePublicClient);
