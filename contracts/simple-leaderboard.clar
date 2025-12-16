;; title: simple-leaderboard
;; version: 1.0.0
;; summary: Sistema simples de leaderboard com pontos e duelos
;; description: Contrato que permite ganhar pontos, duelar e consultar leaderboard

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Total de usuarios unicos que interagiram com o contrato
(define-data-var total-unique-users uint u0)

;; Contador de participantes (para lista indexada)
(define-data-var participants-count uint u0)

;; data maps
;; Indica se um endereco ja interagiu com o contrato
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)

;; Pontos de cada usuario
(define-map points principal uint)

;; Lista de participantes indexada (indice -> principal)
(define-map participants uint principal)

;; public functions
;; @notice Ganha pontos simplesmente interagindo
(define-public (gain-points (amount uint))
    (begin
        (asserts! (> amount u0) (err u1))
        (let ((sender tx-sender))
            (begin
                ;; Registra usuario se for primeira interacao
                (register-user sender)
                ;; Adiciona pontos
                (let ((current-points (match (map-get? points sender) pts
                    pts
                    u0
                )))
                    (map-set points sender (+ current-points amount))
                )
                (ok true)
            )
        )
    )
)

;; read only functions
;;

;; private functions
;;
