;; title: simple-ping-pong
;; version: 1.0.0
;; summary: Interacoes ping/pong on-chain com contadores
;; description: Contrato que permite registrar pings e pongs com rastreamento de metricas

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; Total de pings registrados
(define-data-var total-pings uint u0)

;; Total de pongs registrados
(define-data-var total-pongs uint u0)

;; data maps
;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; Quantos pings cada endereco registrou
(define-map ping-count principal uint)

;; Quantos pongs cada endereco registrou
(define-map pong-count principal uint)

;; Timestamp do ultimo ping ou pong de cada endereco
(define-map last-action-at principal uint)

;; public functions
;; @notice Registra um ping e retorna PONG
(define-public (ping)
    (begin
        (let ((sender tx-sender))
            (begin
                ;; Registra interacao
                (register-interaction sender)
                ;; Incrementa ping count do usuario
                (let ((user-ping-count (match (map-get? ping-count sender) count
                    count
                    u0
                )))
                    (map-set ping-count sender (+ user-ping-count u1))
                )
                ;; Incrementa total de pings
                (var-set total-pings (+ (var-get total-pings) u1))
                ;; Atualiza timestamp da ultima acao
                (map-set last-action-at sender burn-block-height)
                (ok (some "PONG"))
            )
        )
    )
)

;; @notice Registra um pong e retorna PING
(define-public (pong)
    (begin
        (let ((sender tx-sender))
            (begin
                ;; Registra interacao
                (register-interaction sender)
                ;; Incrementa pong count do usuario
                (let ((user-pong-count (match (map-get? pong-count sender) count
                    count
                    u0
                )))
                    (map-set pong-count sender (+ user-pong-count u1))
                )
                ;; Incrementa total de pongs
                (var-set total-pongs (+ (var-get total-pongs) u1))
                ;; Atualiza timestamp da ultima acao
                (map-set last-action-at sender burn-block-height)
                (ok (some "PING"))
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

;; @notice Retorna contadores de ping/pong e timestamp da ultima acao do usuario atual
(define-read-only (my-ping-pong)
    (ok {
        pings: (match (map-get? ping-count tx-sender) count count u0),
        pongs: (match (map-get? pong-count tx-sender) count count u0),
        last-at: (match (map-get? last-action-at tx-sender) timestamp timestamp u0)
    })
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

