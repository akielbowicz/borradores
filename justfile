# Justfile para automatizar la creación de notas con ZK

# Helper interno: commit y push de una nota
[private]
_commit path mensaje:
    @git add "{{path}}"
    @git commit -m "{{mensaje}}"
    @git push
    @echo "Nota sincronizada: {{path}}"

# Crear una nota TIL (Today I Learned / Hoy aprendí)
til titulo:
    #!/usr/bin/env bash
    note_path=$(zk new --no-input -g til hoy-aprendi --title "{{titulo}}" --print-path)
    zk edit "$note_path"
    just _commit "$note_path" "Agregar TIL: {{titulo}}"

# Crear un machete (cheat sheet)
mch titulo:
    #!/usr/bin/env bash
    note_path=$(zk new --no-input -g mch machetes --title "{{titulo}}" --print-path)
    zk edit "$note_path"
    just _commit "$note_path" "Agregar machete: {{titulo}}"

# Crear una exploración
exp titulo:
    #!/usr/bin/env bash
    note_path=$(zk new --no-input -g exp exploraciones --title "{{titulo}}" --print-path)
    zk edit "$note_path"
    just _commit "$note_path" "Agregar exploración: {{titulo}}"

# Crear una nota de "quiero" (things I want)
tiw titulo:
    #!/usr/bin/env bash
    note_path=$(zk new --no-input -g tiw quiero --title "{{titulo}}" --print-path)
    zk edit "$note_path"
    just _commit "$note_path" "Agregar cosa que quiero: {{titulo}}"

# Crear una idea
ida titulo:
    #!/usr/bin/env bash
    note_path=$(zk new --no-input -g ida ideas --title "{{titulo}}" --print-path)
    zk edit "$note_path"
    just _commit "$note_path" "Agregar idea: {{titulo}}"

# Crear nota con IA - pasale el contenido y la categoría
ai-note categoria titulo contenido:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{categoria}}" in
        til) dir="hoy-aprendi"; group="til";;
        mch) dir="machetes"; group="mch";;
        exp) dir="exploraciones"; group="exp";;
        tiw) dir="quiero"; group="tiw";;
        ida) dir="ideas"; group="ida";;
        *) echo "Categoría no válida. Usa: til, mch, exp, tiw, ida"; exit 1;;
    esac
    echo "Generando nota con IA..."
    note_path=$(zk new --no-input -g "$group" "$dir" --title "{{titulo}}" --print-path)
    if command -v claude &> /dev/null; then
        prompt="Crea una nota en formato org-mode sobre: {{contenido}}. Usa el título: {{titulo}}. Incluye secciones relevantes y contenido útil."
        claude --model sonnet-4.5 "$prompt" >> "$note_path"
    else
        echo -e "\n** Contenido\n\n{{contenido}}" >> "$note_path"
    fi
    just _commit "$note_path" "Agregar nota IA: {{titulo}}"

# Editar una nota (usa zk edit con búsqueda interactiva)
edit query="":
    #!/usr/bin/env bash
    if [ -z "{{query}}" ]; then
        note=$(zk list --format path | fzf --preview 'cat {}')
    else
        note=$(zk list --match "{{query}}" --format path --limit 1)
    fi
    if [ -n "$note" ]; then
        zk edit "$note"
        just _commit "$note" "Actualizar: $(basename $note)"
    fi

# Sincronizar cambios (útil después de ediciones manuales)
sync mensaje="Actualizar notas":
    @git add -A
    @git commit -m "{{mensaje}}"
    @git push

# Ver el estado del repositorio
status:
    @git status

# Listar notas recientes usando zk
list filtro="":
    @zk list --sort created- --limit 20 {{filtro}}

# Buscar notas por contenido
search query:
    @zk list --match "{{query}}" --format full

# Ayuda - mostrar comandos disponibles
help:
    @echo "Comandos disponibles:"
    @echo "  just til TITULO          - Crear TIL"
    @echo "  just mch TITULO          - Crear machete"
    @echo "  just exp TITULO          - Crear exploración"
    @echo "  just tiw TITULO          - Crear 'quiero'"
    @echo "  just ida TITULO          - Crear idea"
    @echo "  just ai-note CAT TITULO CONTENIDO - Crear nota con IA"
    @echo "  just edit [QUERY]        - Editar nota (interactivo o por búsqueda)"
    @echo "  just sync [MENSAJE]      - Sincronizar cambios"
    @echo "  just status              - Ver estado git"
    @echo "  just list [FILTRO]       - Listar notas recientes"
    @echo "  just search QUERY        - Buscar notas por contenido"
