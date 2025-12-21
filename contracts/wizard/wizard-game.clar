;; title: wizard-game
;; version: 1.0.0
;; summary: Sistema de RPG on-chain com XP, niveis e feiticos
;; description: Contrato de jogo onde usuarios gastam MANA para ganhar XP, subir de nivel e lancar feiticos

;; traits
;; Trait para interagir com o wizard-token
(define-trait wizard-token-trait
    (
        (transfer (principal uint) (response uint uint))
        (get-balance (principal) (response uint uint))
    )
)

;; token definitions
;;

;; constants
;; XP necessario por nivel
(define-constant XP_PER_LEVEL u100)

;; Taxa de conversao MANA para XP (1 MANA = 1 XP, considerando 6 decimais)
(define-constant MANA_TO_XP_RATE u1)

;; Mana minimo para gastar (1 MANA com 6 decimais)
(define-constant MIN_MANA_SPEND u1000000)

;; data vars
;; Owner do contrato
(define-data-var contract-owner principal tx-sender)

;; Contrato do wizard-token (MANA)
(define-data-var wizard-token-contract (optional principal) none)

;; Contrato do wizard-card NFT (opcional)
(define-data-var wizard-card-contract (optional principal) none)

;; Se NFT e necessario para acoes
(define-data-var nft-required-for-actions bool false)

;; Total de wizards unicos
(define-data-var total-unique-wizards uint u0)

;; Contador de wizards (para lista indexada)
(define-data-var wizards-count uint u0)

;; data maps
;; Indica se um endereco ja interagiu
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)

;; XP de cada wizard
(define-map xp principal uint)

;; Nivel de cada wizard
(define-map level principal uint)

;; Feiticos lancados por cada wizard
(define-map spells-cast principal uint)

;; Lista de wizards indexada (indice -> principal)
(define-map wizards uint principal)

;; public functions
;;

;; read only functions
;;

;; private functions
;;
