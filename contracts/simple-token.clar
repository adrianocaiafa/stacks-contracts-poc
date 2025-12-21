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
;; @notice Transfere tokens de um usuario para outro
(define-public (transfer (to principal) (amount uint))
    (begin
        (asserts! (> amount u0) (err u1))
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
                        (asserts! (>= sender-balance amount) (err u2))
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

;; @notice Cunha novos tokens para um endereco
(define-public (mint (to principal) (amount uint))
    (begin
        (asserts! (> amount u0) (err u3))
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
                ;; Cunha tokens
                (let ((receiver-balance (match (map-get? balances to) bal bal u0)))
                    (map-set balances to (+ receiver-balance amount))
                )
                ;; Atualiza supply total
                (var-set total-supply (+ (var-get total-supply) amount))
                (ok true)
            )
        )
    )
)

;; read only functions
;;

;; private functions
;;
