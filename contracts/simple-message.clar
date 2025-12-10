;; title: simple-message
;; version: 1.0.0
;; summary: Conta quantos enderecos unicos interagiram com o contrato
;; description: Contrato que permite enviar mensagens on-chain e rastreia interacoes de usuarios unicos

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

;; Guarda a ultima mensagem enviada por cada endereco
(define-map last-message principal (string-ascii 1000))

;; Guarda TODAS as mensagens em lista (usando map com indice)
(define-map message-feed uint (string-ascii 1000))
(define-data-var message-feed-count uint u0)

;; public functions
;; @notice Envia uma mensagem on-chain
;; @dev Isso GERA transacao real e altera storage
(define-public (post-message (message (string-ascii 1000)))
    (begin
        (asserts! (> (len message) u0) (err u1))
        (let ((sender tx-sender))
            (begin
                ;; Conta usuario unico se for a primeira interacao
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
                ;; Guarda a ultima mensagem enviada pelo usuario
                (map-set last-message sender message)
                ;; Armazena no feed global
                (let ((current-count (var-get message-feed-count)))
                    (begin
                        (map-set message-feed current-count message)
                        (var-set message-feed-count (+ current-count u1))
                    )
                )
                (ok true)
            )
        )
    )
)

;; read only functions
;; @notice Quantas mensagens totais foram enviadas?
(define-read-only (total-messages)
    (ok (var-get message-feed-count))
)

;; @notice Retorna o total de usuarios unicos
(define-read-only (get-total-unique-users)
    (ok (var-get total-unique-users))
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

;; @notice Retorna a ultima mensagem de um endereco
(define-read-only (get-last-message (user principal))
    (ok (map-get? last-message user))
)

;; @notice Retorna uma mensagem especifica do feed pelo indice
(define-read-only (get-message-by-index (index uint))
    (ok (map-get? message-feed index))
)

;; @notice Helper pra ver quantas vezes VOCE ja chamou o contrato
(define-read-only (my-interactions)
    (ok (match (map-get? interactions-count tx-sender) count
        count
        u0
    ))
)

;; private functions
;;

