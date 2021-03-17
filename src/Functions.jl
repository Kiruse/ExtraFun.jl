######################################################################
# General purpose functionized patterns
# -----
# Licensed under MIT License.
import Base.Threads: @threads

export negate
negate(x) = (args...; kwargs...) -> !x(args...; kwargs...)

export isathing
const isathing = negate(isnothing)

export isinstanceof
isinstanceof(x::T2, ::Type{T1}) where {T1, T2<:T1} = true
isinstanceof(_, _) = false

export truthy, falsy
truthy(::Nothing) = false
truthy(b::Bool)   = b
truthy(n::Number) = n != 0
truthy(_) = true
const falsy = negate(truthy)

export hassignature
function hassignature(fn, argtypes::Type...)
    sig = Tuple{typeof(fn), argtypes...}
    for method ∈ methods(fn)
        if sig <: method.sig
            return true
        end
    end
    return false
end

export isiterable
@generated function isiterable(x)
    if hassignature(iterate, x)
        :(true)
    else
        :(false)
    end
end

export curry
curry(fn, curryargs...; kwcurryargs...) = (moreargs...; kwargs...) -> fn(curryargs..., moreargs...; kwcurryargs..., kwargs...)

export indexof
indexof(arr, elem; by = identity, offset::Integer = 1, strict::Bool = false) = findnext(curr->strict ? by(curr) === elem : by(curr) == elem, arr, offset)

export shift!
function shift!(arr)
    item = arr[1]
    deleteat!(arr, 1)
    item
end

export unshift!
function unshift!(arr, value)
    insert!(arr, 1, value)
    arr
end

export hflip!
function hflip!(arr::AbstractArray)
    rows, cols = size(arr)
    if cols < 2 return arr end
    
    @threads for row ∈ 1:rows
        @threads for col ∈ 1:(cols÷2)
            tmp = arr[row, col]
            arr[row, col] = arr[row, cols-(col-1)]
            arr[row, cols-(col-1)] = tmp
        end
    end
    arr
end

export vflip!
function vflip!(arr::AbstractArray)
    rows, cols = size(arr)
    if rows < 2 return arr end
    
    @threads for col ∈ 1:cols
        @threads for row ∈ 1:(rows÷2)
            tmp = arr[row, col]
            arr[row, col] = arr[rows-(row-1), col]
            arr[rows-(row-1), col] = tmp
        end
    end
    arr
end

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


is_call_expr(_) = false
is_call_expr(expr::Expr) = expr.head === :call
is_call_assignment(expr::Expr) = expr.head === :(=) && is_call_expr(expr.args[2])
