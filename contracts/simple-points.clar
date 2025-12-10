;; title: simple-points
;; version: 1.0.0
;; summary: Sistema simples de pontos on-chain + contagem de usuarios unicos
;; description: Contrato que permite ganhar e transferir pontos entre usuarios

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; data maps
;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; Pontos de cada endereco
(define-map points principal uint)

;; public functions
;; @notice Ganhe pontos simplesmente interagindo
(define-public (gain-points (amount uint))
    (begin
        (asserts! (> amount u0) (err u1))
        (let ((sender tx-sender))
            (begin
                ;; Contar usuario unico uma vez
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

