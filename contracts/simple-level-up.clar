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
                                        ;; Atualiza leaderboard
                                        (update-top5 sender new-level)
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
;; @notice Retorna quantas vezes o usuario atual interagiu
(define-read-only (my-interactions)
    (ok (match (map-get? interactions-count tx-sender) count
        count
        u0
    ))
)

;; @notice Retorna o XP do usuario atual
(define-read-only (my-xp)
    (ok (match (map-get? xp tx-sender) xp-amount
        xp-amount
        u0
    ))
)

;; @notice Retorna o nivel do usuario atual
(define-read-only (my-level)
    (ok (match (map-get? level tx-sender) lvl
        lvl
        u0
    ))
)

;; @notice Retorna o total de usuarios unicos
(define-read-only (get-total-unique-users)
    (ok (var-get total-unique-users))
)

;; @notice Retorna o XP de um usuario especifico
(define-read-only (get-xp (user principal))
    (ok (match (map-get? xp user) xp-amount
        xp-amount
        u0
    ))
)

;; @notice Retorna o nivel de um usuario especifico
(define-read-only (get-level (user principal))
    (ok (match (map-get? level user) lvl
        lvl
        u0
    ))
)

;; @notice Retorna o usuario na posicao do leaderboard (0-4)
(define-read-only (get-top-level-user (position uint))
    (ok (map-get? top-levels position))
)

;; @notice Retorna quantos usuarios estao no top 5
(define-read-only (get-top-levels-count)
    (ok (var-get top-levels-count))
)

;; @notice Verifica se um endereco esta no top 5
(define-read-only (get-is-in-top5 (user principal))
    (ok (match (map-get? is-in-top5 user) in-top5
        in-top5
        false
    ))
)

;; private functions
;; @notice Atualiza o leaderboard top 5 com o novo usuario
(define-private (update-top5 (user principal) (user-level uint))
    (begin
        ;; Se ja esta no top 5, nao precisa atualizar
        (match (map-get? is-in-top5 user) already-in-top5
            true
            (begin
                ;; Verifica cada posicao do leaderboard
                (let ((current-count (var-get top-levels-count)))
                    (if (< current-count u5)
                        ;; Se tem menos de 5 usuarios, adiciona no final
                        (begin
                            (map-set top-levels current-count user)
                            (map-set is-in-top5 user true)
                            (var-set top-levels-count (+ current-count u1))
                            true
                        )
                        ;; Se tem 5 usuarios, verifica se deve entrar
                        (begin
                            ;; Verifica posicao 0
                            (match (map-get? top-levels u0) pos0-user
                                (begin
                                    (let ((pos0-level (match (map-get? level pos0-user) lvl
                                        lvl
                                        u0
                                    )))
                                        (if (> user-level pos0-level)
                                            (begin
                                                ;; Move todos para baixo e insere na posicao 0
                                                (map-set top-levels u4 (unwrap! (map-get? top-levels u3) tx-sender))
                                                (map-set top-levels u3 (unwrap! (map-get? top-levels u2) tx-sender))
                                                (map-set top-levels u2 (unwrap! (map-get? top-levels u1) tx-sender))
                                                (map-set top-levels u1 (unwrap! (map-get? top-levels u0) tx-sender))
                                                (map-set top-levels u0 user)
                                                (map-set is-in-top5 user true)
                                                true
                                            )
                                            ;; Verifica posicao 1
                                            (begin
                                                (match (map-get? top-levels u1) pos1-user
                                                    (begin
                                                        (let ((pos1-level (match (map-get? level pos1-user) lvl
                                                            lvl
                                                            u0
                                                        )))
                                                            (if (> user-level pos1-level)
                                                                (begin
                                                                    (map-set top-levels u4 (unwrap! (map-get? top-levels u3) tx-sender))
                                                                    (map-set top-levels u3 (unwrap! (map-get? top-levels u2) tx-sender))
                                                                    (map-set top-levels u2 (unwrap! (map-get? top-levels u1) tx-sender))
                                                                    (map-set top-levels u1 user)
                                                                    (map-set is-in-top5 user true)
                                                                    true
                                                                )
                                                                ;; Verifica posicao 2
                                                                (begin
                                                                    (match (map-get? top-levels u2) pos2-user
                                                                        (begin
                                                                            (let ((pos2-level (match (map-get? level pos2-user) lvl
                                                                                lvl
                                                                                u0
                                                                            )))
                                                                                (if (> user-level pos2-level)
                                                                                    (begin
                                                                                        (map-set top-levels u4 (unwrap! (map-get? top-levels u3) tx-sender))
                                                                                        (map-set top-levels u3 (unwrap! (map-get? top-levels u2) tx-sender))
                                                                                        (map-set top-levels u2 user)
                                                                                        (map-set is-in-top5 user true)
                                                                                        true
                                                                                    )
                                                                                    ;; Verifica posicao 3
                                                                                    (begin
                                                                                        (match (map-get? top-levels u3) pos3-user
                                                                                            (begin
                                                                                                (let ((pos3-level (match (map-get? level pos3-user) lvl
                                                                                                    lvl
                                                                                                    u0
                                                                                                )))
                                                                                                    (if (> user-level pos3-level)
                                                                                                        (begin
                                                                                                            (map-set top-levels u4 (unwrap! (map-get? top-levels u3) tx-sender))
                                                                                                            (map-set top-levels u3 user)
                                                                                                            (map-set is-in-top5 user true)
                                                                                                            true
                                                                                                        )
                                                                                                        ;; Verifica posicao 4
                                                                                                        (begin
                                                                                                            (match (map-get? top-levels u4) pos4-user
                                                                                                                (begin
                                                                                                                    (let ((pos4-level (match (map-get? level pos4-user) lvl
                                                                                                                        lvl
                                                                                                                        u0
                                                                                                                    )))
                                                                                                                        (if (> user-level pos4-level)
                                                                                                                            (begin
                                                                                                                                (map-set top-levels u4 user)
                                                                                                                                (map-set is-in-top5 user true)
                                                                                                                                true
                                                                                                                            )
                                                                                                                            false
                                                                                                                        )
                                                                                                                    )
                                                                                                                )
                                                                                                                false
                                                                                                            )
                                                                                                        )
                                                                                                    )
                                                                                                )
                                                                                            )
                                                                                            false
                                                                                        )
                                                                                    )
                                                                                )
                                                                            )
                                                                        )
                                                                        false
                                                                    )
                                                                )
                                                            )
                                                        )
                                                    )
                                                    false
                                                )
                                            )
                                        )
                                    )
                                )
                                false
                            )
                        )
                    )
                )
            )
        )
    )
)

