######################################################################
# General purpose function stubs for specialization
# -----
# Licensed under MIT License
export use
use(args...; kwargs...) = MethodError(use, (kwargs, args...))

export cancel
cancel(args...; kwargs...) = MethodError(cancel, (kwargs, args...))

export clear
clear(args...; kwargs...) = MethodError(clear, (kwargs, args...))

export update!
update!(args...; kwargs...) = MethodError(update!, (kwargs, args...))

export init
init(args...; kwargs...) = MethodError(init, (kwargs, args...))

export store
store(args...; kwargs...) = MethodError(store, (kwargs, args...))

export restore
restore(args...; kwargs...) = MethodError(restore, (kwargs, args...))
