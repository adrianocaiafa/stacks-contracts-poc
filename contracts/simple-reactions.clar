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
;;

;; read only functions
;;

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

