#!/usr/bin/env python3
import requests
import json
import csv
from urllib.parse import urljoin
import urllib3
import time
import sys

# === Конфигурация ===
GLPI_URL = "https://glpi.xbet.lan/"
GLPI_API_TOKEN = "2KQcAPYziZs4CGRgBxi1ke2etKFEx1J9OmMzQMaS"
USERNAME = "chistov.i"
PASSWORD = "***"
# Входной CSV-файл - берется из первого аргумента командной строки или используется по умолчанию
CSV_FILE = sys.argv[1] if len(sys.argv) > 1 else "mongo_servers.csv"
CERT = False   # больше не используем, оставлено для совместимости

# ===============================
# Настройки requests
# ===============================
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# === Функции для работы с сессией ===
def init_session():
    headers = {
        "Content-Type": "application/json",
        "Authorization": "user_token " + GLPI_API_TOKEN,
    }
    response = requests.get(GLPI_URL.rstrip("/") + "/apirest.php/initSession", headers=headers, verify=False)
    response.raise_for_status()
    session_token = response.json()["session_token"]
    return session_token

def kill_session(session_token):
    headers = {"Content-Type": "application/json", "Session-Token": session_token}
    response = requests.get(GLPI_URL.rstrip("/") + "/apirest.php/killSession", headers=headers, verify=False)
    response.raise_for_status()
    return response.text

# === Поиск компьютера по имени ===
def get_computer_by_name(session_token, name):
    headers = {"Content-Type": "application/json", "Session-Token": session_token}
    
    # Попробуем несколько подходов для поиска компьютера
    
    # Подход 1: Поиск с точным именем через searchText
    try:
        params = {"searchText": name, "forcedisplay[]": "name"}
        response = requests.get(GLPI_URL.rstrip("/") + "/apirest.php/Computer", headers=headers, params=params, verify=False)
        if response.status_code == 200:
            data = response.json()
            if isinstance(data, list):
                for comp in data:
                    if comp.get("name") == name:
                        return comp.get("id")
        elif response.status_code == 206:
            # HTTP 206 означает частичный контент - обрабатываем как обычно
            data = response.json()
            if isinstance(data, list):
                for comp in data:
                    if comp.get("name") == name:
                        return comp.get("id")
    except:
        pass
    
    # Подход 2: Поиск по диапазонам с увеличенными лимитами
    ranges = ["0-999", "1000-1999", "2000-2999", "3000-3999", "4000-4999", "5000-5999", "6000-6999", "7000-7999"]  # Покрываем больше записей
    for range_param in ranges:
        try:
            params = {"range": range_param, "forcedisplay[]": "name"}
            response = requests.get(GLPI_URL.rstrip("/") + "/apirest.php/Computer", headers=headers, params=params, verify=False)
            if response.status_code in [200, 206]:  # Принимаем и 206 как валидный ответ
                data = response.json()
                if isinstance(data, list):
                    for comp in data:
                        if comp.get("name") == name:
                            return comp.get("id")
        except:
            continue
    
    return None

# === Получение текущих заметок для компьютера ===
def get_notes(session_token, comp_id):
    headers = {"Content-Type": "application/json", "Session-Token": session_token}
    
    # Прямое обращение к Notepad - единственный работающий метод
    try:
        response = requests.get(
            GLPI_URL.rstrip("/") + f"/apirest.php/Computer/{comp_id}/Notepad",
            headers=headers,
            verify=False
        )
        
        if response.status_code == 200:
            notepad_data = response.json()
            if notepad_data:
                if isinstance(notepad_data, list):
                    notes = [item.get("content", "") for item in notepad_data if item.get("content")]
                    return "\n".join(notes) if notes else "(no notes found)"
                elif isinstance(notepad_data, dict) and "content" in notepad_data:
                    return notepad_data["content"]
    except Exception as e:
        pass

    return "(no notes found)"

# === Добавление заметки к компьютеру ===
def add_note(session_token, comp_id, note_content):
    headers = {"Content-Type": "application/json", "Session-Token": session_token}
    
    # Данные для создания новой заметки
    note_data = {
        "input": {
            "items_id": comp_id,
            "itemtype": "Computer",
            "content": note_content
        }
    }
    
    try:
        response = requests.post(
            GLPI_URL.rstrip("/") + "/apirest.php/Notepad",
            headers=headers,
            json=note_data,
            verify=False
        )
        
        if response.status_code in [200, 201]:
            return True, "Note added successfully"
        else:
            return False, f"Error adding note: {response.status_code} - {response.text}"
    except Exception as e:
        return False, f"Exception adding note: {str(e)}"

