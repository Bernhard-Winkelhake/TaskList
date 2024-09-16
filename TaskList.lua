local socket = require("socket")

-- Funktion zum Bildschirm löschen
local function clear_screen()
 os.execute("clear")
end

-- Tabelle für Aufgaben
local todo_list = {}

-- Hilfsvariablen für die Navigation
local current_index = 1
local num_tasks = 0

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
  clear_screen()
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

-- Funktion zum Anzeigen der Befehle
local function show_commands()
  io.write("\nCommands: | ':add' | ':del' | ':ex' |\n")
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
    print("Task coud not be added")
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
local function handle_input(command)
  if command == ":add" then
    add_task()
  elseif command == ":del" then
    delete_task()
  elseif command == ":ex" then
    clear_screen()
    print("Program terminated")
    return false
  elseif command == "j" then
    if current_index > 1 then
      current_index = current_index - 1
    end
  elseif command == "k" then
    if current_index < num_tasks then
      current_index = current_index + 1
    end
  else
    print("Unknown command. Please try again")
  end
  return true
end

-- Hauptschleife des Programms
local function main_loop()
  load_tasks()
  while true do
    clear_screen()
    show_tasks()
    show_commands()
    
    
    -- Wartet auf Eingabe von Benutzer
    local input = io.read()
    if not handle_input(input) then
      break
    end
  end
end

-- Programmstart
main_loop()

