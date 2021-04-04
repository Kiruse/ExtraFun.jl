######################################################################
# Event emitter & listener system leveraging dynamic multiple dispatch.
# -----
# Licensed under MIT License
module Events
import ..ExtraFun
import ExtraFun: Ident, indexof

export @event
macro event(fn::Expr)
    @assert fn.head === :function || fn.head === :(=) "expected function declaration"
    @assert length(fn.args) == 2 "unexpected function data"
    
    fn_head, fn_body = fn.args
    
    @assert fn_head.head === :call "expected function declaration"
    
    curly  = fn_head.args[1]
    params = nothing
    args   = fn_head.args[2:length(fn_head.args)]
    if args[1].head === :parameters
        params = args[1]
        args = args[2:length(args)]
    end
    
    @assert curly.head === :curly "expected curly function with event name symbol"
    
    listener_name = curly.args[1]
    event_name    = curly.args[2].value::Symbol
    
    if !haskey(_static_events, event_name)
        _static_events[event_name] = Symbol[]
    end
    push!(_static_events[event_name], listener_name)
    
    result = :(Events.listen(::ExtraFun.Ident{$(QuoteNode(event_name))}, ::ExtraFun.Ident{$(QuoteNode(listener_name))}) = $fn_body)
    if params !== nothing
        insert!(result.args[1].args, 2, params)
    end
    append!(result.args[1].args, args)
    esc(result)
end
isdotsequence(::Symbol) = true
isdotsequence(expr::Expr) = expr.head === :. && isdotsequence(args[2])

export emit
function emit(evt_name::Symbol, args...; kwargs...)
    errors = Exception[]
    
    if haskey(_static_events, evt_name)
        for fn_name ∈ _static_events[evt_name]
            try
                listen(Ident{evt_name}(), Ident{fn_name}(), args...; kwargs...)
            catch ex
                push!(errors, ex)
            end
        end
    end
    
    if haskey(_callback_events, evt_name)
        for cb ∈ _callback_events[evt_name]
            try
                cb(args...; kwargs...)
            catch ex
                push!(errors, ex)
            end
        end
    end
    
    if !isempty(errors)
        throw(CompositeException(errors))
    end
    nothing
end

export listen
function listen() end
function listen(callback, evt_name::Symbol)
    if !haskey(_callback_events, evt_name)
        _callback_events[evt_name] = []
    end
    push!(_callback_events[evt_name], callback)
    nothing
end

export listen_once
function listen_once(callback, evt_name::Symbol)
    function wrapper(args...; kwargs...)
        callback(args...; kwargs...)
        deafen(evt_name, wrapper)
    end
    listen(wrapper, evt_name)
end

export deafen
function deafen(evt_name::Symbol, callback)
    if haskey(_callback_events, evt_name)
        idx = indexof(_callback_events[evt_name], callback; strict=true)
        if idx !== nothing
            deleteat!(_callback_events[evt_name], idx)
        end
    end
    nothing
end


const _static_events = Dict{Symbol, Vector{Symbol}}()
const _callback_events = Dict{Symbol, Vector}()
end # module Events
