;; title: simple-reactions
;; version: 1.0.0
;; summary: Sistema de like/dislike para um item compartilhado
;; description: Contrato que permite reagir com like ou dislike a um item unico

;; traits
;;

;; token definitions
;;

;; constants
;; Valores de reacao: -1 = dislike, 0 = nenhuma, 1 = like
(define-constant REACTION_DISLIKE i128 -1)
(define-constant REACTION_NONE i128 0)
(define-constant REACTION_LIKE i128 1)

;; data vars
;; Total de likes
(define-data-var likes uint u0)

;; Total de dislikes
(define-data-var dislikes uint u0)

;; data maps
;; Reacao de cada endereco (-1 = dislike, 0 = nenhuma, 1 = like)
(define-map reactions principal int128)

;; public functions
;; @notice Define reacao como like
(define-public (like)
    (begin
        (set-reaction tx-sender REACTION_LIKE)
        (ok true)
    )
)

;; @notice Define reacao como dislike
(define-public (dislike)
    (begin
        (set-reaction tx-sender REACTION_DISLIKE)
        (ok true)
    )
)

;; @notice Remove reacao (define como nenhuma)
(define-public (clear-reaction)
    (begin
        (set-reaction tx-sender REACTION_NONE)
        (ok true)
    )
)

;; read only functions
;; @notice Retorna o total de likes
(define-read-only (get-likes)
    (ok (var-get likes))
)

;; @notice Retorna o total de dislikes
(define-read-only (get-dislikes)
    (ok (var-get dislikes))
)

;; @notice Retorna a reacao do usuario atual
(define-read-only (my-reaction)
    (ok (match (map-get? reactions tx-sender) reaction
        reaction
        REACTION_NONE
    ))
)

;; @notice Retorna a reacao de um usuario especifico
(define-read-only (get-reaction (user principal))
    (ok (match (map-get? reactions user) reaction
        reaction
        REACTION_NONE
    ))
)

;; @notice Retorna estatisticas completas (likes, dislikes e total)
(define-read-only (get-stats)
    (ok {
        likes: (var-get likes),
        dislikes: (var-get dislikes),
        total: (+ (var-get likes) (var-get dislikes))
    })
)

;; private functions
;; @notice Define uma reacao para um usuario
(define-private (set-reaction (sender principal) (new-reaction int128))
    (begin
        ;; Valida reacao
        (asserts! (and (>= new-reaction REACTION_DISLIKE) (<= new-reaction REACTION_LIKE)) (err u1))
        ;; Obtem reacao antiga
        (let ((old-reaction (match (map-get? reactions sender) reaction
            reaction
            REACTION_NONE
        )))
            ;; Se a reacao nao mudou, nao faz nada
            (if (is-eq old-reaction new-reaction)
                true
                (begin
                    ;; Remove reacao antiga dos contadores
                    (if (is-eq old-reaction REACTION_LIKE)
                        (var-set likes (- (var-get likes) u1))
                        (if (is-eq old-reaction REACTION_DISLIKE)
                            (var-set dislikes (- (var-get dislikes) u1))
                            true
                        )
                    )
                    ;; Aplica nova reacao
                    (map-set reactions sender new-reaction)
                    ;; Adiciona nova reacao aos contadores
                    (if (is-eq new-reaction REACTION_LIKE)
                        (var-set likes (+ (var-get likes) u1))
                        (if (is-eq new-reaction REACTION_DISLIKE)
                            (var-set dislikes (+ (var-get dislikes) u1))
                            true
                        )
                    )
                    true
                )
            )
        )
    )
)

