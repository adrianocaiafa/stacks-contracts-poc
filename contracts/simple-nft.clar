;; title: simple-nft
;; version: 1.0.0
;; summary: NFT controlado com limite de mint por usuario
;; description: Contrato NFT onde o owner controla o supply e usuarios podem mintar no maximo 2 NFTs

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;; Proprietario de cada NFT (token-id -> principal)
(define-map owners uint principal)

;; Contador de NFTs mintados por usuario
(define-map minted-count principal uint)

;; Contador de tokens mintados (para gerar IDs)
(define-data-var token-counter uint u0)

;; public functions
;;

;; read only functions
;;

;; private functions
;;
