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

;; read only functions
;;

;; private functions
;;
