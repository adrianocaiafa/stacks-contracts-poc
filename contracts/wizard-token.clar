;; title: wizard-token
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

;; Total de usuarios unicos que interagiram com o contrato
(define-data-var total-unique-users uint u0)

;; data maps
;; Indica se um endereco ja interagiu com o contrato
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)
;; Balanco de tokens de cada usuario
(define-map balances principal uint)

;; Indica se um usuario ja fez claim
(define-map has-claimed principal bool)

;; public functions
;; @notice Permite que cada usuario reivindique uma quantidade fixa de tokens uma vez
(define-public (claim)
    (let ((sender tx-sender))
        (begin
            ;; Valida que o usuario ainda nao fez claim
            (asserts! (not (match (map-get? has-claimed sender) claimed claimed false)) (err u1))
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
            ;; Marca como claimed
            (map-set has-claimed sender true)
            ;; Cunha os tokens
            (let ((receiver-balance (match (map-get? balances sender) bal bal u0)))
                (map-set balances sender (+ receiver-balance CLAIM_AMOUNT))
            )
            ;; Atualiza supply total
            (var-set total-supply (+ (var-get total-supply) CLAIM_AMOUNT))
            (ok true)
        )
    )
)

;; @notice Transfere tokens de um usuario para outro
(define-public (transfer (to principal) (amount uint))
    (begin
        (asserts! (> amount u0) (err u2))
        (let ((sender tx-sender))
            (begin
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
                ;; Verifica se tem saldo suficiente
                (let ((sender-balance (match (map-get? balances sender) bal bal u0)))
                    (begin
                        (asserts! (>= sender-balance amount) (err u3))
                        ;; Transfere tokens
                        (map-set balances sender (- sender-balance amount))
                        (let ((receiver-balance (match (map-get? balances to) bal bal u0)))
                            (map-set balances to (+ receiver-balance amount))
                        )
                        (ok true)
                    )
                )
            )
        )
    )
)

;; read only functions
;; @notice Retorna o balanco de tokens do usuario atual
(define-read-only (get-balance)
    (ok (match (map-get? balances tx-sender) bal bal u0))
)

;; @notice Retorna o balanco de tokens de um usuario especifico
(define-read-only (get-balance-of (user principal))
    (ok (match (map-get? balances user) bal bal u0))
)

;; @notice Retorna o supply total de tokens
(define-read-only (get-total-supply)
    (ok (var-get total-supply))
)

;; @notice Retorna o nome do token
(define-read-only (get-name)
    (ok TOKEN_NAME)
)

;; @notice Retorna o simbolo do token
(define-read-only (get-symbol)
    (ok TOKEN_SYMBOL)
)

;; @notice Retorna os decimais do token
(define-read-only (get-decimals)
    (ok TOKEN_DECIMALS)
)

;; @notice Retorna se o usuario atual ja fez claim
(define-read-only (my-has-claimed)
    (ok (match (map-get? has-claimed tx-sender) claimed claimed false))
)

;; @notice Retorna se um usuario especifico ja fez claim
(define-read-only (has-user-claimed (user principal))
    (ok (match (map-get? has-claimed user) claimed claimed false))
)

;; @notice Retorna a quantidade de tokens do claim
(define-read-only (get-claim-amount)
    (ok CLAIM_AMOUNT)
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

;; private functions
;;
