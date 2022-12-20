# Поиск узла дерева на Oberon-2

```
MODULE Trees;

IMPORT Texts, Oberon;

TYPE
    Tree* = POINTER TO Node;  (* star denotes export, not pointer! *)
    Node* = RECORD
        name-: POINTER TO ARRAY OF CHAR;  (* minus denotes read-only export *)
        left, right: Tree
    END;

PROCEDURE (t: Tree) Lookup* (name: ARRAY OF CHAR): Tree;
    VAR p: Tree;
BEGIN p := t;
    WHILE (p # NIL) & (name # p.name^) DO
        IF name < p.name^ THEN p := p.left ELSE p := p.right END
    END;
    RETURN p
END Lookup;

...
```