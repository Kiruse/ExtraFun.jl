######################################################################
# Extra general purpose functions & stubs
# -----
# Copyright (c) Kiruse 2021. Licensed under MIT License
module ExtraFun
using Reexport
export use

include("./Stubs.jl")
include("./Errors.jl")
include("./Macros.jl")

include("./Types.jl")
include("./Functions.jl")
include("./Functionals.jl")
include("./XCopy.jl")
include("./CancellableTasks.jl")
include("./Events.jl")

@reexport using .CancellableTasks

end # module
