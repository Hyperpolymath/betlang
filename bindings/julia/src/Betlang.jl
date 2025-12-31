# SPDX-License-Identifier: MIT OR Apache-2.0
"""
    Betlang

Julia bindings for the Betlang probabilistic programming language.

Provides ternary bet primitives and probability distributions.

# Examples
```julia
using Betlang

# Ternary bet - uniform choice from 3 options
choice = ternary_bet()  # Returns 0, 1, or 2

# Weighted ternary bet
result = weighted_ternary_bet(0.5, 0.3, 0.2)

# Standard distributions
x = uniform(0.0, 1.0)
y = normal(0.0, 1.0)
z = exponential(2.0)

# Sample arrays
samples = normal_samples(1000, 0.0, 1.0)
```
"""
module Betlang

using Libdl

# Library path - adjust for your installation
const LIBBET = Ref{Ptr{Cvoid}}(C_NULL)

function __init__()
    # Try to load the library from common locations
    lib_names = [
        "libbet_julia",
        joinpath(@__DIR__, "..", "target", "release", "libbet_julia"),
        joinpath(@__DIR__, "..", "target", "debug", "libbet_julia"),
    ]

    for name in lib_names
        try
            LIBBET[] = dlopen(name)
            return
        catch
            continue
        end
    end

    @warn "Could not load Betlang library. Some functions may not work."
end

# ============================================================================
# Core Ternary Bet Primitive
# ============================================================================

"""
    ternary_bet() -> Int

Returns 0, 1, or 2 with equal probability (1/3 each).
This is the core primitive of Betlang.

# Example
```julia
options = ["Rock", "Paper", "Scissors"]
choice = options[ternary_bet() + 1]
```
"""
function ternary_bet()::Int
    ccall(dlsym(LIBBET[], :bet_ternary), Cint, ())
end

"""
    weighted_ternary_bet(w0, w1, w2) -> Int

Returns 0, 1, or 2 with probabilities proportional to the given weights.

# Arguments
- `w0`: Weight for outcome 0
- `w1`: Weight for outcome 1
- `w2`: Weight for outcome 2

Weights are normalized internally, so they don't need to sum to 1.
"""
function weighted_ternary_bet(w0::Real, w1::Real, w2::Real)::Int
    ccall(dlsym(LIBBET[], :bet_weighted_ternary), Cint,
          (Cdouble, Cdouble, Cdouble),
          Float64(w0), Float64(w1), Float64(w2))
end

"""
    ternary_logic() -> Int

Returns a ternary logic value:
- `-1`: false
- `0`: unknown
- `1`: true

Based on Kleene's three-valued logic.
"""
function ternary_logic()::Int
    ccall(dlsym(LIBBET[], :bet_ternary_logic), Cint, ())
end

# ============================================================================
# Discrete Distributions
# ============================================================================

"""
    uniform_int(low, high) -> Int

Sample uniformly from integers in [low, high] (inclusive).
"""
function uniform_int(low::Integer, high::Integer)::Int
    ccall(dlsym(LIBBET[], :bet_uniform_int), Clong,
          (Clong, Clong), Int64(low), Int64(high))
end

"""
    bernoulli(p) -> Bool

Returns true with probability p, false otherwise.
"""
function bernoulli(p::Real)::Bool
    ccall(dlsym(LIBBET[], :bet_bernoulli), Cint, (Cdouble,), Float64(p)) != 0
end

"""
    binomial(n, p) -> Int

Number of successes in n Bernoulli trials with success probability p.
"""
function binomial(n::Integer, p::Real)::Int
    ccall(dlsym(LIBBET[], :bet_binomial), Clong,
          (Cuint, Cdouble), UInt32(n), Float64(p))
end

"""
    poisson(λ) -> Int

Sample from Poisson distribution with rate λ.
"""
function poisson(λ::Real)::Int
    ccall(dlsym(LIBBET[], :bet_poisson), Clong, (Cdouble,), Float64(λ))
end

"""
    categorical(weights) -> Int

Sample from categorical distribution with given weights.
Returns an index from 0 to length(weights)-1.
"""
function categorical(weights::Vector{<:Real})::Int
    w = Float64.(weights)
    ccall(dlsym(LIBBET[], :bet_categorical), Cint,
          (Ptr{Cdouble}, Csize_t), w, length(w))
end

# ============================================================================
# Continuous Distributions
# ============================================================================

"""
    uniform(low, high) -> Float64

Sample uniformly from [low, high).
"""
function uniform(low::Real, high::Real)::Float64
    ccall(dlsym(LIBBET[], :bet_uniform), Cdouble,
          (Cdouble, Cdouble), Float64(low), Float64(high))
end

"""
    standard_normal() -> Float64

Sample from standard normal distribution (mean=0, std=1).
"""
function standard_normal()::Float64
    ccall(dlsym(LIBBET[], :bet_standard_normal), Cdouble, ())
end

"""
    normal(mean, std) -> Float64

Sample from normal distribution with given mean and standard deviation.
"""
function normal(mean::Real, std::Real)::Float64
    ccall(dlsym(LIBBET[], :bet_normal), Cdouble,
          (Cdouble, Cdouble), Float64(mean), Float64(std))
end

"""
    exponential(rate) -> Float64

Sample from exponential distribution with given rate.
"""
function exponential(rate::Real)::Float64
    ccall(dlsym(LIBBET[], :bet_exponential), Cdouble, (Cdouble,), Float64(rate))
