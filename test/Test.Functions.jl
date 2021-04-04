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
    
    @testset "Extended Base.wait" begin
        let cond = Condition()
            @sync begin
                flag = false
                
                @async begin
                    lock(cond) do
                        sleep(rand())
                        flag = true
                        notify(cond)
                    end
                end
                
                @test @await begin
                    lock(cond) do
                        @assert !flag
                        wait(() -> flag, cond)
                        @assert flag
                    end
                    true
                end
            end
        end
        
        let cond = Condition()
            value = nothing
            @sync begin
                wakeup = false
                
                @async begin
                    lock(cond) do
                        sleep(0.1)
                        notify(cond, 24)
                        sleep(0.1)
                        wakeup = true
                        notify(cond, 42)
                    end
                end
                
                @async begin
                    lock(cond) do
                        value = wait(() -> wakeup, cond)
                    end
                end
            end
            @test value == 42
        end
        
        let cond = Condition()
            lock(cond) do
                @test_throws TimeoutError wait(() -> false, cond, timeout=0.5)
            end
        end
        
        let cond = Condition()
            t0 = time()
            @sync begin
                flag = false
                
                # These shouldn't change the outcome
                @async begin
                    sleep(0.1)
                    lock(cond) do; notify(cond) end
                    sleep(0.1)
                    lock(cond) do; notify(cond) end
                end
                
                @async begin
                    sleep(0.5)
                    lock(cond) do
                        flag = true
                        notify(cond)
                    end
                end
                
                @test @await begin
                    t0 = time()
                    lock(cond) do
                        @async begin
                            @assert !flag
                            wait(() -> flag, cond)
                            @assert flag
                        end
                    end
                    true
                end
            end
            @test isapprox(time()-t0, 0.5, atol=0.1)
        end
        
        let cond = Condition()
            value = nothing
            @sync begin
                wakeup = false
                
                @async begin
                    lock(cond) do
                        sleep(0.1)
                        notify(cond, 24)
                        sleep(0.1)
                        wakeup = true
                        notify(cond, 42)
                    end
                end
                
                @async begin
                    lock(cond) do
                        value = wait(() -> wakeup, cond; timeout=0.5)
                    end
                end
            end
            @test value == 42
        end
    end
end
end # module TestFunctions
