using Serialization

using TodoGrabber

export get_filenames, find_todos, write_todos, save_dict, grab_dir,
    find_todos_struct
const cachefile = "./tests/serial_cache.bin"

function get_filenames(fpath::String)
    files = String[]
    for f in readdir(abspath(fpath), join=true)
        push!(files, f)
    end
    return files
end


function write_todos(targetfile::String,
                     tododict::Union{Dict{String, Vector{Todo}}, Nothing})
    if tododict == nothing
        printstyled(stderr, "No todos found", color = :red)
        return nothing
    end
    open(targetfile, "w") do tfile
        for (fname, todo_vec) in tododict
            write(tfile, string("* ", fname, "\n"))
            for todo in todo_vec
                write(tfile, string("** [[TODO]] ", todo.ID," ", todo.Suffix, "\n"))
            end
        end
    end

    return nothing
end

function save_dict(tododict::Dict{String, Vector{Todo}}; targetfile::String="")
    if isempty(targetfile)
        serialize(cachefile, tododict)
    else
        serialize(targetfile, tododict)
    end
end


function grab_dir(directory::String; target_file::String="")
    filenames = get_filenames(directory)
    todos = find_todos(filenames)
    save_dict(todos)
    if isempty(target_file)
        printstyled(stderr, "No output file given. Writing on temp_stack.org",
                    color = :yellow)
        write_todos("./tests/temp_stack.org", todos)
    else
        println(stdout, "Writing on $target_file")
        write_todos(target_file, todos)
    end
end

function find_todos(target_files::Vector{String})
    todo_dict = Dict{String,Vector{Todo}}()
    for filename in target_files
        captured = Vector{Todo}(undef, 0)
        open(filename) do file
            match_lines(captured, filename, file, todo_dict)
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


function match_lines(captured::Vector{Todo} , filename::String, file::IOStream,
                     todo_dict::Union{Dict{String, Vector{Todo}}, Nothing})

    for (line, line_text) in enumerate(eachline(file))
        m = match(r"^(.*)TODO: (.*)$", line_text)
        if m !== nothing
            # TODO: Rethink about stripping
            cleaned_capture = strip(m.captures[2], ['-','*','>',' ', '/'])
            if !haskey(todo_dict, filename) ||
                isempty(findall(x->x==cleaned_capture, getindex(todo_dict, filename)))
                push!(captured, Todo(m.captures[1],
                                     String(cleaned_capture), filename,
                                     line, "lmao", -1))
                preffix = m.captures[1]
            end
        end # regex if
    end # line loop
end
