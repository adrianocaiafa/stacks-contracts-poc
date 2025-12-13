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
;;

;; read only functions
;;

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