end

"""
    gamma_dist(shape, scale) -> Float64

Sample from gamma distribution with given shape and scale.
"""
function gamma_dist(shape::Real, scale::Real)::Float64
    ccall(dlsym(LIBBET[], :bet_gamma), Cdouble,
          (Cdouble, Cdouble), Float64(shape), Float64(scale))
end

"""
    beta_dist(α, β) -> Float64

Sample from beta distribution with parameters α and β.
"""
function beta_dist(α::Real, β::Real)::Float64
    ccall(dlsym(LIBBET[], :bet_beta), Cdouble,
          (Cdouble, Cdouble), Float64(α), Float64(β))
end

# ============================================================================
# Array Sampling
# ============================================================================

"""
    uniform_samples(n) -> Vector{Float64}

Generate n samples from Uniform[0, 1).
"""
function uniform_samples(n::Integer)::Vector{Float64}
    out = Vector{Float64}(undef, n)
    ccall(dlsym(LIBBET[], :bet_sample_uniform_array), Cvoid,
          (Ptr{Cdouble}, Csize_t), out, n)
    out
end

"""
    normal_samples(n, mean, std) -> Vector{Float64}

Generate n samples from Normal(mean, std).
"""
function normal_samples(n::Integer, mean::Real, std::Real)::Vector{Float64}
    out = Vector{Float64}(undef, n)
    ccall(dlsym(LIBBET[], :bet_sample_normal_array), Cvoid,
          (Ptr{Cdouble}, Csize_t, Cdouble, Cdouble),
          out, n, Float64(mean), Float64(std))
    out
end

"""
    shuffle!(arr)

Shuffle array in place.
"""
function shuffle!(arr::Vector{Float64})
    ccall(dlsym(LIBBET[], :bet_shuffle_real), Cvoid,
          (Ptr{Cdouble}, Csize_t), arr, length(arr))
    arr
end

# ============================================================================
# Statistics
# ============================================================================

"""
    bet_mean(arr) -> Float64

Compute mean of array.
"""
function bet_mean(arr::Vector{Float64})::Float64
    ccall(dlsym(LIBBET[], :bet_mean), Cdouble,
          (Ptr{Cdouble}, Csize_t), arr, length(arr))
end

"""
    bet_variance(arr) -> Float64

Compute variance of array.
"""
function bet_variance(arr::Vector{Float64})::Float64
    ccall(dlsym(LIBBET[], :bet_variance), Cdouble,
          (Ptr{Cdouble}, Csize_t), arr, length(arr))
end

"""
    bet_std(arr) -> Float64

Compute standard deviation of array.
"""
function bet_std(arr::Vector{Float64})::Float64
    ccall(dlsym(LIBBET[], :bet_std), Cdouble,
          (Ptr{Cdouble}, Csize_t), arr, length(arr))
end

"""
    bet_covariance(x, y) -> Float64

Compute covariance of two arrays.
"""
function bet_covariance(x::Vector{Float64}, y::Vector{Float64})::Float64
    @assert length(x) == length(y)
    ccall(dlsym(LIBBET[], :bet_covariance), Cdouble,
          (Ptr{Cdouble}, Ptr{Cdouble}, Csize_t), x, y, length(x))
end

"""
    bet_correlation(x, y) -> Float64

Compute Pearson correlation coefficient.
"""
function bet_correlation(x::Vector{Float64}, y::Vector{Float64})::Float64
    @assert length(x) == length(y)
    ccall(dlsym(LIBBET[], :bet_correlation), Cdouble,
          (Ptr{Cdouble}, Ptr{Cdouble}, Csize_t), x, y, length(x))
end

# ============================================================================
# High-Level API
# ============================================================================

"""
    bet(a, b, c)

The ternary bet primitive - randomly returns one of three values.

# Example
```julia
result = bet("heads", "tails", "edge")
```
"""
function bet(a, b, c)
    choice = ternary_bet()
    if choice == 0
        return a
    elseif choice == 1
        return b
    else
        return c
    end
end

"""
    weighted_bet(options::Vector{Tuple{T, Real}}) where T

Weighted bet over multiple options.

# Example
```julia
result = weighted_bet([("win", 0.6), ("lose", 0.3), ("draw", 0.1)])
```
"""
function weighted_bet(options::Vector{Tuple{T, R}}) where {T, R<:Real}
    weights = Float64[w for (_, w) in options]
    idx = categorical(weights)
    return options[idx + 1][1]
end

"""
    monte_carlo(f, n::Int) -> Vector

Run function f n times and collect results.

# Example
```julia
results = monte_carlo(n=1000) do
    uniform(0, 1)^2 + uniform(0, 1)^2 <= 1
end
pi_estimate = 4 * sum(results) / length(results)
```
"""
function monte_carlo(f, n::Int)
    [f() for _ in 1:n]
end

"""
    version() -> String

Get Betlang library version.
"""
function version()::String
    ptr = ccall(dlsym(LIBBET[], :bet_version), Ptr{Cchar}, ())
    unsafe_string(ptr)
end

# Exports
export ternary_bet, weighted_ternary_bet, ternary_logic
export uniform_int, bernoulli, binomial, poisson, categorical
export uniform, standard_normal, normal, exponential, gamma_dist, beta_dist
export uniform_samples, normal_samples, shuffle!
export bet_mean, bet_variance, bet_std, bet_covariance, bet_correlation
export bet, weighted_bet, monte_carlo, version

end # module
