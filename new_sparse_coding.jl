using LinearAlgebra
using SparseArrays

"""
Computes the Smith Normal Form of a matrix A.
"""
function SNF!(A::Array{Bool})
    m,n = size(A)
    S = [Matrix{Bool}(I,m,m) A; zeros(Bool,n,m) Matrix{Bool}(I,n,n)] 
    @time rref!(S, m+1, m, n)
    R, rank = shift_cols!(S, m+1, m, n) 
    clear_cols!(R, rank, m+1,  m, n) 
    P = R[1:m, 1:m]
    D = R[1:m, m+1:m+n]
    Q = R[m+1:m+n, m+1:m+n]
    @assert rank == sum(D)
    return P,D,Q,rank
end 

function get_rank!(A::SparseMatrixCSC)
    m,n = size(A)
    rref!(A, 1, m, n)
    rank = 0
    for row = 1:size(A,1)
        for col = 1:size(A,2)
            if A[row, col]
                rank += 1
                break
            end 
        end 
    end 
    return rank
end

@inline function inv_z2(M::Array{Bool})
    m,n = size(M)
    @assert (m==n) "M should be square" 
    S = [M Matrix{Bool}(I,m,m)]
    rref!(S, 1, m, n) 
    return S[1:m, n+1:end], S
end 

@inline function swapcols!(X::SparseMatrixCSC, i::Int, j::Int)
    for k = 1:size(X,1)
        X[k,i], X[k,j] = X[k,j], X[k,i]
    end
end

@inline function swaprows!(X::SparseMatrixCSC, i::Int, j::Int)
    for k = 1:size(X,2)
        X[i, k], X[j, k] = X[j, k], X[i, k]
    end
end

# @inline function *(A::Array{Bool}, B::Array{Bool})::Array{Bool}
    # m,n = size(A) 
    # o,p = size(B)
    # @assert (n == o) "Dimension mismatch"
    # C = zeros(Bool, m, p)
    # m,n = size(C)
    # filler = zeros(Bool, size(A, 2))
    # for row=1:m
        # for col=1:n
            # C[row, col] = reduce(⊻, A[row, :] .& B[:, col])
            # # for k = 1:size(A,2)
                # # filler[k] = (A[row,k] & B[k,col])
            # # end 
            # # C[row, col] = reduce(⊻, filler)
        # end 
    # end 
    # return C
# end 

@inline function rref!(S::SparseMatrixCSC, lead::Int, m::Int, n::Int)   
    first = lead 
    for row=1:m
        if lead > first+n-1
            return S 
        end 
        r = row 
        while ! S[r, lead] 
            r += 1
            if r > m
                r = row
                lead += 1
                if lead > first+n-1
                    return S
                end 
            end 
        end 
        if r != row
            swaprows!(S, r, row)
        end 
        for r=1:m
            if r != row
                scale = S[r,lead]
                for c = 1:size(S,2)
                    S[r,c] ⊻= (scale & S[row, c]) 
                end 
            end 
        end 
        lead += 1
    end 
    return S
end 

"""
Shifts columns of a row reduced echelon form matrix R such that R[i, i] = 1  for all 1 ≤ i ≤ n 
"""
@inline function shift_cols!(R::Array{Bool}, lead::Int, m::Int, n::Int)
    rank = 0 
    for (col,row) = zip(lead:lead+n-1, 1:m)
        if ! R[row, col] 
            c = col
            while c <= lead+n-1
                if R[row, c]
                    swapcols!(R, c, col)
                    break
                end 
                c += 1
            end 
            if c > lead+n-1
                return R, row-1
            end 
        end 
        rank = row
    end 
    return R, rank
end 

"""
Clears out linearly dependent columns through columns operations which zero out the elements 
"""
@inline function clear_cols!(R::Array{Bool}, rank::Int, lead::Int, m::Int, n::Int)
    for col=(lead+rank):(lead+n-1)
        for row=1:m
            if R[row, col] 
                for r = 1:size(R,1)
                    R[r,col] ⊻= R[r, row+lead-1]
                end 
            end 
        end 
    end 
    return R
end 

# function main()
    # # A = [1 1 0; 0 1 1]
    # # A = [0 1 1; 1 0 0; 0 1 0]
    # # A = [1 0 0; 0 0 1; 0 1 0]
    #
   
    # A = rand([0 1], 5, 8)
    # A = rand([0 1], 30, 29)

    # A = [1 1 1 0 0; 1 1 1 0 1; 1 1 0 1 1] 
    # # A =[ 1  1  1  1  0  1  1  1; 0  0  1  0  0  0  1  1 ; 1  0  1  1  1  1  1  0 ; 0  0  1  1  0  1  0  1 ; 1  0  0  1  0  1  0  1]
    # # A = [ 0  0  0  1  1;
     # # 1  0  1  1  0;
     # # 0  1  0  0  1;
     # # 0  1  0  0  1;
     # # 0  0  0  1  0]
    # # A = [ 0  0  0  1  1; 1  1  1  0  0; 1  1  1  0  0; 0  0  0  1  0; 1  0  0  0  1]
    # # A = [ 0  1  1  1  1; 0  0  0  0  0 ; 0  1  1  1  0 ; 0  0  1  0  0 ; 0  0  0  0  0 ]

    # @time P,D,Q,rank = SNF!(Matrix{Bool}(A))

    # Pinv, X = inv_z2(P) 
    # show(stdout, "text/plain", Pinv*D)
    # println()
    # t = Matrix{Bool}(A)
    # show(stdout, "text/plain", t*Q)
    # val  = (Pinv*D) .⊻ (t*Q)
    # println("\nPoo\n", sum(val))

    # show(stdout, "text/plain", A)
    # println("")
    # X = Matrix{Bool}(A)
    # m, n = size(A)
    # R = rref!(X, 1, m, n)
    # show(stdout, "text/plain", R)
    # println("")
    # R, rank = shift_cols!(R,1,m,n) 
    # show(stdout, "text/plain", R)
    # println("Rank ", rank)
    # R = clear_cols!(R,rank,m,n) 
    # show(stdout, "text/plain", R)
    # println("")
    # #
    # println("OG Matrix")
    # show(stdout, "text/plain", A) 
    # println()
    # K,S = inv_z2(Matrix{Bool}(A))   
    # show(stdout, "text/plain", K)
    # println()
    # show(stdout, "text/plain", S)
    # println("Verifiying, \n")
    # show(stdout, "text/plain",  Matrix{Bool}(A) * K)
# end 

# main()


