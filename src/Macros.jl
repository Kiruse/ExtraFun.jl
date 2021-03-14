######################################################################
# General purpose macros
# -----
# Licensed under MIT License
export @sym_str, @curry

macro sym_str(str)
    esc(:(Symbol($str)))
end

# Like curry, but applies it to all first-level method calls in a block.
"""`@curry exprs...`
 
 Injects `exprs` as the first arguments in every first-level method calls of the last argument. Like [`curry`](@ref),
 but does not generate an anonymous method instance that can be passed to other methods.
 
 # Example
 
 ```julia
 logid = 42
 @curry "Log " logid ": " begin
    println(420)
    println(69)
 end
 # prints "Log 42: 420"
 # prints "Log 42: 69"
 ```
 """
macro curry(curry...)
    if length(curry) < 2
        throw(ArgumentError("no curry-expressions"))
    end
    
    curry = collect(curry)
    exec = pop!(curry)
    
    posargs, kwargs = curry_splitargs(curry)
    
    if exec isa Expr
        if exec.head === :block
            for expr ∈ exec.args
                if expr isa Expr
                    if is_call_expr(expr)
                        curry_call!(expr, posargs, kwargs)
                    elseif is_call_assignment(expr)
                        curry_call!(expr.args[2], posargs, kwargs)
                    end
                end
            end
        elseif is_call_expr(exec)
            curry_call!(exec, posargs, kwargs)
        elseif is_call_assignment(exec)
            curry_call!(exec.args[2], posargs, kwargs)
        end
    end
    
    esc(exec)
end

function curry_splitargs(args)
    posargs = []
    kwargs  = []
    for arg ∈ args
        if curry_iskwarg(arg)
            push!(kwargs, arg)
        else
            push!(posargs, arg)
        end
    end
    posargs, kwargs
end
curry_iskwarg(_) = false
curry_iskwarg(arg::Expr) = (arg.head === :(=)) || (arg.head === :call && arg.args[1] === :(=>))

function curry_call!(call::Expr, pos, kw)
    @assert call.head === :call
    splice!(call.args, 2:1, pos)
    append!(call.args, curry_makekwarg.(kw))
    call
end
function curry_makekwarg(arg::Expr)
    if arg.head === :(=)
        Expr(:kw, arg.args[1], arg.args[2])
    elseif arg.head === :call && arg.args[1] === :(=>)
        Expr(:kw, arg.args[2], arg.args[3])
    else
        throw(ArgumentError("Unknown expression $arg"))
    end
end