;; title: simple-status
;; version: 1.0.0
;; summary: Sistema de status on-chain por usuario
;; description: Contrato que permite definir e limpar uma mensagem de status on-chain

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

;; Status de cada usuario (string de ate 280 caracteres)
(define-map status principal (string-ascii 280))

;; public functions
;; @notice Define ou atualiza sua mensagem de status on-chain
(define-public (set-status (new-status (string-ascii 280)))
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
            ;; Define o status
            (map-set status sender new-status)
            (ok true)
        )
    )
)

;; @notice Limpa seu status atual
(define-public (clear-status)
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
            ;; Remove o status
            (map-delete status sender)
            (ok true)
        )
    )
)

;; read only functions
;; @notice Retorna quantas vezes voce interagiu com este contrato
(define-read-only (my-interactions)
    (ok (match (map-get? interactions-count tx-sender) count count u0))
)

;; @notice Retorna sua string de status atual
(define-read-only (my-status)
    (ok (match (map-get? status tx-sender) status-value 
        (some status-value)
        none
    ))
)

;; @notice Retorna o total de usuarios unicos
(define-read-only (get-total-unique-users)
    (ok (var-get total-unique-users))
)

;; @notice Retorna o status de um usuario especifico
(define-read-only (get-status (user principal))
    (ok (match (map-get? status user) status-value 
        (some status-value)
        none
    ))
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
