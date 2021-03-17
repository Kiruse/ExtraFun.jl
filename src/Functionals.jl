######################################################################
# Functions that are less imperative and more functional. These
# functions do a bit of smart magic in order to accomplish a given task.
# -----
# Licensed under MIT License

export negate
negate(x) = (args...; kwargs...) -> !x(args...; kwargs...)

export isathing
const isathing = negate(isnothing)

export truthy, falsy
truthy(::Nothing) = false
truthy(b::Bool)   = b
truthy(n::Number) = n != 0
truthy(_) = true
const falsy = negate(truthy)

function Base.split(cond, arr::AbstractArray)
    atrue  = []
    afalse = []
    for item ∈ arr
        if cond(item)
            push!(atrue, item)
        else
            push!(afalse, item)
        end
    end
    atrue, afalse
end
Base.split(cond, tpl::Tuple) = filter(item->cond(item), tpl), filter(item->!cond(item), tpl)

"""`insert!(arr::Vector{T}, elem::T; before = nothing, after = nothing, strict::Bool = false)`
 
 Insert `elem` into `arr` either immediately before `before` or immediately after `after`. Specifying both keyword
 arguments `before` and `after` as well as neither is illegal - exactly one must be specified. The specified relative
 element must exist in the array.
 
 If `strict` is false, simple equality (==) is used, otherwise strict equality (===)."""
function Base.insert!(arr::Vector{T}, elem::T; before = nothing, after = nothing, by = identity, strict::Bool = false) where T
    if before === nothing && after === nothing
        throw(ArgumentError("Neither `before` nor `after` specified"))
    elseif before !== nothing && after !== nothing
        throw(ArgumentError("Both `before` and `after` specified"))
    end
    
    idx = if before !== nothing
        indexof(arr, before; by=by, strict=strict)
    else
        idx = indexof(arr, after; by=by, strict=strict)
        idx === nothing ? nothing : idx+1
    end
    
    if idx === nothing
        ArgumentError("Relative element not found")
    end
    insert!(arr, idx, elem)
end

export indexed
abstract type Indexability end
struct Indexed <: Indexability end
struct NonIndexed <: Indexability end
@generated function indexability(x)
    if hassignature(getindex, x, Integer)
        :(Indexed())
    else
        :(NonIndexed())
    end
end
indexed(v) = indexed(indexability(v), v)
indexed(::Indexed, v) = v
indexed(::NonIndexed, v) = collect(v)
