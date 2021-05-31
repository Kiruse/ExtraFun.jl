# ExtraFun
Extra general purpose functions, stubs, macros & meta types.

These functions, macros & types are either commonly used patterns, or mere stubs.

# Table of Contents
- [ExtraFun](#extrafun)
- [Table of Contents](#table-of-contents)
- [Stubs](#stubs)
  - [cancel](#cancel)
  - [clear](#clear)
  - [init](#init)
  - [restore](#restore)
  - [store](#store)
  - [update!](#update)
  - [use](#use)
- [Functionals](#functionals)
  - [negate](#negate)
  - [isathing](#isathing)
  - [truthy and falsy](#truthy-and-falsy)
  - [indexed](#indexed)
  - [iterable](#iterable)
- [Functions](#functions)
  - [curry](#curry)
  - [decamelcase](#decamelcase)
  - [indexof](#indexof)
  - [isiterable](#isiterable)
  - [hassignature](#hassignature)
  - [shift](#shift)
  - [unshift](#unshift)
  - [Smart Base.insert!](#smart-baseinsert)
  - [Base.split](#basesplit)
- [Macros](#macros)
  - [@curry](#curry-1)
  - [@once](#once)
  - [@sym_str](#sym_str)
  - [@with](#with)
- [Types](#types)
  - [Mutable](#mutable)
  - [CancellableTask](#cancellabletask)
  - [TimeoutTask](#timeouttask)
- [Meta Types](#meta-types)
  - [Ident](#ident)
  - [Optional & Unknown](#optional--unknown)
- [XCopy](#xcopy)
  - [xcopy function](#xcopy-function)
  - [@xcopy macro](#xcopy-macro)
  - [xcopy_construct function](#xcopy_construct-function)
  - [xcopy_override](#xcopy_override)
  - [@xcopy_override](#xcopy_override-1)

# Stubs
Function stubs are generically named functions without any actual body - they are, by default, noop. Every defined stub
takes no arguments and do absolutely nothing.

These stubs are meant to be complementary to the Julia standard library. Similar to overloading `Base.push!`, you would
overload `ExtraFun.use`. Then, users of your library may simply `using ExtraFun` and call `use(<your type>)` without
having to worry about absolutely addressing the appropriate module. ExtraFun allows for shorter function names and thus
ease of use.

Following is an enumeration of all function stubs exported by ExtraFun, along with their respective intention. In turn,
these intentions are merely intended to give you an idea what to use these stubs for.

## cancel
Intended to cancel a time-consuming task, such as an intense computation or a blocking IO operation.

## clear
Intended to empty a collection or clear the state of an object.

## init
Initialize something. Intended for deferred initialization of a resource. Possibly reopen an existing resource without
having to fully reconstruct it, reusing previously supplied data.

## restore
Restore the state of an object from an external resource, typically a file or an internet resource. Forms the
complementary counterpiece to `ExtraFun.store` method.

## store
Store the state of an object in an external resource, typically a file or an internet resource. Unlike the standard
library's `Serialization.deserialize` method, this method is intended for Julia-version and platform independent
serialization. For this purpose, it is advised to store a complementary file format version and/or parity data.

## update!
Intended to update the (internal) state of an object. Useful to defer comparatively heavy computations to the end of a
cycle, for example.

## use
Intended to indicate a change of state, either globally or locally to a container object.


# Functionals
Following are general purpose patterns packaged in functions (and possibly corresponding types) for convenience.

## negate
Simple functional negation of a callable. Useful to shorten down callbacks rather than using lambdas.

### Signature
```julia
negate(callable)::Bool
```

Naturally, it is assumed `callable` returns a boolean value.

### Example
```julia
isdiv3(x) = x % 3 == 0
filter!(negate(isdiv3), [1, 2, 3, 4])
```

## isathing
Simple negation of `Base.isnothing(x)`.

## truthy and falsy
`truthy` is a functional way of evaluating the "truth" of a value - as prominent in many other languages. In general, this means at least one bit is set. `falsy` is simply `negate(truthy)`.

### Signatures
```julia
truthy(::Nothing) = false
truthy(b::Bool) = b
truthy(n::Number) = n != 0
truthy(_) = true
falsy(x) = !truthy(x)
```

## indexed
A functional alternative to `Base.collect(coll)` which only collects `coll` into a `Vector` if it isn't indexable, otherwise returns `coll` itself.

## iterable
Return the passed-in argument if a signature of `Base.iterate` exists for it, otherwise return an iterable type around the argument. The result of this function will always be iterable.

# Functions
Imperative general purpose functions.

## curry
Currying is a pattern where a new method is derived from an existing. When calling the curried method, positional arguments specified in the original `curry` call are prepended to the arguments of the curried call, and keyword arguments are added.

A macro to conveniently curry every single first-level function call also exists.

### Signature
```julia
curry(callable, args...; kwargs...)
```

### Example
```julia
function foo(num, factor; dofloor)
    res = num * factor
    if dofloor
        res = floor(res)
    end
    return res
end

bar = curry(foo, 42; dofloor=true)
bar(0.5) # == 21
bar(2.1) # == 88
```

## decamelcase
Transform a camel-cased string into its underscored counterpiece. Useful e.g. to transform `Symbol`s in macros.

### Signature
```julia
decamelcase(str::AbstractString; uppercase::Bool = false)::AbstractString
```

### Example
```julia
decamelcase("fooBarBaz") === "foo_bar_baz"
decamelcase("FoobarBaz") === "foobar_baz"
decamelcase("FooBarBaz", uppercase=true) === "FOO_BAR_BAZ"
```

## indexof
Finds the index of the given element in the array-like. If the element was not found, returns `nothing`.

### Signature
```julia
indexof(ary, elem; by = identity, offset = 0, strict = false)::Integer
```

`by` specifies a mapping callback on each element returning the mapped value to compare. The mapper is not called on `elem`.

`offset` specifies the 0-based offset from the start of the array-like to begin search.

`strict` specifies whether to use simple equality (`==`) or strict equality (`===`).

### Example
```julia
indexof([1, 2, 3], 5, by=(i)->i-2, strict=true) # == 3
indexof([1, 2, 3], 5) # == -1
indexof([1, 2, 3], 1, offset=2) # == -1
```

## isiterable
Generated function pattern to test if a signature for `Base.iterate(::T)` exists.

Beware as this pattern may malbehave if such a signature is loaded *after* the first call to this generated function.

### Example
```julia
isiterable([]) # == true
isiterable(:foobar) # == false
isiterable(42) # == true
```

## hassignature
Function pattern to test if a specific signature of a function exists.

### Signature
```julia
hassignature(callable, argtypes::Type...)::Bool
```

### Example
```julia
struct MyStruct end

hassignature(push!, Vector{Int}) # == true
hassignature(push!, MyStruct) # == false
```

## shift
Retrieve and remove the first element from the array-like.

### Signature
```julia
shift(ary::Iterable{T})::T
```

Note that `Iterable` is not an actual type and used here merely for clarity.

The array-like must specialize `Base.getindex` and `Base.deleteat!` functions.

### Example
```julia
vec = [1, 2, 3]
shift(vec) # == 1
shift(vec) # == 2
vec # == [3]
```

## unshift
Insert an element at index 1 of an array-like.

### Signature
```julia
unshift(ary::Iterable{T}, elem::T) -> ary
```

Note that `Iterable` is not an actual type and is used here only for clarity.

The array-like must support the signature `Base.insert!(::typeof(ary), 1, ::typeof(elem))`.

### Example
```julia
unshift([2, 3, 4], 1) # == [1, 2, 3, 4]
```

## Smart Base.insert!
Insert a new element before or after an existing in a `Vector`.

### Signature
```julia
Base.insert!(vec::Vector{T}, elem::T; [befure], [after], by = identity, strict::Bool = false)
```

Either `before` or `after` keyword argument must be supplied, but not both. Otherwise, an `ArgumentError` is thrown.

`by` is a mapping callback transforming the elements of `vec`, but not `before`/`after` or `elem`. This is useful to, for example, insert `elem` before another which meets a specific condition.

`strict` can be used to specify whether to use strict equality (`===`) or simple equality (`==`).

### Example
```julia
struct Wrapper
    int::Int
end
insert!(Wrapper.([1, 2, 3, 4, 6]), 5, before=6, by=(w)->w.int)
insert!(Wrapper.([1, 2, 3, 4, 6]), 5, after=4, by=(w)->w.int)
```

## Base.split
Split a collection into two distinct ones where the first contains all elements for which a given condition returns true and the second all those for which it returns false.

Currently supports standard vectors and tuples.

### Signature
```julia
split(condition, collection::Iterable{T})::Tuple{Vector{T}, Vector{T}}
```

Note that `Iterable` is not an actual type and is used here only for clarity.

The first vector contains all items of `collection` for which `condition` returned true. The second vector contains all remaining items.

### Example
```julia
split(iseven, collect(1:10)) # == ([2, 4, 6, 8, 10], [1, 3, 5, 7, 9])
```

# Macros
ExtraFun provides a handful of useful yet simple macros. These include:

## @curry
A convenience macro which curries every single first-level function call in its block expression. This is useful to call multiple functions reusing various identical arguments.

### Example
```julia
@curry 0xFF42 file = stderr begin
    println("foobar") # prints "0xFF42 foobar" to stderr
    println(42) # prints "0xFF42 42" to stderr
end
```

## @once
A convenience macro which ensures the given code is only executed once per session.

### Example
```julia
function foo(n)
    @once n > 512 println("parameter exceeds safety threshold")
    n+1
end

foo(513)
# prints: parameter exceeds safety threshold
foo(514)
# does not print
```

## @sym_str
A simple string prefix to produce a symbol. Literally equivalent to `Symbol(str)`. The advantage of using the `sym""`
notation is that it allows using characters otherwise illegal in `:` notation whilst shortening syntax slightly.

## @with
Resource management inspired by other languages' `with` keyword. It generates Julia code in the following syntax:

```julia
@with resources... block
# is (almost) equivalent to
try
  let resources...
    block
  end
finally
  close.(resources)
end
```

### Usage
Usage is similar to other languages' `with` keyword:

```julia
res1 = SomeCloseableResource()
@with res1 res2 = SomeCloseableResource() SomeCloseableResource() begin
  println(res1)
  println(res2)
end
println(res1)
# res2 and last resource undefined here
```

*Note:* For `res1` above to work, `SomeCloseableResource()` should be or contain a reference to the closeable resource. If
it can be copied bitwise, `res1` may remain unchanged outside of `@with`.

# Types
General purpose and simple types.

## Mutable
A simple mutable wrapper around a single field of type `T`. The `Mutable` type comes in handy either as a way to reference variables, or to mark a single field of an otherwise immutable struct as mutable.

### Signature
```julia
struct Mutable{T}
  value::T
end
```

### Example
```julia
using ExtraFun

struct Immutable
    immutable::Int
    mutable::Mutable{Bool}
end
Immutable(immutable, mutable::Bool) = Immutable(immutable, Mutable(mutable))

myvar = Immutable(42, false)
myvar.mutable[] # == false
myvar.mutable[] = true
myvar.mutable[] # == true
myvar.immutable += 1 # throws
```

## CancellableTask
Wrapper around a `Task` object with a specialization of `ExtraFun.cancel` to cancel cancel a blocking and/or yielding task prematurely. Unfortunately, these cannot be used with `@sync` and `@async`.

### with_cancel
To conveniently create such a task, the `with_cancel` method is introduced. Its signature is as follows:

### Signature
```julia
with_cancel(callback, schedule_immediately::Bool = false)::CancellableTask
```

### Example
```julia
using ExtraFun

task1 = with_cancel() do
  sleep(9999)
end
task2 = with_cancel() do
  return 42
end
task3 = with_cancel() do
  throw("foobar")
end

cancel(task1)
wait(task1) # throws TaskFailedException wrapping CancellationError

fetch(task2) == 42 # success

wait(task3) # throws TaskFailedException wrapping "foobar"
```

## TimeoutTask
Wrapper around a `Task` object with an automatic timeout. The timeout only affects the task if it blocks and/or yields. One can `Base.wait`, `Base.fetch`, or `ExtraFun.cancel` the task. Like a `CancellableTask`, the `CancellationError` thrown by `Base.wait` and `Base.fetch` will be wrapped by a `TaskFailedException`. Analogously, the `TimeoutError` triggered upon timing out will also be wrapped in such a `TaskFailedException`. Like `CancellableTask`, these tasks are incompatible with `@sync` and `@async`.

### with_timeout
To conveniently create such a task, the `with_timeout` method is introduced. Its signature is as follows:

### Signature
```julia
with_timeout(callback, timeout::Real; schedule_immediately::Bool)::TimeoutTask
```

### Example
```julia
using ExtraFun

task1 = with_timeout(2) do
  sleep(3)
end
task2 = with_timeout(2) do
  return 42
end
task3 = with_timeout(2) do
  sleep(3)
end
task4 = with_timeout(3) do
  throw("foobar")
end

wait(task1) # throws TaskFailedException wrapping TimeoutError

fetch(task2) == 42 # success

cancel(task3)
wait(task3) # throws TaskFailedException wrapping CancellationError

wait(task4) # throws TaskFailedException wrapping "foobar"
```


# Meta Types
Meta Types are types (abstract or concrete) which either provide additional information on other types, or merely convey
additional information to the compiler. In the simplest instance, this allows adjusting the behavior of otherwise
identical functions, or, vice versa, customizing the behavior of an otherwise identical structure.

## Ident
The `Ident` meta type does not contain any information. It is designed to enable the compiler to dispatch based on
actual `Symbol` values as opposed to the `Symbol` type.

### Signature
```julia
struct Ident{S} end
```

### Example
```julia
struct Ident{S} end

extract(::Ident{:foo}) = 42
extract(::Ident{:bar}) = 69.69
```

## Optional & Unknown
*ExtraFun* introduces an `Optional{S, T}` meta type which represents a value which theoretically exists but may or may not be loaded at the time. If the value is not loaded, the `Optional` will contain `unknown` - the only instance of `Unknown`, similar to `nothing` and `Nothing`. While `T` can be any type, `S` is a vanity parameter intended as a unique identifier for your `Optional`, allowing specialization of `Base.getindex(::Optional{S})` while retaining interoperability with other `Optional`s of other `S`.

### Usage
The signature of `Optional` is rather complex. Plentiful specializations of `Base.convert` allow you to use it in the most intuitive ways. Generally, the `S` identifier can be ignored; it will default to `:generic`. It is only relevant to retrieving the actual value of the `Optional` in case the current value is `unknown`.

Getting and setting the value proceeds much like `Ref` through `Base.getindex` and `Base.setindex!`, or rather `opt[]` and `opt[] = value`. The default implementation of `Base.getindex` tests if the wrapped value is `unknown`. If so, it calls `ExtraFun.load(::Optional)`, caches its return value, and passes it on. The default implementation of `Base.setindex!` always overrides the value regardless. All of the above methods may be specialized on your `S` identifier.

Alternatively, you may test if an `Optional` contains `unknown` with `ExtraFun.isunknown`, and then `ExtraFun.load` it with additional arguments if necessary.

Generally, whichever usage you imagine is probably possible. If not, drop me an issue and I'll see about implementing it!

Some examples:

```julia
Optional() # == Optional{:generic, Any}(unknown)
Optional(42) # == Optional{:generic, Int}(42)
Optional(:myoptional, 24)
Optional{:myoptional}() # == Optional{:myoptional, Any}(unknown)
Optional{:foo, Real}() # == Optional{:foo, Real}(unknown)
Optional{:bar, Integer}(42.) # == Optional{:bar, Integer}(42)

struct Foo
  opt::Optional{:foo, Float32}
end
Foo() = Foo(unknown)
Foo() # == Foo(Optional{:foo, Float32}(unknown))
Foo(42) # == Foo(Optional{:foo, Float32}(42.0f0))
Foo(42).opt[] === 42.f0
Foo(Optional(42)) # == Foo(Optional{:foo, Float32}(42.0f0))
Foo().opt   = 42 # |-- These are equivalent due to Base.convert
Foo().opt[] = 42 # |--

struct Bar
  opt::Optional{:bar}
end
Bar(42) # == Bar(Optional{:bar, Int}(42))
Bar(Optional{:generic, Integer}(42)) # == Bar(Optional{:generic, Integer}(42))

struct Baz
  opt::Optional{S, Float32} where S
end
ExtraFun.load(opt::Optional{:baz}) = opt.value = 69.69
ExtraFun.load(io::IO, opt::Optional{:baz}) = opt.value = read(io, Float32)

Baz(42) # == Baz(Optional{:generic, Float32}(42.0f0))
Baz(Optional{:baz, Real}(42)) # == Baz(Optional{:baz, Float32}(42.0f0))
Baz(Optional(:baz, 42)) # == Baz(Optional{:baz, Float32}(42.0f0))
Baz(unknown).opt[] ≈ 69.69

let baz = Baz(unknown)
  buff = IOBuffer() # Prepare external storage
  buff.write(24.f0)
  buff.seek(0)
  
  load(buff, baz)
  baz.opt[] == 24.f0
end
```

Sometimes, simply calling `load(optional)` is not enough. You may depend on additional arguments such as a file handle. In that case, manually 

# XCopy
A more complex pattern which ExtraFun provides is the `xcopy` function and macro family. These allow customizing by various degrees of depth how an object is copied.

## xcopy function
Copies the template object, overriding the copy's fields by keyword arguments.

### Signature
```julia
xcopy(x::T)::T
```

### Example
```julia
struct MyStruct
    int::Int
    flag::Bool
end

@xcopy MyStruct
xcopy(MyStruct(0, false), int=42) # MyStruct(42, false)
```

## @xcopy macro
Makes a given type `xcopy`able; `xcopy` is by design not generic.

### Signature
```julia
@xcopy(T::Type)
```

## xcopy_construct function
Actually constructs a new instance of the same type of the source object.

### Signature
```julia
xcopy_construct(tpl::T, args...; kwargs...)::T
```

Creates a new instance of `T` with specified `args` and `kwargs`. Specializations may change the behavior entirely, or simply add further initialization based on `tpl`. The arguments - both positional and keyword - are received from `xcopy` which copies these either from `tpl` or uses a customized/overridden value.

Normally, it won't be necessary to override this method, but it can be useful to trigger additional logic upon the newly constructed object.

## xcopy_override
Retrieves the copied value for the copied object. By default, retrieves `tpl`'s own field. If the field itself is `Base.copy`able, it is copied. Otherwise, it is returned directly (referenced).

### Signature
```julia
xcopy_override(tpl, ::FieldCopyOverride{F})::Any
```

`F` is a `Symbol` representing the field name for which to retrieve the copied value.

Specializations may specialize this method to further customize the behavior of copying individual fields of `tpl`. However, it is strongly advised to use `@xcopy_override` to implement such a specialization for convenience.

## @xcopy_override
Convenience macro to specialize `xcopy_override`.

### Signature
```julia
@xcopy_override(T::Type, S::Symbol, expr::Expr)
```

`T` is the type for which the `xcopy` is being implemented. `S` is the field for which the copied value is overridden. `expr` is the expression used to compute the overridden value.

### Example
```julia
struct MyStruct
    int::Int
    flag::Bool
end

@xcopy MyStruct
@xcopy_override MyStruct :int tpl.int + 1
xcopy(MyStruct(1, false)) == MyStruct(2, false) # == true
```
