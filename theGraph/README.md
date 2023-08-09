
INSTALL GRAPH CLI USING NPM
```shell
npm install -g @graphprotocol/graph-cli
```


INITIALIZE SUBGRAPH
```shell
graph init --studio game-data-statistics
```


AUTHENTICATE IN CLI
```shell
graph auth --studio
```

ENTER SUBGRAPH
```shell
cd game-data-statistics
```

BUILD SUBGRAPH
```shell
graph codegen && graph build
```

DEPLOY SUBGRAPH
```shell
graph deploy --studio game-data-statistics
```


result :
````shell
✔ Upload subgraph to IPFS

Build completed: QmdxUFvxSjARAMp6HpbYFdm1W3knGHZXLW7u2giGAsXhRC

Deployed to https://thegraph.com/studio/subgraph/game-data-statistics

Subgraph endpoints:
Queries (HTTP):     https://api.studio.thegraph.com/query/50935/game-data-statistics/v0.0.1

````