;; title: simple-flag
;; version: 1.0.0
;; summary: Flag booleana on-chain por usuario
;; description: Contrato que permite definir e alternar uma flag booleana on-chain

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Total de usuarios unicos que interagiram com o contrato
(define-data-var total-unique-users uint u0)

;; data maps
;; Indica se um endereco ja interagiu com o contrato
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)

;; Flag booleana de cada usuario
(define-map flag principal bool)

;; public functions
;; @notice Define explicitamente o valor da flag (true ou false)
(define-public (set-flag (value bool))
    (let ((sender tx-sender))
        (begin
            ;; Conta usuario unico se for a primeira interacao
            (match (map-get? has-interacted sender) already-interacted
                true
                (begin
                    (map-set has-interacted sender true)
                    (var-set total-unique-users (+ (var-get total-unique-users) u1))
                )
            )
            ;; Incrementa contador de interacoes
            (let ((current-count (match (map-get? interactions-count sender) count
                count
                u0
            )))
                (map-set interactions-count sender (+ current-count u1))
            )
            ;; Define a flag
            (map-set flag sender value)
            (ok true)
        )
    )
)

;; @notice Alterna o valor atual da flag
(define-public (toggle-flag)
    (let ((sender tx-sender))
        (begin
            ;; Conta usuario unico se for a primeira interacao
            (match (map-get? has-interacted sender) already-interacted
                true
                (begin
                    (map-set has-interacted sender true)
                    (var-set total-unique-users (+ (var-get total-unique-users) u1))
                )
            )
            ;; Incrementa contador de interacoes
            (let ((current-count (match (map-get? interactions-count sender) count
                count
                u0
            )))
                (map-set interactions-count sender (+ current-count u1))
            )
            ;; Alterna o valor da flag
            (let ((current-flag (match (map-get? flag sender) flag-value flag-value false)))
                (map-set flag sender (not current-flag))
            )
            (ok true)
        )
    )
)

;; read only functions
;; @notice Retorna quantas vezes voce interagiu com este contrato
(define-read-only (my-interactions)
    (ok (match (map-get? interactions-count tx-sender) count count u0))
)

;; @notice Retorna o valor atual da sua flag
(define-read-only (my-flag)
    (ok (match (map-get? flag tx-sender) flag-value flag-value false))
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

;; @notice Retorna a flag de um usuario especifico
(define-read-only (get-flag (user principal))
    (ok (match (map-get? flag user) flag-value flag-value false))
)

;; private functions
;;
