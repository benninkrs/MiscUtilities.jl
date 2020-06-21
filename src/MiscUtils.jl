# Miscellaneous conveniences/utilities for Julia
module MiscUtils

export Maybe, Optional, None, TTuple, Iterable
export Imatrix
export unzip, allsame, allequal
export @showargs

import Base: size, axes

# Type Aliases
const Maybe{T} = Union{T, Missing}
const Optional{T} = Union{T, Nothing}
const None = Union{}
const Iterable = Union{Tuple, AbstractArray, UnitRange, Base.Generator}
const TTuple{T} = Tuple{Vararg{T}}

using LinearAlgebra
const Imatrix = LinearAlgebra.I


size(x::AbstractArray, dims::Iterable) = map(d->size(x, d), dims)
axes(x::AbstractArray, dims::Iterable) = map(d->axes(x, d), dims)


# These are possibly inefficient -- they iterate over z once for each field.
# The alternative is to iterate once, and push! onto multiple vectors
unzip(z) = unzip(z, eltype(z))
unzip(z, ::Type{T} where T<:Tuple) = map(i -> getindex.(z, i), ntuple(Int, length(first(z))))
unzip(z, t::Type{T} where T<:NamedTuple) = map(i -> getindex.(z, i), (;zip(fieldnames(t), fieldnames(t))...))



"""
	allsame(itarable)

Return `true` if all elements in the iterable are the same (===).
"""
function allsame(it::Iterable)
	if length(it) <= 1
		return true
	end
	v = first(it)
	for v_ in it
		v_ === v || return false
	end
	return true
end


"""
	allequal(iterable)

Return `true` if all elements in the iterable are equal (==).
"""
function allequal(it::Iterable)
	if length(it) <= 1
		return true
	end
	v = first(it)
	for v_ in it
		v_ === v || return false
	end
	return true
end

macro showargs(args...)
	for (i,arg) in enumerate(args)
		println(i, ":  ", arg)
	end
	return :(nothing)
end


# macro set(ex, val)
# 	@assert ex isa Expr "First argument to @set must be of the form x.a or x[i]"
# 	if ex isa Expr
# 		if ex.head == :ref
# 			return esc( :( Base.setindex($(ex.args[1]), $val, $(ex.args[2:end]...)) ) )
# 		elseif ex.head == :.
# 			return esc( :( setfield($(ex.args[1]), $val, $(ex.args[2:end]...)) ) )
# 		end
# 	end
# 	error("First argument to @set must be of the form x.a or x[i]")
# end


#  stolen from ConstructionBase.jl
# setfield(obj, val, field::Symbol) = setfield_(obj, val, Type{field})
# @generated function setfield_(obj, val, ::Type{Type{field}}) where {field}
# 	fields = fieldnames(obj)
# 	show(obj)
# 	show(field)
# 	show(fields)
#     if in(field, fields)
#         args = map(fields) do fn
#             if fn == field
#                 :( $val )
#             else
#                 :(obj.$fn)
#             end
#         end
#         return Expr(:block,
#             Expr(:meta, :inline),
#             Expr(:call,:($obj($(args...))))
#         )
#     else
# 		 :(setproperty_unknown_field_error(obj, field))
#     end
# end
#
# setproperty_unknown_field_error(obj, field) = error("An object of type $(typeof(obj)) does not have a field $field")



#import Statistics: quantile, quantile!, _quantile, _quantilesort!

# quantile(v::AbstractArray, p; sorted::Bool = false, dim) = quantile!(sorted ? v : Base.copymutable(v), p; sorted=sorted, dim)
#
# quantile!(v::AbstractVector, p::Real; sorted::Bool=false) = _quantile(_quantilesort!(v, sorted, p, p, dim), p, dim)
#
# """
# Capture variables as a named tuple
# """
# macro namedtuple(ex)
#     Expr(:tuple, [Expr(:(=), esc(arg), arg) for arg in ex.args]...)
# end
#
#
# function otherdims(n, dims)
#     return tuple(setdiff(1:n, dims)...)
# end


# want a way to
# function eachsliceindex(sz; dims)
#     sz[dims] .= 1  # not always mutable
#     ci = CartesianIndices(sz)
#     # ... ?
# end
#
#
# function mapslices!(f, A; dims)
#     for i in eachsliceindex(A; dims)
#         A[i...] = f(A[i...])
#     end
# end


# function _quantilesort!(v::AbstractArray, sorted::Bool, minp::Real, maxp::Real, dim)
#     isempty(v) && throw(ArgumentError("empty data vector"))
#     @assert !has_offset_axes(v)
#
#     if !sorted
#         lv = length(v)
#         lo = floor(Int,1+minp*(lv-1))
#         hi = ceil(Int,1+maxp*(lv-1))
#
#         # only need to perform partial sort
#         sort!(v, 1, lv, Base.Sort.PartialQuickSort(lo:hi), Base.Sort.Forward)
#     end
#     ismissing(v[end]) && throw(ArgumentError("quantiles are undefined in presence of missing values"))
#     isnan(v[end]) && throw(ArgumentError("quantiles are undefined in presence of NaNs"))
#     return v
# end
#
#
# # Core quantile lookup function: assumes `v` sorted along dimension dim
# @inline function _quantile(v::AbstractVector, p::Real, dim)
#     0 <= p <= 1 || throw(ArgumentError("input probability out of [0,1] range"))
#     @assert !has_offset_axes(v)
#
#     lv = size(v, dim)
#     f0 = (lv - 1)*p # 0-based interpolated index
#     t0 = trunc(f0)
#     h  = f0 - t0
#     i  = trunc(Int,t0) + 1
#
#     T  = promote_type(eltype(v), typeof(v[1]*h))
#
#     if h == 0
#         return convert(T, v[i])
#     else
#         a = selectdim(v, dim, i)
#         b = selectdim(v, dim, i+1)
#         if isfinite(a) && isfinite(b)
#             return convert(T, a + h*(b-a))
#         else
#             return convert(T, (1-h)*a + h*b)
#         end
#     end
# end

end
