abstract type OnlineAlgorithm{T} end

function Base.show(io::IO, o::OnlineAlgorithm)
    print(io, typeof(o), ": ")
    fields =  fieldnames(typeof(o))
    for i = 1:length(fields)
        if typeof(getfield(o, fields[i])) <: OnlineAlgorithm
            continue
        end
        print(io, fields[i], " = ")
        print(io, getfield(o, fields[i]), " | ")
    end
end
