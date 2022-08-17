let
  nixpkgs-sources =
    builtins.fetchTarball
      https://github.com/anmonteiro/nix-overlays/archive/master.tar.gz;
      pkgs = import nixpkgs-sources { };
      ocamlPackages = pkgs.ocaml-ng.ocamlPackages_4_14;
in
pkgs.mkShell {
  # build tools
  nativeBuildInputs = with ocamlPackages; [ 
    ocaml 
    findlib 
    dune_2 
    ocaml-lsp 
  ];
  
  # dependencies
  buildInputs = with ocamlPackages; [ 
    caqti
    caqti-lwt
    caqti-driver-postgresql 
    uuidm
    ppx_deriving_yojson
    lwt_ppx
    cohttp-lwt-unix
    mirage-crypto-rng
    sha
    base64
    alcotest
    qcheck-alcotest
    opium
  ];
}
