# Déploiement de `PoolNFT`

Prérequis
- `forge` installé (Foundry)
- Avoir un fournisseur RPC (Ex: Infura, Alchemy) pour Sepolia ou autre testnet
- Une clé privée avec des fonds pour payer le gas (ne partage pas la clé)

Variables d'environnement
- `BASE_URI` : l'URI de base des métadonnées (ex: `ipfs://Qm.../`)
- `RPC_SEPOLIA` : l'URL RPC du réseau (ex: `https://sepolia.infura.io/v3/YOUR_KEY`)
- `PRIVATE_KEY` : la clé privée du déployeur (hex, préférez `0x...`)
- `DEPLOY_METHOD` (optionnel) : `script` (par défaut) ou `create`

Deux options de déploiement

1) Via le script Foundry (recommandé)

Exporte les variables et lance `deploy.sh` (méthode par défaut) :

```bash
export BASE_URI="ipfs://VOTRE_CID/"
export RPC_SEPOLIA="https://sepolia.infura.io/v3/YOUR_KEY"
export PRIVATE_KEY="0x..."
cd day02-solidity
chmod +x deploy.sh
./deploy.sh
```

Le script invoque `script/DeployPoolNFT.s.sol` qui lit `BASE_URI` et `PRIVATE_KEY`.

2) Via `forge create` (option alternative)

```bash
export BASE_URI="ipfs://VOTRE_CID/"
export RPC_SEPOLIA="https://sepolia.infura.io/v3/YOUR_KEY"
export PRIVATE_KEY="0x..."
export DEPLOY_METHOD=create
cd day02-solidity
./deploy.sh
```

Notes de sécurité
- Ne commettez jamais votre clé privée dans le repo.
- Pour CI, utilisez des secrets stockés dans votre pipeline.

Vérifications après déploiement
- Vérifier le baseURI:

```bash
cast call <NFT_ADDRESS> "baseURI()" --rpc-url $RPC_SEPOLIA
```

- Mint d'un NFT (depuis le propriétaire):

```bash
cast send <NFT_ADDRESS> "mint(address)" <YOUR_WALLET> --rpc-url $RPC_SEPOLIA --private-key $PRIVATE_KEY
```

---
Si tu veux, je peux lancer un déploiement de test maintenant (il faudra fournir `PRIVATE_KEY` et `RPC_SEPOLIA`), ou préparer un fichier `env.example` pour t'aider.
