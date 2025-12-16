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
                (try! (register-user sender))
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

;; @notice Duelo simples entre usuarios - quem tem mais pontos ganha
(define-public (duel (opponent principal) (amount uint))
    (begin
        (asserts! (is-some (some opponent)) (err u2))
        (asserts! (not (is-eq opponent tx-sender)) (err u3))
        (let ((sender tx-sender))
            (begin
                ;; Verifica se tem pontos suficientes
                (let ((sender-points (match (map-get? points sender) pts pts u0))
                      (opponent-points (match (map-get? points opponent) pts pts u0)))
                    (begin
                        (asserts! (>= sender-points amount) (err u4))
                        (asserts! (>= opponent-points amount) (err u5))
                        ;; Registra usuario se for primeira interacao
                        (try! (register-user sender))
                        ;; Se empate, nao faz nada
                        (if (is-eq sender-points opponent-points)
                            (ok true)
                            (begin
                                ;; Determina vencedor e perdedor
                                (let ((winner (if (> sender-points opponent-points) sender opponent))
                                      (loser (if (> sender-points opponent-points) opponent sender)))
                                    (begin
                                        ;; Vencedor ganha +amount, perdedor perde -amount
                                        (map-set points winner (+ (match (map-get? points winner) pts pts u0) amount))
                                        (let ((loser-current (match (map-get? points loser) pts pts u0)))
                                            (if (>= loser-current amount)
                                                (map-set points loser (- loser-current amount))
                                                (map-set points loser u0)
                                            )
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
)

;; read only functions
;; @notice Retorna os pontos do usuario atual
(define-read-only (my-points)
    (ok (match (map-get? points tx-sender) pts pts u0))
)

;; @notice Retorna quantas vezes voce interagiu com este contrato
(define-read-only (my-interactions)
    (ok (match (map-get? interactions-count tx-sender) count count u0))
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

;; @notice Retorna os pontos de um usuario especifico
(define-read-only (get-points (user principal))
    (ok (match (map-get? points user) pts pts u0))
)

;; @notice Retorna o numero de participantes
(define-read-only (get-participants-count)
    (ok (var-get participants-count))
)

;; @notice Retorna um participante pelo indice
(define-read-only (get-participant (index uint))
    (ok (map-get? participants index))
)

;; @notice Retorna pontos e participante de um indice (para leaderboard)
(define-read-only (get-participant-with-points (index uint))
    (match (map-get? participants index) participant
        (ok (some {
            user: participant,
            points: (match (map-get? points participant) pts pts u0)
        }))
        (ok none)
    )
)

;; private functions
;; @notice Registra um usuario (adiciona a lista de participantes se for primeira vez)
(define-private (register-user (user principal))
    (begin
        ;; Se e a primeira interacao, adiciona a lista de participantes
        (match (map-get? has-interacted user) already-interacted
            true
            (begin
                (map-set has-interacted user true)
                (var-set total-unique-users (+ (var-get total-unique-users) u1))
                ;; Adiciona a lista de participantes
                (let ((next-index (var-get participants-count)))
                    (begin
                        (map-set participants next-index user)
                        (var-set participants-count (+ next-index u1))
                    )
                )
            )
        )
        ;; Incrementa contador de interacoes
        (let ((current-count (match (map-get? interactions-count user) count
            count
            u0
        )))
            (map-set interactions-count user (+ current-count u1))
        )
        (ok true)
    )
)
