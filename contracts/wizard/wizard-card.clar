;; title: wizard-card
;; version: 1.0.0
;; summary: NFT de identidade de wizard para o ecossistema WizardGame
;; description: Contrato NFT simples onde cada wallet pode mintar apenas um card

;; traits
;;

;; token definitions
;;

;; constants
;; Nome do NFT
(define-constant TOKEN_NAME "Wizard Card")

;; Simbolo do NFT
(define-constant TOKEN_SYMBOL "WIZCARD")

;; data vars
;; Owner do contrato
(define-data-var contract-owner principal tx-sender)

;; Contador de tokens mintados (para gerar IDs)
(define-data-var token-counter uint u1)

;; Total de usuarios unicos que interagiram com o contrato
(define-data-var total-unique-users uint u0)

;; data maps
;; Indica se um endereco ja interagiu com o contrato
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)

;; Proprietario de cada NFT (token-id -> principal)
(define-map owners uint principal)

;; Indica se um usuario ja mintou um card
(define-map has-minted principal bool)

;; public functions
;;

;; read only functions
;;

;; private functions
;;
