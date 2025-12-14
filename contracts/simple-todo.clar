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
;;

;; data maps
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
;;

;; read only functions
;;

;; private functions
;;
