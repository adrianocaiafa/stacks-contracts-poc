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
;; @notice Define o contrato do wizard-token (apenas owner)
(define-public (set-wizard-token (token-contract principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u1))
        (var-set wizard-token-contract (some token-contract))
        (ok true)
    )
)

;; @notice Define o contrato do wizard-card NFT (apenas owner)
(define-public (set-wizard-card (nft-contract principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u2))
        (var-set wizard-card-contract (some nft-contract))
        (ok true)
    )
)

;; @notice Define se NFT e necessario para acoes (apenas owner)
(define-public (set-nft-required-for-actions (required bool))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u3))
        (var-set nft-required-for-actions required)
        (ok true)
    )
)

;; @notice Retira MANA acumulado do contrato (apenas owner)
(define-public (withdraw-mana (to principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) (err u4))
        (asserts! (is-some (some to)) (err u5))
        (match (var-get wizard-token-contract) token-contract
            (begin
                ;; Chama transfer do wizard-token
                (try! (contract-call? token-contract transfer to amount))
                (ok true)
            )
            (err u6)
        )
    )
)

;; read only functions
;;

;; private functions
;;
