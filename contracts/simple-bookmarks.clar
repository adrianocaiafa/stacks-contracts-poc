;; title: simple-bookmarks
;; version: 1.0.0
;; summary: Bookmark on-chain por usuario (URL ou referencia)
;; description: Contrato que permite salvar e limpar um bookmark on-chain

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;; Total de usuarios unicos que interagiram com o contrato
(define-data-var total-unique-users uint u0)

;; data maps
;; Indica se um endereco ja interagiu com o contrato
(define-map has-interacted principal bool)

;; Contador de interacoes por usuario
(define-map interactions-count principal uint)

;; Bookmark de cada usuario (string de ate 500 caracteres)
(define-map bookmark principal (string-ascii 500))

;; public functions
;; @notice Salva ou atualiza seu bookmark on-chain (URL, handle, etc.)
(define-public (save-bookmark (url (string-ascii 500)))
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
            ;; Salva o bookmark
            (map-set bookmark sender url)
            (ok true)
        )
    )
)

;; read only functions
;;

;; private functions
;;
