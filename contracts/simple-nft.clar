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

;; Total de usuarios unicos que interagiram com o contrato
(define-data-var total-unique-users uint u0)

;; data maps
;; Indica se um endereco ja interagiu com o contrato
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)
;; Proprietario de cada NFT (token-id -> principal)
(define-map owners uint principal)

;; Contador de NFTs mintados por usuario
(define-map minted-count principal uint)

;; public functions
;; @notice Define o supply maximo de NFTs (apenas owner)
(define-public (set-supply (supply uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
        (asserts! (> supply u0) (err u2))
        ;; Verifica se ainda nao foi definido ou permite redefinir
        (var-set max-supply (some supply))
        (ok true)
    )
)

;; read only functions
;;

;; private functions
;;
