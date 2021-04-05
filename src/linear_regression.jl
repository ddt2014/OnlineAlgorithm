include("stats.jl")

using LinearAlgebra
#-------------------------------------------------#  linear regression
"""
    LinearRegression1D(T::Type = Float64)
    y = β * x + α, where x::Number
"""
mutable struct LinearRegression1D{T<:Number} <: OnlineAlgorithm{Number}
    x_var::Variance{T}
    xy_cov::Covariance{T}
    x_mean::Mean{T}
    y_mean::Mean{T}
    β::T
    α::T
    n::Int
end
LinearRegression1D(T::Type = Float64) = (
    LinearRegression1D(
        Variance(T),
        Covariance(T),
        Mean(T),
        Mean(T),
        T(0),
        T(0),
        0
    )
)
function get_para(o::LinearRegression1D)
    return (o.β, o.α)
end
@generated function value(o::LinearRegression1D)
    return  :(o.β)
end

function update!(o::LinearRegression1D{T}, x::Number, y::Number) where {T<:Number}
    o.n += 1
    if o.n == 1
        o.β = 1.0
        o.α = y - x
    else
        o.α = o.y_mean.mean - o.β * o.x_mean.mean
        o.β = o.xy_cov.covariance / (o.x_var.variance + 1e-6)
    end

    o.x_mean = update!(o.x_mean, x)
    o.y_mean = update!(o.y_mean, y)
    o.x_var = update!(o.x_var, x)
    o.xy_cov = update!(o.xy_cov, x, y)

    return o
end


#-------------------------------------------------#  linear regression
"""
    LinearRegression(T::Type = Float64)
"""
mutable struct LinearRegression <: OnlineAlgorithm{Number}
    weight::Matrix{Float64}
    n::Int
end
LinearRegression() = LinearRegression(zeros(1, 1),  0)

value(o::LinearRegression) = get_para(o)

function Base.show(io::IO, o::LinearRegression)
    print(io, typeof(o), ": ")
    fields =  fieldnames(typeof(o))
    print(io, "coef = ", get_para(o))
    print(io, " | n = ", o.n)
end

function _LRHelper(a, b, n)
    return a + (b - a) / n
end

function update!(o::LinearRegression, xy) where {T<:Number}
    o.n += 1
    x, y = xy
    if o.n == 1
        o.weight = zeros(length(x) + 1, length(x) + 1)
    end
    for j in 1:(size(o.weight, 2) - 1)
        o.weight[j, end] = _LRHelper(o.weight[j, end], x[j] * y, o.n)  # x`y
        for i in 1:j
            o.weight[i, j] = _LRHelper(o.weight[i, j], x[i] * x[j], o.n)  # x`x
        end
    end
    o.weight[end] = _LRHelper(o.weight[end], y * y, o.n)  # y`y

    return o
end

function get_para(o::LinearRegression)
    return (
        Symmetric(o.weight[1:(end - 1), 1:(end - 1)])
        \ o.weight[1:(end  -1), end]
    )
end
