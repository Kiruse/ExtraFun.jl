######################################################################
# Functions UTs
# -----
# Licensed under MIT License
module TestFunctions
using Test
using ExtraFun
import ..Helpers: Immutable, testmultiply

@testset "ExtraFun Functions" begin
    @testset "curry" begin
        let curried = curry(testmultiply, 42, truncate=true)
            @test curried(2.1) == 88
            @test curried(0.4) == 16
        end
    end
    
    @testset "indexof" begin
        @test indexof([1, 2, 3], 2) == 2
        @test indexof([1, 2, 3], 1, offset=2) === nothing
        @test indexof([1, 2, 3], 1, by=(x)->x-2) == 3
    end
    
    @testset "[xv]flip!" begin
        let mat = [1 2 3; 4 5 6; 7 8 9]
            @test vflip!(mat) == [7 8 9; 4 5 6; 1 2 3]
        end
        
        let mat = [1 2 3; 4 5 6; 7 8 9]
            @test hflip!(mat) == [3 2 1; 6 5 4; 9 8 7]
        end
    end
    
    @testset "isinstanceof" begin
        @test isinstanceof(42, Number)
        @test isinstanceof(42, Integer)
        @test isinstanceof(42, Int)
        @test !isinstanceof(42, Unsigned)
        @test !isinstanceof(42, AbstractFloat)
        @test isinstanceof(Immutable(42, false), Immutable)
    end
end
end # module TestFunctions
