using Serialization

using TodoGrabber

const cachefile = "./tests/serial_cache.bin"

function get_filenames(fpath::String)
    files = String[]
    for f in readdir(abspath(fpath), join=true)
        push!(files, f)
    end
    return files
end


function write_todos(tododict::Union{Dict{String,Vector{Todo}},Nothing},
                     targetfile::String)
    if tododict === nothing
        printstyled(stderr, "No todos found", color=:red)
        return nothing
    end
    open(targetfile, "w") do tfile
        for (fname, todo_vec) in tododict
            write(tfile, string("* ", fname, "\n"))
            for todo in todo_vec
                write(tfile, string("** [[TODO]] ", todo.ID, " ", todo.Suffix,
                                    "\n"))
            end
        end
    end
    return nothing
end

function save_dict(tododict::Dict{String,Vector{Todo}}; targetfile::String="")
    if isempty(targetfile)
        serialize(cachefile, tododict)
    else
        serialize(targetfile, tododict)
    end
    return nothing
end


function grab_dir(directory::String; target_file::String="")
    filenames = get_filenames(directory)
    todos = find_todos(filenames)
    save_dict(todos)
    if isempty(target_file)
        println(stdout, "[NOTE] No output file given. Writing on temp_stack.org")
        write_todos(todos, "./tests/temp_stack.org")
    else
        println(stdout, "Writing on $target_file")
        write_todos(todos, target_file)
    end
    return nothing
end

function find_todos(target_files::Vector{String})
    todo_dict = Dict{String,Vector{Todo}}()
    for filename in target_files
        captured = Vector{Todo}(undef, 0)
        open(filename) do file
            match_lines!(captured, filename, file, todo_dict)
        end # file loop
        if isempty(captured) # only push todos when they exist
            continue
        end
        todo_dict[filename] = captured
    end
    if isempty(todo_dict)
        return nothing
    end
    return todo_dict
end


function match_lines!(captured::Vector{Todo}, filename::String, file::IOStream,
                      todo_dict::Union{Dict{String,Vector{Todo}},Nothing})

    preffix = ""
    line::Int64 = 0
    sizet::Int64 = 0
    search_body::Bool = false
    temp_todo_vec = Vector{Todo}(undef, 256)
    println(stdout, "working on ", filename)
    while !eof(file)
        line += 1
        line_text = readline(file)
        m = match(r"^(.*)TODO: (.*)$", line_text)
        if m !== nothing
            # TODO: Rethink about stripping
            cleaned_capture = strip(m.captures[2], ['-','*','>',' ', '/'])
            if !haskey(todo_dict, filename) ||
                isempty(findall(x -> x == cleaned_capture, getindex(todo_dict,
                                                                    filename)))
                sizet += 1
                preffix = m.captures[1]
                temp_todo_vec[sizet] = Todo(preffix,
                                              String(cleaned_capture),
                                              filename,
                                              "",
                                              line,
                                              sizet)

                search_body = true
            end
        elseif !isempty(line_text) && !isempty(preffix) && search_body
            if preffix == line_text[1:sizeof(preffix)]
                temp_todo_vec[sizet].Body *= split(line_text, preffix)[2] * " "
            else
                preffix = ""
                search_body = false
            end
        end
    end # while loop
    copy!(captured, temp_todo_vec[1:sizet])
end # match_lines
