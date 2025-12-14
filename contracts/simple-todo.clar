;; title: simple-todo
;; version: 1.0.0
;; summary: Lista de tarefas simples por usuario
;; description: Contrato que permite criar, marcar como concluida e deletar tarefas

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

;; Contador de tarefas por usuario
(define-map task-count principal uint)

;; Tarefas: (usuario, id) -> {id: uint, text: string, done: bool, deleted: bool}
(define-map tasks (tuple (user principal) (id uint)) 
    (tuple 
        (id uint)
        (text (string-ascii 500))
        (done bool)
        (deleted bool)
    )
)

;; public functions
;; @notice Adiciona uma nova tarefa
(define-public (add-task (text (string-ascii 500)))
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
            ;; Obtem o proximo ID de tarefa
            (let ((next-id (match (map-get? task-count sender) count count u0)))
                (begin
                    ;; Cria a nova tarefa
                    (map-set tasks (tuple (user sender) (id next-id)) 
                        (tuple 
                            (id next-id)
                            (text text)
                            (done false)
                            (deleted false)
                        )
                    )
                    ;; Incrementa contador de tarefas
                    (map-set task-count sender (+ next-id u1))
                    (ok true)
                )
            )
        )
    )
)

;; @notice Alterna o estado de conclusao de uma tarefa
(define-public (toggle-done (id uint))
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
            ;; Obtem a tarefa
            (let ((task-key (tuple (user sender) (id id))))
                (match (map-get? tasks task-key) task
                    (begin
                        (asserts! (not (get deleted task)) (err u1))
                        ;; Alterna o estado done
                        (map-set tasks task-key 
                            (tuple 
                                (id (get id task))
                                (text (get text task))
                                (done (not (get done task)))
                                (deleted (get deleted task))
                            )
                        )
                        (ok true)
                    )
                    (err u2)
                )
            )
        )
    )
)

;; read only functions
;;

;; private functions
;;
