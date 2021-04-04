######################################################################
# Event System UTs
# -----
# Licensed under MIT License.
module TestEvents
using Test
using ExtraFun
using ExtraFun.Events


@testset "Events" begin
    @testset "meta" begin
        foo_success = false
        @event function foo{:test_event1}(arg1, arg2; kwarg = false)
            foo_success = arg1 == 24 && arg2 == 25 && kwarg == 42
        end
        
        @test emit(:test_event1, 24, 25, kwarg=42) === nothing
        @test foo_success
    end
    
    @testset "callback" begin
        success = false
        listen(:test_event2) do arg1, arg2
            @assert arg1 == 42
            @assert arg2 == 420
            success = true
        end
        @test emit(:test_event2, 42, 420) === nothing
        @test success
        
        count = false
        listen_once(:test_event3) do arg1, arg2
            @assert arg1 == 69
            @assert arg2 == .69
            count = true
        end
        @test emit(:test_event3, 69, .69) === nothing
        @test emit(:test_event3, 42, 420) === nothing
        @test count == 1
    end
end

end # module TestEvents
