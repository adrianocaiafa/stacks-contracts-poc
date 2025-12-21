;; title: simple-token
;; version: 1.0.0
;; summary: Token fungivel simples com mint, burn e transfer
;; description: Contrato de token fungivel que permite cunhar, queimar e transferir tokens

;; traits
;;

;; token definitions
;;

;; constants
;; Nome do token
(define-constant TOKEN_NAME "Simple Token")

;; Simbolo do token
(define-constant TOKEN_SYMBOL "STK")

;; Decimais do token
(define-constant TOKEN_DECIMALS u6)

;; data vars
;; Supply total de tokens (total cunhado)
(define-data-var total-supply uint u0)

;; Total de usuarios unicos que interagiram com o contrato
(define-data-var total-unique-users uint u0)

;; data maps
;; Indica se um endereco ja interagiu com o contrato
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)

;; Balanco de tokens de cada usuario
(define-map balances principal uint)

;; public functions
;;

;; read only functions
;;

;; private functions
;;
