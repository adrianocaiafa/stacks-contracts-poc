;; title: simple-kudos
;; version: 1.0.0
;; summary: Envia kudos simples on-chain entre enderecos
;; description: Contrato que permite enviar kudos entre usuarios com rastreamento de metricas

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; Total de kudos enviados
(define-data-var total-kudos uint u0)

;; data maps
;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; Total de kudos que um usuario recebeu
(define-map kudos-received principal uint)

;; Total de kudos que um usuario enviou
(define-map kudos-sent principal uint)

;; public functions
;; @notice Envia 1 kudos para um endereco especifico
(define-public (give-kudos (to principal))
    (begin
        (let ((sender tx-sender))
            (begin
                ;; Valida endereco (nao pode enviar para si mesmo)
                (asserts! (not (is-eq to sender)) (err u1))
                ;; Registra interacao
                (register-interaction sender)
                ;; Incrementa kudos enviados pelo sender
                (let ((sender-kudos-sent (match (map-get? kudos-sent sender) count
                    count
                    u0
                )))
                    (map-set kudos-sent sender (+ sender-kudos-sent u1))
                )
                ;; Incrementa kudos recebidos pelo receiver
                (let ((receiver-kudos-received (match (map-get? kudos-received to) count
                    count
                    u0
                )))
                    (map-set kudos-received to (+ receiver-kudos-received u1))
                )
                ;; Incrementa total de kudos
                (var-set total-kudos (+ (var-get total-kudos) u1))
                (ok true)
            )
        )
    )
)

;; read only functions
;; @notice Quantas vezes o usuario atual interagiu com o contrato
(define-read-only (my-interactions)
    (ok (match (map-get? interactions-count tx-sender) count
        count
        u0
    ))
)

;; @notice Quantos kudos o usuario atual enviou
(define-read-only (my-kudos-sent)
    (ok (match (map-get? kudos-sent tx-sender) count
        count
        u0
    ))
)

;; @notice Quantos kudos o usuario atual recebeu
(define-read-only (my-kudos-received)
    (ok (match (map-get? kudos-received tx-sender) count
        count
        u0
    ))
)

;; @notice Retorna o total de usuarios unicos
(define-read-only (get-total-unique-users)
    (ok (var-get total-unique-users))
)

;; @notice Retorna o total de kudos enviados
(define-read-only (get-total-kudos)
    (ok (var-get total-kudos))
)

;; @notice Retorna quantos kudos um usuario enviou
(define-read-only (get-kudos-sent (user principal))
    (ok (match (map-get? kudos-sent user) count
        count
        u0
    ))
)

;; @notice Retorna quantos kudos um usuario recebeu
(define-read-only (get-kudos-received (user principal))
    (ok (match (map-get? kudos-received user) count
        count
        u0
    ))
)

;; @notice Verifica se um endereco ja interagiu
(define-read-only (get-has-interacted (user principal))
    (ok (match (map-get? has-interacted user) interacted
        interacted
        false
    ))
)

;; @notice Retorna quantas vezes um endereco interagiu
(define-read-only (get-interactions-count (user principal))
    (ok (match (map-get? interactions-count user) count
        count
        u0
    ))
)

;; private functions
;; @notice Registra uma interacao do usuario
(define-private (register-interaction (sender principal))
    (begin
        (match (map-get? has-interacted sender) already-interacted
            true
            (begin
                (map-set has-interacted sender true)
                (var-set total-unique-users (+ (var-get total-unique-users) u1))
            )
        )
        (let ((current-count (match (map-get? interactions-count sender) count
            count
            u0
        )))
            (map-set interactions-count sender (+ current-count u1))
        )
        true
    )
)

