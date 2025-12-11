;; title: simple-level-up
;; version: 1.0.0
;; summary: Sistema de XP + Niveis + Leaderboard automatico
;; description: Contrato que permite ganhar XP, subir de nivel e manter um leaderboard dos top 5

;; traits
;;

;; token definitions
;;

;; constants
;; XP necessario para subir de nivel
(define-constant XP_PER_LEVEL u100)

;; data vars
;; Total de usuarios unicos que ja interagiram
(define-data-var total-unique-users uint u0)

;; data maps
;; Marca se um endereco ja interagiu pelo menos 1 vez
(define-map has-interacted principal bool)

;; Quantas vezes cada endereco ja interagiu
(define-map interactions-count principal uint)

;; XP de cada endereco
(define-map xp principal uint)

;; Nivel de cada endereco
(define-map level principal uint)

;; Leaderboard dos 5 maiores niveis (indice 0-4)
(define-map top-levels uint principal)
;; Contador para saber quantos usuarios estao no top 5
(define-data-var top-levels-count uint u0)
;; Marca se um endereco esta no top 5
(define-map is-in-top5 principal bool)

;; public functions
;; @notice Ganhe XP e suba de nivel automaticamente
(define-public (gain-xp (amount uint))
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
                ;; Adiciona XP
                (let ((current-xp (match (map-get? xp sender) xp-amount
                    xp-amount
                    u0
                )))
                    (let ((new-xp (+ current-xp amount)))
                        (map-set xp sender new-xp)
                        ;; Calcula novo nivel
                        (let ((new-level (/ new-xp XP_PER_LEVEL)))
                            (let ((current-level (match (map-get? level sender) lvl
                                lvl
                                u0
                            )))
                                (if (> new-level current-level)
                                    (begin
                                        (map-set level sender new-level)
                                        (ok true)
                                    )
                                    (ok true)
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)

;; read only functions
;;

;; private functions
;;

