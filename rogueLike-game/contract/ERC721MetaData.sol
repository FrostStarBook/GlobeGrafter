// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC721MetaData {

    function getImg(uint _img) public pure returns(string memory) {
        string memory result;
        if(_img == 1) return "https://lime-okay-spoonbill-223.mypinata.cloud/ipfs/QmYQ6qyUdpqKLeL78DjUwM941xbfC1CwZi3fXmpB3GeUe1?_gl=1*1wlkfk*_ga*MTI4ODQxMjIzNy4xNjkxNTUxOTkz*_ga_5RMPXG14TE*MTY5MTU1MTk5NC4xLjEuMTY5MTU1MjE3Ny4xOC4wLjA.";
        if(_img == 2) return "https://lime-okay-spoonbill-223.mypinata.cloud/ipfs/Qmda8x7zmsn9qXTpUcRtB3wzvbHAwAfCtB3Yeqe9oHWeTY?_gl=1*rft4ru*_ga*MTI4ODQxMjIzNy4xNjkxNTUxOTkz*_ga_5RMPXG14TE*MTY5MTU1MTk5NC4xLjEuMTY5MTU1MjE3Ny4xOC4wLjA.";
        if(_img == 3) return "https://lime-okay-spoonbill-223.mypinata.cloud/ipfs/QmbL3JrLiHfZ6dgjfhsAYKoWV4yEuPYMMBDN12KaSQRCNH?_gl=1*rft4ru*_ga*MTI4ODQxMjIzNy4xNjkxNTUxOTkz*_ga_5RMPXG14TE*MTY5MTU1MTk5NC4xLjEuMTY5MTU1MjE3Ny4xOC4wLjA.";
        if(_img == 4) return "https://lime-okay-spoonbill-223.mypinata.cloud/ipfs/QmVifSRHEwoY24MNueV8h9evbirsHg1jwuBMRckzbmcD74?_gl=1*1wopyz2*_ga*MTI4ODQxMjIzNy4xNjkxNTUxOTkz*_ga_5RMPXG14TE*MTY5MTU1MTk5NC4xLjEuMTY5MTU1MjE3Ny4xOC4wLjA.";
        if(_img == 5) return "https://lime-okay-spoonbill-223.mypinata.cloud/ipfs/QmPX7QDdWJZnUQeuWj7dhdgvKUeC7N1DC9XPJS5SRXtQAp?_gl=1*1wopyz2*_ga*MTI4ODQxMjIzNy4xNjkxNTUxOTkz*_ga_5RMPXG14TE*MTY5MTU1MTk5NC4xLjEuMTY5MTU1MjE3Ny4xOC4wLjA.";
        if(_img == 6) return "https://lime-okay-spoonbill-223.mypinata.cloud/ipfs/QmQB34gAHiwpK8uxKrsftA99HcezG6YabQHzoe7q7nxZo6?_gl=1*1wopyz2*_ga*MTI4ODQxMjIzNy4xNjkxNTUxOTkz*_ga_5RMPXG14TE*MTY5MTU1MTk5NC4xLjEuMTY5MTU1MjE3Ny4xOC4wLjA.";
        if(_img == 7) return "https://lime-okay-spoonbill-223.mypinata.cloud/ipfs/Qmcs17jTdPrP5AoAwY1qHNuB2MmT8P73Z8UVkh3fixzbcM?_gl=1*14zhqj8*_ga*MTI4ODQxMjIzNy4xNjkxNTUxOTkz*_ga_5RMPXG14TE*MTY5MTU1MTk5NC4xLjEuMTY5MTU1MjE3Ny4xOC4wLjA.";
        else return result;
    }
}
