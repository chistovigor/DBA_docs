#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Конфигурация
# ==============================
REMOTE_URI="mongodb://user:pass@remote-mongo.example.com:27017/dbname"
LOCAL_URI="mongodb://ferret:ferret@127.0.0.1:27017/dbname"
DB_NAME="dbname"
DUMP_DIR="/tmp/mongo_dump"
REPORT_JSON="./migration_report.json"
REPORT_HTML="./migration_report.html"

# ==============================
# Утилиты логирования
# ==============================
log()   { echo -e "\033[1;32m[INFO]\033[0m $1"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# ==============================
# Проверки окружения
# ==============================
check_tools() {
  for cmd in docker mongodump mongorestore mongosh jq; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      error "Не найдено: $cmd. Установите и повторите попытку."
      exit 1
    fi
  done
}

# ==============================
# Старт FerretDB (eval-образ)
# ==============================
start_ferret() {
  if ! docker ps --format '{{.Names}}' | grep -q "^ferretdb-eval$"; then
    log "Запуск FerretDB контейнера (ghcr.io/ferretdb/ferretdb-eval:2)..."
    docker run -d --name ferretdb-eval \
      -p 27017:27017 \
      -e POSTGRES_USER=ferret \
      -e POSTGRES_PASSWORD=ferret \
      -v "$PWD/pgdata:/var/lib/postgresql/data" \
      ghcr.io/ferretdb/ferretdb-eval:2
  else
    log "FerretDB уже запущен."
  fi
}

# ==============================
# Дамп удалённой MongoDB
# ==============================
dump_mongo() {
  log "Снятие дампа с удалённой MongoDB..."
  rm -rf "$DUMP_DIR"
  mongodump --uri="$REMOTE_URI" --out="$DUMP_DIR"
  if [ ! -d "$DUMP_DIR/$DB_NAME" ]; then
    warn "Папка дампа $DUMP_DIR/$DB_NAME не найдена. Проверьте DB_NAME и URI."
  fi
}

# ==============================
# Восстановление дампа в FerretDB
# ==============================
restore_to_ferret() {
  log "Восстановление данных в FerretDB..."
  mongorestore --uri="$LOCAL_URI" --drop "$DUMP_DIR/$DB_NAME"
}

# ==============================
# Проверка подключения к FerretDB
# ==============================
check_connection() {
  log "Проверка подключения к FerretDB..."
  mongosh "$LOCAL_URI" --eval "db.stats()" >/dev/null
}

# ==============================
# Сравнение коллекций (кол-во документов)
# ==============================
compare_collections() {
  log "Сравнение коллекций и количества документов..."

  remote_counts_file=$(mktemp)
  local_counts_file=$(mktemp)

  mongosh "$REMOTE_URI" --quiet --eval '
    db.getCollectionNames().map(c => ({collection: c, count: db[c].countDocuments()}))
  ' | jq -c '.[]' > "$remote_counts_file"

  mongosh "$LOCAL_URI" --quiet --eval '
    db.getCollectionNames().map(c => ({collection: c, count: db[c].countDocuments()}))
  ' | jq -c '.[]' > "$local_counts_file"

  # Превращаем потоки JSON-объектов в массивы
  remote_counts_json=$(jq -s '.' "$remote_counts_file")
  local_counts_json=$(jq -s '.' "$local_counts_file")

  # Делаем «outer join» по именам коллекций, чтобы учесть отсутствующие
  collections=$(
    jq -n --argjson r "$remote_counts_json" --argjson l "$local_counts_json" '
      def to_map: map({ ( .collection ): (.count) }) | add // {};
      def keys_all(a;b): (a|keys_unsorted) + (b|keys_unsorted) | unique;

      ($r|to_map) as $rr |
      ($l|to_map) as $ll |
      {
        collections: (
          keys_all($rr;$ll) | map({
            collection: .,
            remote_count: ($rr[.] // 0),
            local_count: ($ll[.] // 0),
            status: if (($rr[.] // 0) == ($ll[.] // 0)) then "OK" else "MISMATCH" end
          })
        )
      }
    '
  )

  # Вывод в консоль для наглядности
  echo "------------------------------"
  echo "Документы по коллекциям:"
  echo "$collections" | jq -r '
    .collections[]
    | @tsv "\(.collection)\t\(.remote_count)\t\(.local_count)\t\(.status)"
  ' | while IFS=$'\t' read -r col rc lc st; do
    printf " %-30s | Remote: %-10s | Local: %-10s | %s\n" "$col" "$rc" "$lc" "$st"
  done
}

# ==============================
# Сравнение индексов (кол-во индексов)
# ==============================
compare_indexes() {
  log "Сравнение индексов..."

  remote_indexes_file=$(mktemp)
  local_indexes_file=$(mktemp)

  mongosh "$REMOTE_URI" --quiet --eval '
    db.getCollectionNames().forEach(c => {
      printjson({collection: c, indexes: db[c].getIndexes()})
    })
  ' | jq -c '.' > "$remote_indexes_file"

  mongosh "$LOCAL_URI" --quiet --eval '
    db.getCollectionNames().forEach(c => {
      printjson({collection: c, indexes: db[c].getIndexes()})
    })
  ' | jq -c '.' > "$local_indexes_file"

  remote_idx_json=$(jq -s '.' "$remote_indexes_file")
  local_idx_json=$(jq -s '.' "$local_indexes_file")

  indexes=$(
    jq -n --argjson r "$remote_idx_json" --argjson l "$local_idx_json" '
      def to_map:
        map({ ( .collection ): ( .indexes | length ) }) | add // {};
      def keys_all(a;b): (a|keys_unsorted) + (b|keys_unsorted) | unique;

      ($r|to_map) as $rr |
      ($l|to_map) as $ll |
      {
        indexes: (
          keys_all($rr;$ll) | map({
            collection: .,
            remote_indexes: ($rr[.] // 0),
            local_indexes: ($ll[.] // 0),
            status: if (($rr[.] // 0) == ($ll[.] // 0)) then "OK" else "DIFF" end
          })
        )
      }
    '
  )

  echo "------------------------------"
  echo "Индексы по коллекциям:"
  echo "$indexes" | jq -r '
    .indexes[]
    | @tsv "\(.collection)\t\(.remote_indexes)\t\(.local_indexes)\t\(.status)"
  ' | while IFS=$'\t' read -r col ri li st; do
    printf " %-30s | Indexes: Remote=%-4s Local=%-4s | %s\n" "$col" "$ri" "$li" "$st"
  done
}

# ==============================
# Генерация JSON-отчёта (с итоговой сводкой)
# ==============================
generate_json_report() {
  log "Формирование JSON отчёта..."
  # Объединяем секции collections и indexes
  combined=$(jq -s '.[0] * .[1]' <(echo "$collections") <(echo "$indexes"))

  # Добавляем сводку
  summary=$(jq '
    {
      total_collections: (.collections | length),
      collections_ok: (.collections | map(select(.status == "OK")) | length),
      collections_mismatch: (.collections | map(select(.status != "OK")) | length),
      total_indexes: (.indexes | length),
      indexes_ok: (.indexes | map(select(.status == "OK")) | length),
      indexes_diff: (.indexes | map(select(.status != "OK")) | length)
    }
  ' <<< "$combined")

  jq -s '.[0] * {summary: .[1]}' <(echo "$combined") <(echo "$summary") > "$REPORT_JSON"
  log "JSON-отчёт создан: $REPORT_JSON"
}

# ==============================
# Генерация HTML-отчёта (с итоговой сводкой)
# ==============================
generate_html_report() {
  log "Формирование HTML отчёта..."
  jq -r '
  def status_color(s):
    if s == "OK" then "green"
    elif s == "MISMATCH" then "red"
    elif s == "DIFF" then "orange"
    else "gray" end;

  def table_section(title; items; headers; fields):
    "<h2>" + title + "</h2>" +
    "<table border=\"1\" cellspacing=\"0\" cellpadding=\"6\" style=\"border-collapse: collapse; font-family: sans-serif; font-size: 14px;\">" +
      "<thead style=\"background:#f0f0f0\"><tr>" +
        (headers | map("<th style=\"text-align:left;\">" + . + "</th>") | join("")) +
      "</tr></thead>" +
      "<tbody>" +
        (items | map(
          "<tr>" +
          (fields | map(
            if . == "status"
            then "<td style=\"color:" + status_color(.[.]) + "; font-weight:bold;\">" + (.[.] | tostring) + "</td>"
            else "<td>" + (.[.] | tostring) + "</td>" end
          ) | join("")) +
          "</tr>"
        ) | join("")) +
      "</tbody></table>";

  def summary_table(summary):
    "<h2>Summary</h2>" +
    "<table border=\"1\" cellspacing=\"0\" cellpadding=\"6\" style=\"border-collapse: collapse; font-family: sans-serif; font-size: 14px;\">" +
      "<tr><th style=\"text-align:left;\">Total Collections</th><td>\(summary.total_collections)</td></tr>" +
      "<tr><th style=\"text-align:left;\">Collections OK</th><td style=\"color:green\">\(summary.collections_ok)</td></tr>" +
      "<tr><th style=\"text-align:left;\">Collections Mismatch</th><td style=\"color:red\">\(summary.collections_mismatch)</td></tr>" +
      "<tr><th style=\"text-align:left;\">Total Indexes</th><td>\(summary.total_indexes)</td></tr>" +
      "<tr><th style=\"text-align:left;\">Indexes OK</th><td style=\"color:green\">\(summary.indexes_ok)</td></tr>" +
      "<tr><th style=\"text-align:left;\">Indexes Diff</th><td style=\"color:orange\">\(summary.indexes_diff)</td></tr>" +
    "</table>";

  "<!doctype html><html><head><meta charset=\"utf-8\"><title>Migration Report</title></head><body style=\"margin:24px;\">" +
    "<h1 style=\"font-family:sans-serif;\">MongoDB → FerretDB Migration Report</h1>" +
    summary_table(.summary) +
    table_section(
      "Collections",
      .collections,
      ["Collection", "Remote Count", "Local Count", "Status"],
      ["collection", "remote_count", "local_count", "status"]
    ) +
    table_section(
      "Indexes",
      .indexes,
      ["Collection", "Remote Indexes", "Local Indexes", "Status"],
      ["collection", "remote_indexes", "local_indexes", "status"]
    ) +
  "</body></html>"
  ' "$REPORT_JSON" > "$REPORT_HTML"

  log "HTML-отчёт создан: $REPORT_HTML"
}

# ==============================
# Основная последовательность
# ==============================
check_tools
start_ferret
dump_mongo
restore_to_ferret
check_connection
compare_collections
compare_indexes
generate_json_report
generate_html_report

log "Все операции завершены успешно!"
echo "Файлы отчётов: $REPORT_JSON  и  $REPORT_HTML"
