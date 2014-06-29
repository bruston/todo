#!/usr/bin/env lua

--- A simple todo-list.
--
-- Usage:
-- `todo` lists all todos.
-- `todo add "[task]"` add a task.
-- `todo rm [#num]` remove a task by number.
-- `todo -h` display usage instructions.

-- String formatting helper functions
function printf(...) return io.stdout:write(string.format(...)) end
function sprintf(...) return string.format(...) end
function fprintf(f, ...) return f:write(string.format(...)) end

todoFile = sprintf("%s/.todos", os.getenv("HOME"))

function usage()
    print([[
USAGE:
`todo` lists all todos.
`todo add "[task]"` add a task.
`todo rm [#num]` remove a task by number.
`todo -h` display usage instructions.]])
end

function list()
    local lineNum = 0
    for line in io.lines(todoFile) do
        lineNum = lineNum + 1
        printf("%d. %s\n", lineNum, line)
    end
end

function add(task)
    local f = io.open(todoFile, "a")
    fprintf(f, "%s\n", task)
    f:close()
end

function rm(num)
    local tasks = {}
    local lineNum = 0

    num = tonumber(num)
    if not num then
        print("You must specify the task number you wish to remove.\n")
        return list()
    end

    for line in io.lines(todoFile) do
        lineNum = lineNum + 1
        if lineNum ~= num then
            tasks[#tasks+1] = line
        end
    end

    local f = io.open(todoFile, "w+")

    for i = 1, #tasks do
        fprintf(f, "%s\n", tasks[i])
    end

    f:close()
    list()
end

-- Main execution starts here

-- Make sure the todo file can be either created, or opened and written to, else bail.
f = io.open(todoFile, "a")
if not f then
    return printf("Unable to access %s/.todos", todoFile)
end
f.close()

-- Process command-line arguments and call appropriate function.
if #arg == 0 then
    list()
elseif #arg > 1 and arg[1] == "rm" then
    rm(arg[2])
elseif #arg > 1 and arg[1] == "add" then
    task = ""

    for i = 2, #arg do
        if task == "" then
            task = arg[i]
        else
            task = task.." "..arg[i]
        end
    end

    add(task)
    list()
elseif #arg >= 1 and arg[1] == "-h" then
    usage()
else
    print("Unrecognized command.\n")
    usage()
end