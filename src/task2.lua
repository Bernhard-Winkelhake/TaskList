local socket = require("socket")

-- Funktion zum Bildschirm löschen und Cursor nach oben setzen
local function clear_screen()
  --io.write("\27[2J\27[H")
  --io.flush()  -- Stellt sicher, dass alle Ausgaben tatsächlich geschrieben werden
  os.execute("clear")
end

-- Tabelle für Aufgaben
local todo_list = {}

-- Hilfsvariablen für die Navigation
local current_index = 1
local num_tasks = 0
local mode = "normal"  -- Anfangs im "normalen Modus"

-- Datei zum Speichern und Laden von Aufgaben
local task_file = "task.txt"

-- Funktion zum Laden der Aufgaben aus der Datei
local function load_tasks()
  local file = io.open(task_file, "r")
  if file then
    for line in file:lines() do
      table.insert(todo_list, line)
    end
    file:close()
  end
end

-- Funktion zum Speichern der Aufgaben in die Datei
local function save_tasks()
  local file = io.open(task_file, "w")
  for _, task in ipairs(todo_list) do
    file:write(task .. "\n")
  end
  file:close()
end

-- Funktion zum Anzeigen der Aufgaben
local function show_tasks()
  num_tasks = #todo_list
  if num_tasks == 0 then
    print("There are no tasks")
  else
    print("Your Tasks:")
    for i, task in ipairs(todo_list) do
      if i == current_index then
        io.write("> ")  -- Markiert die aktuelle Aufgabe
      else
        io.write("  ")
      end
      print(i .. ". " .. task)
    end
  end
end

-- Funktion zum Anzeigen der Befehle im Command Mode
local function show_commands()
  io.write("Commands: | ':add' | ':del' | ':ex' |\n")
end

-- Funktion zum Hinzufügen einer Aufgabe
local function add_task()
  clear_screen()
  show_tasks()
  show_commands()
  print("New Task:")
  local task = io.read()
  if task and task ~= "" then
    table.insert(todo_list, task)
    print("Task added")
    save_tasks()
  else
    print("Task could not be added")
  end
end

-- Funktion zum Löschen einer Aufgabe
local function delete_task()
  clear_screen()
  show_tasks()
  show_commands()
  print("Remove Task with Index:")
  local task_number = tonumber(io.read())
  if task_number and task_number > 0 and task_number <= num_tasks then
    table.remove(todo_list, task_number)
    print("Task deleted")
    save_tasks()
  else
    print("Index out of Bounds")
  end
end

-- Funktion zum Behandeln von Tasteneingaben
local function handle_input(input)
  if mode == "command" then
    -- Im Command Mode
    if input == ":add" then
      add_task()
    elseif input == ":del" then
      delete_task()
    elseif input == ":ex" then
      clear_screen()
      print("Program terminated")
      return false
    else
      mode = "normal"
      print("Unknown command. Please try again")
    end
    -- Zurück zum normalen Modus
    mode = "normal"
  elseif mode == "normal" then
    -- Im Normal Mode
    if input == "j" then
      if current_index < num_tasks then
        current_index = current_index + 1
      end
    elseif input == "k" then
      if current_index > 1 then
        current_index = current_index - 1
      end
    elseif input == ":" then
      -- Wechsle in den Command Mode und warte auf Befehl
      mode = "command"
      return true
    elseif input == "^]" then
      -- Wechsle in den Command Mode und warte auf Befehl
      mode = "normal"
      return true
    end
  end  
  return true
end

-- Funktion, um sofortige Eingabe zu ermöglichen
local function get_single_key()
  -- Schalte in den "raw"-Modus, um sofortige Zeichen-Eingabe zu ermöglichen
  os.execute("stty raw -echo")
  local char = io.read(1)
  -- Zurück in den "normalen" Modus schalten
  os.execute("stty -raw echo")
  return char
end

-- Funktion zum Sammeln von Befehlen im Command Mode
local function get_command_input()
  io.write(":")
  local command = io.read()
  return ":" .. command
end

-- Hauptschleife des Programms
local function main_loop()
  load_tasks()
  while true do
    clear_screen()
    show_tasks()
    if mode == "command" then
      show_commands()  -- Zeigt die Befehlsliste im Command Mode an
      -- Sammle den vollständigen Befehl
      local command_input = get_command_input()
      if not handle_input(command_input) then
        break
      end
    else
      print(mode)
      -- Sofortige Eingabe für j/k und Kommandos
      local input = get_single_key()
      if not handle_input(input) then
        break
      end
    end
  end
end

-- Programmstart
main_loop()

