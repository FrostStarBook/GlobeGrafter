import { execute } from '.graphclient'

const myQuery = gql`
  query pairs {
     nftminteds(first: 10) {
        id
        _damage
        _attack
        _dungeons_level
        _exp
        _gold
        _level
        blockNumber
        blockTimestamp
        tokenId
        transactionHash
     }
  }
`

async function main() {
    const result = await execute(myQuery, {})
    console.log(result)
}

main()