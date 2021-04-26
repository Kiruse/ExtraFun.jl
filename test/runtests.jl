######################################################################
# ExtraFun unit tests
# -----
# Licensed under MIT License.
module Helpers
    using ExtraFun
    
    struct Immutable
        mutable::Mutable{Int}
        flag::Bool
    end
    Immutable(mutable, flag) = Immutable(Mutable(mutable), flag)
    Immutable(mutable) = Immutable(mutable, false)
    Base.:(==)(lhs::Immutable, rhs::Immutable) = lhs.mutable == rhs.mutable && lhs.flag == rhs.flag
    
    function testmultiply(base::Integer, factor::Number; truncate::Bool = false)
        if truncate
            floor(base*factor)
        else
            base*factor
        end
    end
end

include("./Test.Functions.jl")
include("./Test.Functionals.jl")
include("./Test.Macros.jl")
include("./Test.Types.jl")
include("./Test.XCopy.jl")
include("./Test.CancellableTasks.jl")
include("./Test.Events.jl")