# === Главная функция ===
def main():
    # Начало отсчета времени
    start_time = time.time()
    
    # Счетчики для статистики
    servers_notes_added = 0
    servers_notes_checked_not_added = 0
    
    # Списки для сводной информации
    servers_not_found = []  # Серверы, которые не были найдены
    servers_notes_changed = []  # Серверы, для которых notes были изменены
    project_server_counts = {}  # Подсчет серверов по проектам
    
    session_token = init_session()
    print(f"✅ Session initialized: {session_token}\n")
    print(f"📁 Using CSV file: {CSV_FILE}\n")

    with open(CSV_FILE, newline="", encoding="utf-8") as csvfile:
        reader = csv.reader(csvfile)  # Изменено: используем csv.reader вместо DictReader
        next(reader, None)  # Пропускаем заголовочную строку
        for row in reader:
            if len(row) < 4:  # Пропускаем строки с недостаточным количеством колонок
                continue
            computer_name = row[0].strip()  # Первая колонка - имя сервера
            project_service = row[1].strip() if len(row) > 1 else ""  # Вторая колонка - проект/сервис
            
            # Подсчитываем серверы по проектам
            if project_service:
                project_server_counts[project_service] = project_server_counts.get(project_service, 0) + 1
            
            comp_id = get_computer_by_name(session_token, computer_name)
            if comp_id:
                print(f"✅ Found computer '{computer_name}' -> id={comp_id}")
                notes = get_notes(session_token, comp_id)
                
                # Показываем текущие заметки только если они непустые
                if notes and notes != "(no notes found)":
                    print(f"   Current notes:\n{notes}")
                
                # Формируем текст для добавления в заметки на основе данных из CSV
                project_service = row[1].strip() if len(row) > 1 else ""  # Вторая колонка - проект/сервис
                owner = row[2].strip() if len(row) > 2 else ""  # Третья колонка - владелец
                chat_group = row[3].strip() if len(row) > 3 else ""  # Четвертая колонка - чат/группа
                
                project_info = f"""

Проект / сервис: {project_service}
Владелец: {owner}
Чат / группа: {chat_group}"""
                
                # Проверяем, не совпадает ли текущее содержимое с планируемым обновлением
                # Нормализуем текст для более точного сравнения
                project_info_normalized = project_info.strip()
                notes_normalized = notes.strip() if notes != "(no notes found)" else ""
                
                # Проверяем несколько условий дублирования:
                # 1. Точное совпадение нового текста в существующих заметках
                # 2. Проверяем по ключевым строкам (проект, владелец, чат) - все три должны присутствовать
                duplicate_detected = False
                if notes != "(no notes found)":
                    # Проверяем точное совпадение (с учетом пробелов и переносов строк)
                    if project_info_normalized in notes_normalized:
                        duplicate_detected = True
                    # Дополнительная проверка по всем трем ключевым полям одновременно
                    elif (project_service and owner and chat_group and
                          f"Проект / сервис: {project_service}" in notes and 
                          f"Владелец: {owner}" in notes and 
                          f"Чат / группа: {chat_group}" in notes):
                        duplicate_detected = True
                
                if duplicate_detected:
                    print("   no update. same information given")
                    servers_notes_checked_not_added += 1
                else:
                    # Добавляем новую заметку с информацией о проекте
                    success, message = add_note(session_token, comp_id, project_info)
                    if success:
                        print(f"✅ Project info added to notes for '{computer_name}'")
                        servers_notes_added += 1
                        servers_notes_changed.append(f"{computer_name} ({project_service})")
                    else:
                        print(f"⚠️ Failed to add project info to '{computer_name}': {message}")
                print()
            else:
                print(f"❌ Computer '{computer_name}' not found")
                servers_not_found.append(f"{computer_name} ({project_service})")

    kill_session(session_token)
    print("✅ Session killed")
    
    # Вычисляем время выполнения
    end_time = time.time()
    execution_time = end_time - start_time
    minutes = int(execution_time // 60)
    seconds = int(execution_time % 60)
    
    # Выводим статистику
    print("\n" + "="*50)
    print("📊 СТАТИСТИКА ВЫПОЛНЕНИЯ")
    print("="*50)
    print(f"⏱️  Время выполнения: {minutes} мин {seconds} сек")
    print(f"✅ Серверов с добавленными notes: {servers_notes_added}")
    print(f"🔍 Серверов с проверенными, но не добавленными notes: {servers_notes_checked_not_added}")
    print(f"📋 Всего обработано серверов: {servers_notes_added + servers_notes_checked_not_added}")
    print("="*50)
    
    # Сводная информация по серверам, которые не были найдены
    if servers_not_found:
        print("\n" + "="*60)
        print("❌ СЕРВЕРЫ, КОТОРЫЕ НЕ БЫЛИ НАЙДЕНЫ (COMPUTER NOT FOUND)")
        print("="*60)
        for i, server in enumerate(servers_not_found, 1):
            print(f"{i:2d}. {server}")
        print(f"\nВсего не найдено серверов: {len(servers_not_found)}")
        print("="*60)
    
    # Сводная информация по серверам, для которых notes были изменены
    if servers_notes_changed:
        print("\n" + "="*60)
        print("✅ СЕРВЕРЫ, ДЛЯ КОТОРЫХ NOTES БЫЛИ ИЗМЕНЕНЫ/ДОБАВЛЕНЫ")
        print("="*60)
        for i, server in enumerate(servers_notes_changed, 1):
            print(f"{i:2d}. {server}")
        print(f"\nВсего серверов с измененными notes: {len(servers_notes_changed)}")
        print("="*60)
    
    # Статистика по проектам/сервисам
    if project_server_counts:
        print("\n" + "="*70)
        print("📊 КОЛИЧЕСТВО СЕРВЕРОВ ПО ПРОЕКТАМ/СЕРВИСАМ")
        print("="*70)
        total_servers = 0
        for project, count in sorted(project_server_counts.items()):
            print(f"  {project}: {count} серверов")
            total_servers += count
        print("-" * 70)
        print(f"ИТОГО обработано строк из CSV файла: {total_servers}")
        print("="*70)

if __name__ == "__main__":
    main()