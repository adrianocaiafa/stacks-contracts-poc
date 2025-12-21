;; title: simple-nft
;; version: 1.0.0
;; summary: NFT controlado com limite de mint por usuario
;; description: Contrato NFT onde o owner controla o supply e usuarios podem mintar no maximo 2 NFTs

;; traits
;;

;; token definitions
;;

;; constants
;; Limite de NFTs que um usuario pode mintar
(define-constant MAX_MINT_PER_USER u2)

;; data vars
;; Owner do contrato (quem pode definir supply)
(define-data-var contract-owner principal tx-sender)

;; Supply maximo de NFTs (definido pelo owner)
(define-data-var max-supply (optional uint) none)

;; Contador de tokens mintados (para gerar IDs)
(define-data-var token-counter uint u0)

;; data maps
;; Proprietario de cada NFT (token-id -> principal)
(define-map owners uint principal)

;; Contador de NFTs mintados por usuario
(define-map minted-count principal uint)

;; public functions
;;

;; read only functions
;;

;; private functions
;;
