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
;; @notice Minta um wizard card NFT (um por wallet)
(define-public (mint)
    (let ((sender tx-sender))
        (begin
            ;; Verifica se usuario ja mintou
            (asserts! (not (match (map-get? has-minted sender) minted minted false)) (err u1))
            ;; Registra interacao
            (match (map-get? has-interacted sender) already-interacted
                true
                (begin
                    (map-set has-interacted sender true)
                    (var-set total-unique-users (+ (var-get total-unique-users) u1))
                )
            )
            (let ((current-count (match (map-get? interactions-count sender) count count u0)))
                (map-set interactions-count sender (+ current-count u1))
            )
            ;; Obtem o proximo token ID
            (let ((token-id (var-get token-counter)))
                (begin
                    ;; Minta o NFT
                    (map-set owners token-id sender)
                    (map-set has-minted sender true)
                    (var-set token-counter (+ token-id u1))
                    (ok token-id)
                )
            )
        )
    )
)

;; @notice Transfere um NFT para outro usuario
(define-public (transfer (token-id uint) (to principal))
    (begin
        (asserts! (is-some (some to)) (err u2))
        (let ((sender tx-sender))
            (begin
                ;; Verifica se o sender e o dono do NFT
                (let ((owner (unwrap! (map-get? owners token-id) (err u3))))
                    (asserts! (is-eq sender owner) (err u4))
                    ;; Transfere o NFT
                    (begin
                        (map-set owners token-id to)
                        ;; Registra interacao
                        (match (map-get? has-interacted sender) already-interacted
                            true
                            (begin
                                (map-set has-interacted sender true)
                                (var-set total-unique-users (+ (var-get total-unique-users) u1))
                            )
                        )
                        (let ((current-count (match (map-get? interactions-count sender) count count u0)))
                            (map-set interactions-count sender (+ current-count u1))
                        )
                        (ok true)
                    )
                )
            )
        )
    )
)

;; read only functions
;; @notice Retorna o dono de um NFT
(define-read-only (get-owner (token-id uint))
    (ok (map-get? owners token-id))
)

;; @notice Retorna o nome do token
(define-read-only (get-name)
    (ok TOKEN_NAME)
)

;; @notice Retorna o simbolo do token
(define-read-only (get-symbol)
    (ok TOKEN_SYMBOL)
)

;; @notice Retorna se o usuario atual ja mintou
(define-read-only (my-has-minted)
    (ok (match (map-get? has-minted tx-sender) minted minted false))
)

;; @notice Retorna se um usuario especifico ja mintou
(define-read-only (has-user-minted (user principal))
    (ok (match (map-get? has-minted user) minted minted false))
)

;; @notice Retorna quantas vezes voce interagiu com este contrato
(define-read-only (my-interactions)
    (ok (match (map-get? interactions-count tx-sender) count count u0))
)

;; @notice Retorna o total de usuarios unicos
(define-read-only (get-total-unique-users)
    (ok (var-get total-unique-users))
)

;; @notice Retorna se um usuario ja interagiu com o contrato
(define-read-only (has-user-interacted (user principal))
    (ok (match (map-get? has-interacted user) interacted interacted false))
)

;; @notice Retorna o contador de interacoes de um usuario especifico
(define-read-only (get-interactions-count (user principal))
    (ok (match (map-get? interactions-count user) count count u0))
)

;; @notice Retorna o proximo token ID que sera mintado
(define-read-only (get-next-token-id)
    (ok (var-get token-counter))
)

;; private functions
;;
