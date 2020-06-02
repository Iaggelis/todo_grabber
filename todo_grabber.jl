function find_todos(filename::String)
    captures = String[]
    open(filename) do file
        for line in eachline(file)
            m = match(r"^(.*)TODO: (.*)$", line)
            if m != nothing
                # println(m.match)
                push!(captures, m.match)
            end
        end
    end
    return captures
end

function write_todos()
    open("/tmp/todostack.org","a")
    return nothing
end

function get_filenames()
    files = String[]
    for f in readdir("./tests/", join=true)
        if f == "todo_grabber.jl"
            continue
        end
        push!(files, f)
    end
    return files
end


fl = get_filenames()
# println(fl)

println("DBG: These are the whole lines that match the regex")
for fli in fl
    a = find_todos(fli)
    for suba in a
        println(suba)
    end
end
