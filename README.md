# Sheldrake

## About
Sheldrake is a blockchain demo network that implements a cryptocurrency(first generation) example without a merkle tree, smart contracts, sidechain and a wallet. The main motivation was practice ocaml, functional programming, blockchain concepts and decentralized applications.

## Dependencies
- OCaml 4.12.0
- Dune 2.9.1
- GCC 11.1.0

## Compile and Run

On root
```bash
 $ dune build
```
to compile(some warnings due to C interfaced code) and
```bash
$ dune exec sheldrake
```
to run.

### How to run properly
 - You'll need to change the port and execute in different terminals to check the requests working between executions.
 - If you have more than one machine you can try to execute in each one and see the requests with server side logs(it's printed in every request).
 - You can just execute one instance and test the endpoints with something like postman.
 
## TODO List
- [ ] Improve error handling
- [ ] Multi-threads(Concurrency)
- [ ] Real database integration
- [ ] Smart contract
- [ ] Optimize client side
- [ ] Increase test coverage
- [ ] CI
- [ ] Finish README

## Limitations
#### TODO

## Contributions
#### TODO

## Authorship
[Tiago Onofre](https://github.com/OnofreTZK)
