# Justfile para automatizar la creación de notas con ZK

# Crear una nota TIL (Today I Learned / Hoy aprendí)
til titulo:
    #!/usr/bin/env bash
    note_path=$(zk new --no-input hoy-aprendi --title "{{titulo}}" --print-path)
    zk edit "$note_path"
    git add "$note_path"
    git commit -m "Agregar TIL: {{titulo}}"
    git push
    echo "Nota creada: $note_path"

# Crear un machete (cheat sheet)
mch titulo:
    #!/usr/bin/env bash
    note_path=$(zk new --no-input machetes --title "{{titulo}}" --print-path)
    zk edit "$note_path"
    git add "$note_path"
    git commit -m "Agregar machete: {{titulo}}"
    git push
    echo "Nota creada: $note_path"

# Crear una exploración
exp titulo:
    #!/usr/bin/env bash
    note_path=$(zk new --no-input exploraciones --title "{{titulo}}" --print-path)
    zk edit "$note_path"
    git add "$note_path"
    git commit -m "Agregar exploración: {{titulo}}"
    git push
    echo "Nota creada: $note_path"

# Crear una nota de "quiero" (things I want)
tiw titulo:
    #!/usr/bin/env bash
    note_path=$(zk new --no-input quiero --title "{{titulo}}" --print-path)
    zk edit "$note_path"
    git add "$note_path"
    git commit -m "Agregar cosa que quiero: {{titulo}}"
    git push
    echo "Nota creada: $note_path"

# Crear una idea
ida titulo:
    #!/usr/bin/env bash
    note_path=$(zk new --no-input ideas --title "{{titulo}}" --print-path)
    zk edit "$note_path"
    git add "$note_path"
    git commit -m "Agregar idea: {{titulo}}"
    git push
    echo "Nota creada: $note_path"

# Crear nota con IA - pasale el contenido y la categoría
ai-note categoria titulo contenido:
    #!/usr/bin/env bash
    set -euo pipefail
    # Mapear categoría a directorio
    case "{{categoria}}" in
        til) dir="hoy-aprendi";;
        mch) dir="machetes";;
        exp) dir="exploraciones";;
        tiw) dir="quiero";;
        ida) dir="ideas";;
        *) echo "Categoría no válida. Usa: til, mch, exp, tiw, ida"; exit 1;;
    esac
    # Generar contenido con IA
    echo "Generando nota con IA..."
    full_title="{{titulo}}"
    # Crear nota con zk (el template se toma automáticamente del grupo)
    note_path=$(zk new --no-input "$dir" --title "$full_title" --print-path)
    # Usar Claude API para generar contenido estructurado
    if command -v claude &> /dev/null; then
        # Si tienes el CLI de Claude instalado
        prompt="Crea una nota en formato org-mode sobre: {{contenido}}. Usa el título: $full_title. Incluye secciones relevantes y contenido útil."
        claude --model sonnet-4.5 "$prompt" >> "$note_path"
    else
        # Fallback: agregar el contenido directamente
        echo -e "\n** Contenido\n\n{{contenido}}" >> "$note_path"
    fi
    # Commit y push
    git add "$note_path"
    git commit -m "Agregar nota generada con IA: {{titulo}}"
    git push
    echo "Nota creada en: $note_path"

# Editar una nota (usa zk edit con búsqueda interactiva)
edit query="":
    #!/usr/bin/env bash
    if [ -z "{{query}}" ]; then
        # Sin query, abre selector interactivo
        note=$(zk list --format path | fzf --preview 'cat {}')
    else
        # Con query, busca y edita
        note=$(zk list --match "{{query}}" --format path --limit 1)
    fi
    if [ -n "$note" ]; then
        zk edit "$note"
        git add "$note"
        git commit -m "Actualizar: $(basename $note)"
        git push
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
