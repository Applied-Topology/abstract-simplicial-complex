using LinearAlgebra 
using Combinatorics
using DelimitedFiles
using SparseArrays

include("new_sparse_coding.jl")
"""
    vrips_complex(data::Array, epsilon::Number, max_vert::Int)

Constructs the Vietoris-Rips Complex based on a data matrix and epsilon value
The data matrix is such that each row is a data point.  
For example, if two points are within epsilon of each other, they form a 1-simplex (segment).
If the maximum distance between three points is within epsilon, they form a 2-simplex (triangle).
The maximum dimension of a simplex in the Vietoris-Rips complex is given by max_vert-1
Returns vrips, a dictionary with key equal to the dimension of the simplices in the complex 
"""
function vrips_complex(data::Array, delta::Number, max_vert::Int)
    @assert (delta >= 0) "Epsilon must be greater than or equal to 0"
    m,n = size(data)
    distances = zeros(m,m)
    for i = 1:m
        for j = i:m
            distances[i,j] = norm(data[i,:] - data[j,:])
        end 
    end    
    vrips = Dict{Int, Array}()
    vrips[1-1] = 1:m
    for vert = 2:max_vert
        dist_dict = Dict{Float64, Array{Tuple}}()
        vrips[vert-1] = []
        combos  = combinations(1:m, vert) 
        for comb in combos
            pairs = combinations(comb, 2)
            key = maximum(distances[x,y] for (x,y) in pairs) 
            if haskey(dist_dict, key)
                push!(dist_dict[key], Tuple(comb))
            else 
                dist_dict[key] = [Tuple(comb)]
            end 
        end 
        dists = collect(keys(dist_dict)) 
        inds = sortperm(dists)
        lind = searchsortedlast(dists[inds], delta)
        rel_dists = dists[inds[1:lind]]
        for dist in rel_dists
            append!(vrips[vert-1], dist_dict[dist])
        end 
    end 
    return vrips
end 


"""
    subtuple(A::Tuple, B::Tuple)::Bool 

Returns a boolean if A is a subtuple of B
Assumes that A, B are both sorted 
"""
@inline function subtuple(A::Tuple, B::Tuple)::Bool
    i = 1
    j = 1
    while A[i] >= B[j]
        if A[i] == B[j]
            i += 1
        end 
        j += 1
         
        if (i > length(A)) && (j > length(B)) 
            return true
        elseif (j > length(B))
            return false 
        elseif (i > length(A))
            return true
        end 
    end 
    return false
end 

"""
    boundary_matrix(cech::Dict, k::Int)

Constructs the boundary matrix ∂k → C_k -> C_{k-1} given a Cech complex, k dimension of the simplices in the complex 
"""
@inline function boundary_matrix(cplx, k)
    @assert haskey(cplx, k) "No complex exists, so no boundary matrix"
    columns = cplx[k]        
    
    if k == 0
        return spzeros(Bool, 1, length(columns))
    end 

    rows = Set{Tuple}() 
    for col in columns
        combos = Set{Tuple}(Tuple(x) for x in combinations(col, k))
        union!(rows, combos)
    end 
    rows = collect(rows)

    # boundary_matrix = MMatrix{length(rows), length(columns)}(zeros(Bool, length(rows), length(columns)))
    boundary_matrix = spzeros(Bool, length(rows), length(columns))
    for row = 1:length(rows)
        for col = 1:length(columns)
            boundary_matrix[row, col] = subtuple(rows[row], columns[col])
        end 
    end 
    @show size(boundary_matrix)
    return boundary_matrix
end 


"""
    betti(cplx, k::Int)

Returns the Betti numbers for H_k, given a simplicial complex cplx. 
Does this by computing the SNF of the boundary matrices
So the kernel of the boundary matrix C_k -> C_{k-1}
And the image of the boundary matrix C_{k+1} -> C_k
TODO: Fix me 
"""
function betti(cplx, k::Int)
    @time bmk = boundary_matrix(cplx,k)
    @time bmkp1 = boundary_matrix(cplx,k+1)
    # @time P,D,Q,r = SNF!(bmk)
    # @time P1,D1,Q1,r1 = SNF!(bmkp1)
    @time r = get_rank!(bmk)
    @time r1 = get_rank1(bmkp1)
    println("Dim of boundary matrix ", size(bmk))
    println("Rank of del k: ", r)
    println("Dim of im k+1, ", r1)
    return (size(bmk)[2] - r) - r1 
end 

"""
    compute_imker(cplx, k::Int)

Returns the image and kernel of ∂_k : C_k → C_{k-1}
Output (dim Im ∂_k, dim ker ∂_k)
"""
function compute_imker(cplx, k::Int)::Tuple{Int, Int}
    bmk = boundary_matrix(cplx, k)
    # P,D,Q,r = SNF!(bmk)
    @time r = get_rank!(bmk)
    return (r, size(bmk)[2]-r)
end 

"""
    vrips_filtration(deltas::Array)

Performs filtration on the Vietoris Rips Complex.  Returns a list of complexes  
"""
function vrips_filtration(data, deltas::Array)
    filtration = []
    i = 1
    bettis = [] 
    for delta in deltas 
        cplx = vrips_complex(data,delta,4)
        push!(filtration, cplx)
        @show b0, z0 = compute_imker(cplx, 0)
        @show b1, z1 = compute_imker(cplx, 1)
        @show b2, z2 = compute_imker(cplx, 2)
        @show b3, z3 = compute_imker(cplx, 3)
        h0 = z0 - b1
        h1 = z1 - b2
        h2 = z2 - b3
        push!(bettis, (h0, h1, h2))
        println(i)
        i += 1
    end 
    return filtration, bettis
end 

"""
    get_deltas(data::Array, step::Int)

Returns a list of all possible distances, to perform the Vietoris Rips filtration on.
"""
function get_deltas(data::Array, step::Int)
    m,n = size(data)
    deltas = [] 
    for i = 1:m
        for j = i+1:m
            push!(deltas, norm(data[i,:] - data[j,:]))
        end 
    end    
    return sort(unique(deltas))[1:step:end]
end 


include("persistence.jl")

function main()
    files = readdir(joinpath(pwd(), "data"))
    pds = Dict()
    Threads.@threads for file in files 
        println(file)
        data = readdlm(joinpath(pwd(), "data", file), ',')[:,2:end]
        deltas = get_deltas(data, 20)
        filtration, bettis = vrips_filtration(data, deltas[1:10])
        @show (bettis)
        pd = mk_persistence_diagram(bettis)
        @show pd
        pds[file] = pd
    end 

    for file in files 
       plot_persistence(pds[file], filename=file[1:end-4])
    end 
    # cplx = vrips_complex(data, deltas[4], 4)
    # BM3, cols3, rows3 = boundary_matrix(cplx, 3) 
    # BM2, cols2, rows2 = boundary_matrix(cplx, 2)
    # @time filtration = vrips_filtration(data, collect(1:10))


    # m,n = size(data)
    # distances = zeros(m,m)
    # for i = 1:m
        # for j = i:m
            # distances[i,j] = norm(data[i,:] - data[j,:])
        # end 
    # end    

    # @time for i=1:10
        # push!(ccx, cech_complex(data, i, 2))
    # end 
end 

main()


