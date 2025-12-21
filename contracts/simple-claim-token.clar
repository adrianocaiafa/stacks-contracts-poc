;; title: simple-claim-token
;; version: 1.0.0
;; summary: Token fungivel com claim unico por usuario
;; description: Contrato de token onde usuarios podem reivindicar uma quantidade fixa de tokens uma vez

;; traits
;;

;; token definitions
;;

;; constants
;; Nome do token
(define-constant TOKEN_NAME "Wizard Mana")

;; Simbolo do token
(define-constant TOKEN_SYMBOL "MANA")

;; Decimais do token
(define-constant TOKEN_DECIMALS u6)

;; Quantidade de tokens que cada usuario pode reivindicar (1000 tokens com 6 decimais)
(define-constant CLAIM_AMOUNT u1000000000)

;; data vars
;; Supply total de tokens (total cunhado via claims)
(define-data-var total-supply uint u0)

;; data maps
;; Balanco de tokens de cada usuario
(define-map balances principal uint)

;; Indica se um usuario ja fez claim
(define-map has-claimed principal bool)

;; public functions
;;

;; read only functions
;;

;; private functions
;;
